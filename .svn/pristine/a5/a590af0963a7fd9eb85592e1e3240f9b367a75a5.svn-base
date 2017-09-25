#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   19 Mar 2009 14:13:00  $
# $Workfile:   findScript.awk  $
#
# This script is used to find the invoking
# script when combined with the following Unix 
# commands:
# ps -ef | grep $PPID | sort | head -1 | awk -f $LIB_HOME/findScript.awk
{
	for (i=NF;i>=1;i--) {
		if (index($i,".ksh") > 0) {
			print $i
		}
	}
}
