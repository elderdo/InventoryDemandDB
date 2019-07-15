/* 
 PULL_ORD1.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file PULL_ORD1_$TimeStamp.TXT
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

DEFINE spoolname = &1 "PULL_ORD1.TXT"

SPOOL '&spoolname'

SELECT    'PN'
       || CHR (9)
       || 'FINISH DATE'
       || CHR (9)
       || 'START DATE'
       || CHR (9)
       || 'ACTION TAKEN'
  FROM DUAL;

SELECT    PN
       || CHR (9)
       || FINISH_DATE
       || CHR (9)
       || START_DATE
       || CHR (9)
       || ACTION_TAKEN
  FROM PULL_ORD1_V
  ORDER BY 1;

SPOOL OFF

QUIT
