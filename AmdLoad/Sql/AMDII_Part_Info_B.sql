/* 
 AMDII_Part_Info_B.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file Part_Info_B_$TimeStamp.TXT
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

DEFINE spoolname = &1 "AMDII_Part_Info_B.TXT"

SPOOL '&spoolname'

SELECT 'NSN' || CHR (9) || 'NOMENCLATURE'
  FROM DUAL;

SELECT NSN || CHR (9) || NOMENCLATURE
  FROM AMDII_PART_INFO_B_V
  ORDER BY 1;

SPOOL OFF

QUIT
