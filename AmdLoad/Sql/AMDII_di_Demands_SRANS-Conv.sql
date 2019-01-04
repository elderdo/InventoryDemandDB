/* 
 AMDII_di_Demands_SRANS-Conv.sql
 Rev:  1.0
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file AMDII_di_Demands_SRANS-Conv_$TimeStamp.TXT
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

DEFINE spoolname = &1 "AMDII_di_Demands_SRANS-Conv.TXT"

SPOOL '&spoolname'

SELECT 'NSN' || CHR (9) || 'SRAN' || CHR (9) || 'DATE' || CHR (9) || 'DEMAND'
  FROM DUAL;

SELECT nsn || CHR (9) || sran || CHR (9) || doc_date || CHR (9) || demand
  FROM AMDII_DI_DEMANDS_SRANS_CONV_V
  ORDER BY 1;

SPOOL OFF

QUIT
