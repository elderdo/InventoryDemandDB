#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.7  $
#     $Date:   11 Sep 2014
# $Workfile:   amd_bssmFlatFiles.ksh  $
#
# SCCSID: amd_bssmFlatFiles.ksh  1.1   Modifies: 07/26/04  10:22:53
#
#
# Date		By		History
# -----------	--------------	-----------------------------------------
# 07/16/04	Thuy P		Initial implementation.
# 09/1l/l4	Douglas Elder	Rev 1.7 Added InventorySummed_to_W
# 

. $UNVAR/apps/CRON/AMD/lib/amdconfig.ksh

DateStr="+%Y"
DateStr="$DateStr%m%d"
export TimeStamp=`date $DateStr`;

rm -f $DATA_HOME/AMDII*.TXT
rm -f $DATA_HOME/FedLog_Active*.TXT
rm -f $DATA_HOME/BSSM*.TXT
rm -f $DATA_HOME/PULL*.TXT
rm -f $DATA_HOME/V_8*.TXT
rm -f $DATA_HOME/RSP*.TXT

sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_Part_Info_A.sql 
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_Part_Info_B.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_Part_Info_C.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_Part_Info2.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_di_Demands_sum.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_2a_cat1.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Inventory.sql >$DATA_HOME/inventory.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/FedLog_Active_NINS.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/BSSM_2f_RAMP.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PULL_ORD1_D.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PULL_ORD1.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_di_Demands_SRANS-Conv.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/V_8_Capability-Requirement-Level-4.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/AMDII_In-Repair
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/InventorySranConv.sql >$DATA_HOME/AMDII_di_Inventory_SRANS-Conv.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/RSP_On_Hand_and_Objective.sql
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/InventorySummed_to_W.sql $DATA_HOME/AMDII_di_Inventory_summed_to_W_${TimeStamp}.TXT

chmod 660 $DATA_HOME/*.TXT
