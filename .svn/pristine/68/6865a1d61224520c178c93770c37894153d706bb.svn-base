#!/usr/bin/ksh
#
#SCCSID: %M%  %I%  Modified: %G% %U%
#
# Date      Who            Purpose
# --------  -------------  --------------------------------------------------
# 11/26/01  k. shew        Initial implementation
# 01/09/02  F. Fajardo     Added 'export' and change to java1.3.
# 01/28/02  k. shew        broke up itemsitemaster, item_loc_criticality_matrix
#			 	into smaller queries then cat'd data. 
# 01/28/02  F. Fajardo     Added to SCCS.
# 02/19/02  k. shew	   changed from >> to > 
#
# note: Query.jar uses WindowAlgo.ini
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

export JRE=/opt/java1.3/jre
export CLASSPATH=$JRE/lib:Query.jar:classes12.zip
$JRE/bin/java Query $DATA_HOME/cntl.txt $AMD_HOME/queries $DATA_HOME

if [ -r "$DATA_HOME/tmp_itemsitemaster1.dat" ] && \
		[ -r "$DATA_HOME/tmp_itemsitemaster2.dat" ] && \
		[ -r "$DATA_HOME/tmp_itemsitemaster3.dat" ]; then
	cat $DATA_HOME/tmp_itemsitemaster1.dat \
		$DATA_HOME/tmp_itemsitemaster2.dat \
		$DATA_HOME/tmp_itemsitemaster3.dat > $DATA_HOME/tmapi_itemsitemaster.dat
else
	echo "ERROR - not all tmp_itemsitemaster(1-3).dat files available"
fi;
	
if [ -r "$DATA_HOME/tmp_i_item_loc_criticality_matrix1.dat" ] && \
		[ -r "$DATA_HOME/tmp_i_item_loc_criticality_matrix2.dat" ] && \
		[ -r "$DATA_HOME/tmp_i_item_loc_criticality_matrix3.dat" ] && \
		[ -r "$DATA_HOME/tmp_i_item_loc_criticality_matrix4.dat" ]; then
	cat $DATA_HOME/tmp_i_item_loc_criticality_matrix1.dat \
		$DATA_HOME/tmp_i_item_loc_criticality_matrix2.dat \
		$DATA_HOME/tmp_i_item_loc_criticality_matrix3.dat \
		$DATA_HOME/tmp_i_item_loc_criticality_matrix4.dat > $DATA_HOME/tmapi_i_item_loc_criticality_matrix.dat
else
	echo 'ERROR - not all tmp_i_item_loc_criticality_matrix(1-4).dat files available'
fi;
