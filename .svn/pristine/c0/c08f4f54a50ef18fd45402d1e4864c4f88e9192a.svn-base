#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   01 May 2008 12:06:48  $
# $Workfile:   loadImport.ksh  $
#
# 05/01/08  Douglas Elder 	   Initial version
#
. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

export JRE=/opt/java1.4/jre
export CLASSPATH=$JRE/lib:$LIB_HOME/WindowAlgo.jar:$LIB_HOME/ojdbc14.jar:$LIB_HOME/log4j-1.2.3.jar:$LIB_HOME:.

cd $BIN_HOME
execJavaApp() {
	$JRE/bin/java -Xmx1024m $1 $2
	if [[ $? -ne 0 ]] ; then
		exit 4
	fi
}

loadImportTable() {
	sqlldr $DB_CONNECTION_STRING_FOR_SPO \
		control=$SRC_HOME/$1.ctl \
		rows=10000 readsize=10000000 bindsize=10000000 \
		log=$LOG_HOME/$1.log \
	       	bad=$LOG_HOME/$1.bad
	if [[ $? -ne 0 ]] ; then
		exit 4
	fi	
	if [[ -a $LOG_HOME/$1.log ]] ; then
		chmod 666 $LOG_HOME/$1.log
	fi
	if [[ -a $LOG_HOME/$1.bad ]] ; then
		chmod 666 $LOG_HOME/$1.bad
	fi
}


importToSpo() {
	sqlplus $DB_CONNECTION_STRING_FOR_SPO << EOF
set time on
set timing on
set term on
exec spoc17v2.pr_imp() ;
quit
EOF
	if [[ $? -ne 0 ]] ; then
		exit 4
	fi
}

loadImportTable $1
importToSpo
