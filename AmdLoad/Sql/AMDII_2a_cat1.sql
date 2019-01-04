/* 
 AMDII_2a_cat1.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file AMDII_2a_cat1_$TimeStamp.TXT
 Rev:  1.0 4/7/2017 initial rev
 Rev:  1.1 5/19/2017 simplified spoolname and added order by

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

DEFINE spoolname = &1 "AMDII_2a_cat1.TXT"

SPOOL '&spoolname'

SELECT    'NSN'
       || CHR (9)
       || 'PART NO'
       || CHR (9)
       || 'PRIME PART NO'
       || CHR (9)
       || 'ITEM TYPE'
       || CHR (9)
       || 'SMR CODE'
  FROM DUAL;

SELECT    NSN
       || CHR (9)
       || PART_NO
       || CHR (9)
       || PRIME_PART_NO
       || CHR (9)
       || ITEM_TYPE
       || CHR (9)
       || SMR_CODE
  FROM AMDII_2A_CAT1_V
  ORDER BY 1;

SPOOL OFF

QUIT
