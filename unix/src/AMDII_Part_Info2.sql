/* 
 AMDII_Part_Info2.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file AMDII_Part_Info2_$TimeStamp.TXT
 Rev 1.0 4/7/2017 initial rev
 Rev 1.1 5/19/2017 simplified spoolname and added order by

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

DEFINE spoolname = &1 "AMDII_Part_Info2.TXT"

SPOOL '&spoolname'

SELECT    'NSN'
       || CHR (9)
       || 'SRAN'
       || CHR (9)
       || 'RSP ON HAND'
       || CHR (9)
       || 'RSP OBJECTIVE'
  FROM DUAL;

SELECT    NSN
       || CHR (9)
       || SRAN
       || CHR (9)
       || RSP_ON_HAND
       || CHR (9)
       || RSP_OBJECTIVE
  FROM AMDII_PART_INFO2_V
  ORDER BY 1;

SPOOL OFF

QUIT
