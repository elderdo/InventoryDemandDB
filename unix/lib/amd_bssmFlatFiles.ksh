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

sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PartInfoA.sql >$DATA_HOME/infoa.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PartInfoB.sql >$DATA_HOME/infob.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PartInfoC.sql >$DATA_HOME/infoc.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PartInfo2.sql >$DATA_HOME/info2.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PartSum.sql >$DATA_HOME/sum.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Cat1.sql >$DATA_HOME/cat1.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Inventory.sql >$DATA_HOME/inventory.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Nins.sql >$DATA_HOME/nins.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Ramp.sql >$DATA_HOME/ramp.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Ord1d.sql >$DATA_HOME/ord1d.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Ord1.sql >$DATA_HOME/ord1.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/PartSumSranConv.sql >$DATA_HOME/sranconv.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Capability.sql >$DATA_HOME/capability.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/Repair.sql >$DATA_HOME/repair.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/InventorySranConv.sql >$DATA_HOME/invsranconv.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/BssmRspOnHand.sql >$DATA_HOME/rsponhand.txt
sqlplus -s $DB_CONNECTION_STRING @$SRC_HOME/InventorySummed_to_W.sql $DATA_HOME/AMDII_di_Inventory_summed_to_W_${TimeStamp}.TXT


cat $SRC_HOME/infoa_header.txt $DATA_HOME/infoa.txt > $DATA_HOME/infoa_out.txt
cat $DATA_HOME/infoa_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_Part_Info_A_${TimeStamp}.TXT
rm -f $DATA_HOME/infoa*.*

cat $SRC_HOME/infob_header.txt $DATA_HOME/infob.txt > $DATA_HOME/infob_out.txt
cat $DATA_HOME/infob_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_Part_Info_B_${TimeStamp}.TXT
rm -f $DATA_HOME/infob*.*

cat $SRC_HOME/infoc_header.txt $DATA_HOME/infoc.txt > $DATA_HOME/infoc_out.txt
cat $DATA_HOME/infoc_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_Part_Info_C_${TimeStamp}.TXT
rm -f $DATA_HOME/infoc*.*

cat $SRC_HOME/info2_header.txt $DATA_HOME/info2.txt > $DATA_HOME/info2_out.txt
cat $DATA_HOME/info2_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_Part_Info2_${TimeStamp}.TXT
rm -f $DATA_HOME/info2*.*

cat $SRC_HOME/sum_header.txt $DATA_HOME/sum.txt > $DATA_HOME/sum_out.txt
cat $DATA_HOME/sum_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_di_Demands_sum_${TimeStamp}.TXT
rm -f $DATA_HOME/sum*.*

cat $SRC_HOME/inv_header.txt $DATA_HOME/inventory.txt > $DATA_HOME/inventory_out.txt
cat $DATA_HOME/inventory_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_di_Inventory_${TimeStamp}.TXT
rm -f $DATA_HOME/inventory*.*

cat $SRC_HOME/cat1_header.txt $DATA_HOME/cat1.txt > $DATA_HOME/cat1_out.txt
cat $DATA_HOME/cat1_out.txt | grep -v "rows selected." > $DATA_HOME/AMDII_2a_cat1_${TimeStamp}.TXT
rm -f $DATA_HOME/cat1*.*

cat $SRC_HOME/nins_header.txt $DATA_HOME/nins.txt > $DATA_HOME/nins_out.txt
cat $DATA_HOME/nins_out.txt | grep -v "rows selected." > $DATA_HOME/FedLog_Active_NINS_${TimeStamp}.TXT
rm -f $DATA_HOME/nins*.*

cat $SRC_HOME/ramp_header.txt $DATA_HOME/ramp.txt > $DATA_HOME/ramp_out.txt
cat $DATA_HOME/ramp_out.txt | grep -v "rows selected." >$DATA_HOME/BSSM_2f_RAMP_${TimeStamp}.TXT
rm -f $DATA_HOME/ramp*.*

cat $SRC_HOME/ord1d_header.txt $DATA_HOME/ord1d.txt > $DATA_HOME/ord1d_out.txt
cat $DATA_HOME/ord1d_out.txt | grep -v "rows selected." >$DATA_HOME/PULL_ORD1_D_${TimeStamp}.TXT
rm -f $DATA_HOME/ord1d*.*

cat $SRC_HOME/ord1_header.txt $DATA_HOME/ord1.txt > $DATA_HOME/ord1_out.txt
cat $DATA_HOME/ord1_out.txt | grep -v "rows selected." >$DATA_HOME/PULL_ORD1_${TimeStamp}.TXT
rm -f $DATA_HOME/ord1*.*

cat $SRC_HOME/sumsran_header.txt $DATA_HOME/sranconv.txt > $DATA_HOME/sranconv_out.txt
cat $DATA_HOME/sranconv_out.txt | grep -v "rows selected." >$DATA_HOME/AMDII_di_Demands_SRANS-Conv_${TimeStamp}.TXT
rm -f $DATA_HOME/sranconv*.*

cat $SRC_HOME/capability_header.txt $DATA_HOME/capability.txt > $DATA_HOME/capability_out.txt
cat $DATA_HOME/capability_out.txt | grep -v "rows selected." >$DATA_HOME/V_8_Capability-Requirement-Level-4_${TimeStamp}.TXT
rm -f $DATA_HOME/capability*.*

cat $SRC_HOME/repair_header.txt $DATA_HOME/repair.txt > $DATA_HOME/repair_out.txt
cat $DATA_HOME/repair_out.txt | grep -v "rows selected." >$DATA_HOME/AMDII_In-Repair_${TimeStamp}.TXT
rm -f $DATA_HOME/repair*.txt

cat $SRC_HOME/invsranconv_header.txt $DATA_HOME/invsranconv.txt > $DATA_HOME/invsranconv_out.txt
cat $DATA_HOME/invsranconv_out.txt | grep -v "rows selected." >$DATA_HOME/AMDII_di_Inventory_SRANS-Conv_${TimeStamp}.TXT
rm -f $DATA_HOME/invsranconv*.*

cat $SRC_HOME/rsp_header.txt $DATA_HOME/rsponhand.txt > $DATA_HOME/rsponhand_out.txt
cat $DATA_HOME/rsponhand_out.txt | grep -v "rows selected." >$DATA_HOME/RSP_On_Hand_and_Objective_${TimeStamp}.TXT
rm -f $DATA_HOME/rsponhand*.*

chmod 660 $DATA_HOME/*.TXT
