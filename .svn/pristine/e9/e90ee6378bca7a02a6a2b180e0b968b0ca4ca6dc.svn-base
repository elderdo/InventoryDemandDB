#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.6  $
#     $Date:   02 Jul 2008 15:06:56  $
# $Workfile:   amd_LoadFtpFile.ksh  $
#
# SCCSID: amd_LoadFtpFile.ksh  1.10  Modified: 01/13/04 10:35:55
#
#------------------------------------------------------------------------------
# This script will process all files on the external ftp server by
# transferring it to the local server and then loading it 
# into either the AMD_L67_SOURCE table or amd_mission_flights table.
#
# Date      By            History
# 11/01  Fernando F.      Initial Implementation
# 01/10  Fernando F.      Modified GenStats().
# 01/24  Fernando F.      Added sqlldr control to load new icao's and 
#                         mission types. Mod report to report dups.
# 04/03/02  Fernando F.   Added logic to populate filename field in
#                         amd_l67_source.
# 08/22/02  Fernando F.   Removed Joan Watson from distribution.
# 10/14/02  Fernando F.   Added Laurie Compton to distribution.
# 10/29/02  Fernando F.   Added emailing of actual L67 file to Laurie.
# 03/04/03  Thuy Pham     Modified FTPSERVER.
#
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh
FTPSERVER=
##FTPUSER=
FTPDir=/apps/CRON/AMD/data/L67GV
User=
Passwd=
TMPFILE=$LOG_HOME/TmPfTpFiLe
MesgFile=$LOG_HOME/MesgBody.txt
MesgRecpt1=laurie.compton@west.boeing.com
MesgRecpt2=douglas.s.elder@west.boeing.com
MesgRecpt3=phuong-thuy.pham@boeing.com

FileType="$1"
FileType=`echo $FileType |tr -A "L67" "L67"`
FileType=`echo $FileType |tr -A "GDSS" "GDSS"`

if [ "$FileType" = "L67" ]; then
	uType="L67"
elif [ "$FileType" = "GDSS" ]; then
	uType="GDSS"
else
	exit
fi


main()
{
	BuildList

	ProcessList

	GenStats
}


#
# Create list of current files to process
#
##BuildList()
##{
##	(ftp -n $FTPSERVER <<- EOF
##		user $FTPUSER
##		user $User $Passwd
##		cd $FTPDir
##		dir ${uType}*
##		dir ${lType}*
##EOF
##	)>$TMPFILE
##}
BuildList()
{
	(cd $FTPDir
		ll ${uType}*
	)>$TMPFILE
}

#
# Process file retreived in above list.
#
ProcessList()
{
	for InFile in `grep -i $FileType $TMPFILE|awk '{print $9}'`
	do
		SourceFile=$FTPDir/$InFile
		DestFile=$DATA_HOME/$InFile

##		ftp -n $FTPSERVER <<- EOF
##			 $User
##			 $Passwd
		 cp $SourceFile $DestFile
			quit
##EOF
	
		if [[ -f $DestFile ]]
		then
			if [ "$FileType" = "L67" ]; then
				LoadFile=$DestFile.tmp        #Will contain filename in file.
				AttFile=$DestFile.txt         #File to be attached.
				FileArg=`basename $DestFile`
			
				# Add the filename to the file to populate in the database.
				awk -v FileName=$FileArg \
					'{printf("%-50s%s\n", FileName,$0)}' $DestFile >$LoadFile

				print "Loading file $InFile to AMD_L67_SOURCE table."
				sqlldr \
					silent=header \
					userid=$DB_CONNECTION_STRING \
					data=$LoadFile \
					control=$SRC_HOME/amd_l67_source.ctl \
					log=$LOG_HOME/$InFile.log \
					bad=$LOG_HOME/$InFile.bad

				print "Emailing $InFile."
				echo "[include $DestFile text/plain base64]" > $AttFile
				cat $DestFile >>$AttFile
			##	elm -s $InFile $MesgRecpt1 < $AttFile
				cat $AttFile | mailx -s $InFile $MesgRecpt1
				cat $AttFile | mailx -s $InFile $MesgRecpt3
			##	elm -s $InFile $MesgRecpt3 < $AttFile

				rm -f $LoadFile $AttFile
			elif [ "$FileType" = "GDSS" ]; then
				InFileType=$InFile.Type.dat
				DestFileType=$DestFile.Type.dat

				print "\nCreating AMD_MISSION_TYPES file($InFileType) from $InFile."
				awk 'BEGIN{FS=","}
					{print $8 "," $8}' $DestFile | sort -u > $DestFileType

				print "\nLoading file $InFileType to AMD_MISSION_TYPES table."
				sqlldr \
					silent=header \
					userid=$DB_CONNECTION_STRING \
					data=$DestFileType \
					control=$SRC_HOME/amd_mission_types.ctl \
					log=$LOG_HOME/$InFileType.log \
					bad=$LOG_HOME/$InFileType.bad

				InFileIcao=$InFile.icao.dat
				DestFileIcao=$DestFile.icao.dat

				print "\nCreating AMD_AIRPORTS file($InFileIcao) from $InFile."
				awk 'BEGIN{FS=","}
					{print $6 "," $6}' $DestFile | sort -u > $DestFileIcao

				print "\nLoading file $InFileIcao to AMD_AIRPORTS table."
				sqlldr \
					silent=header \
					userid=$DB_CONNECTION_STRING \
					data=$DestFileIcao \
					control=$SRC_HOME/amd_airports.ctl \
					log=$LOG_HOME/$InFileIcao.log \
					bad=$LOG_HOME/$InFileIcao.bad

				print "\nLoading file $InFile to AMD_MISSION_FLIGHTS table."
				sqlldr \
					silent=header \
					userid=$DB_CONNECTION_STRING \
					data=$DestFile \
					control=$SRC_HOME/amd_mission_flights.ctl \
					log=$LOG_HOME/$InFile.log \
					bad=$LOG_HOME/$InFile.bad
			fi

			#
			# Remove source only if running from production
			#
			if [[ "$AMDENV" = "prod" ]]
			then
				print "Running on PROD so removing source file."
##				ftp -n $FTPSERVER <<- EOF
##					user $FTPUSER
##					user $User $Passwd
					del $SourceFile
					quit
##EOF
			fi
		else
			print "ERROR: Unable to ftp $SourceFile to $DestFile."
		fi;

	done
}


#
# Collect stats then email notification.
#
GenStats()
{
	rm -f $MesgFile

	for InFile in `grep -i $FileType $TMPFILE|awk '{print $9}'`
	do
		DestFile=$DATA_HOME/$InFile

		(if [[ -f $DestFile ]]
		then
			awk -v FileName=$InFile \
				'BEGIN{DupRec=0}
				/ORA-00001:/{
						DupRec=DupRec+1;
					}
				/Rows successfully loaded./{
						GoodRec=$1
					}
				/not loaded due to data errors./{
						ErrorRec=$1
					}
				/WHEN clauses were failed/{
						Discard=$1
					}
				/Total logical records read:/{
						TotalRec=$5
					}
				END {
					printf("Processed %s: %d loaded, %d error(s), %d duplicate(s).  ",FileName,GoodRec,ErrorRec-DupRec,DupRec)
					if (Discard==TotalRec)
					{
						printf("File is empty.")
					}
					printf("\n")
				}' $LOG_HOME/$InFile.log
		else
			print "ERROR: $InFile not processed due to an error."
		fi; ) >> $MesgFile

	done

	if [ -s $MesgFile ]
	then
		mailx -s "$FileType Notification" -r amd_loadFtpFile $MesgRecpt1 $MesgRecpt2 $MesgRecpt3 <$MesgFile
	fi
}


main $*
