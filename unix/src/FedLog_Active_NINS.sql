/* 
 FedLog_Active_NINS.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file FedLog_Active_NINS_$TimeStamp.TXT
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

DEFINE spoolname = &1 "FedLog_Active_NINS.TXT"

SPOOL '&spoolname'

SELECT 'NIN' FROM DUAL;

SELECT NIN FROM FEDLOG_ACTIVE_NIINS_V
ORDER BY 1;

SPOOL OFF

QUIT
