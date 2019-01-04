/* 
 AMDII_Part_Info_A.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file AMDII_Part_Info_A_$TimeStamp.TXT
 Rev:  1.0 4/7/2017 initial rev
 Rev:  1.1 5/19/2017 DSE simplified spoolname and added order by

**/
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET LINESIZE 32767
SET TERMOUT OFF
SET VERIFY OFF

COLUMN 1 NEW_VALUE 1 NOPRINT

SELECT '' "1"
  FROM DUAL
 WHERE ROWNUM = 0;

DEFINE spoolname = &1 "AMDII_Part_Info_A.TXT"

SPOOL '&spoolname'

SELECT    'NSN'
       || CHR (9)
       || 'MIC'
       || CHR (9)
       || 'PLANNER CODE'
       || CHR (9)
       || 'SMR CODE'
       || CHR (9)
       || 'MTBDR'
       || CHR (9)
       || 'MMAC'
       || CHR (9)
       || 'PART NO'
       || CHR (9)
       || 'MFGR'
       || CHR (9)
       || 'ORDER LEAD TIME'
       || CHR (9)
       || 'ORDER UOM'
       || CHR (9)
       || 'UNIT_OF_ISSUE'
       || CHR (9)
       || 'UNIT COST'
       || CHR (9)
       || 'ACQUISITION ADVICE CODE'
       || CHR (9)
       || 'CURRENT_BACKORDER'
  FROM DUAL;

SELECT    NSN
       || CHR (9)
       || MIC
       || CHR (9)
       || PLANNER_CODE
       || CHR (9)
       || SMR_CODE
       || CHR (9)
       || MTBDR
       || CHR (9)
       || MMAC
       || CHR (9)
       || PART_NO
       || CHR (9)
       || MFGR
       || CHR (9)
       || ORDER_LEAD_TIME
       || CHR (9)
       || ORDER_UOM
       || CHR (9)
       || UNIT_OF_ISSUE
       || CHR (9)
       || UNIT_COST
       || CHR (9)
       || ACQUISITION_ADVICE_CODE
       || CHR (9)
       || CURRENT_BACKORDER
  FROM AMDII_PART_INFO_A_V
  ORDER BY 1;

SPOOL OFF

QUIT
