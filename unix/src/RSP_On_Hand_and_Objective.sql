/* 
 RSP_On_Hand_and_Objective.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file RSP_On_Hand_and_Objective_$TimeStamp.TXT
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

DEFINE spoolname = &1 "RSP_On_Hand_and_Objective.TXT"

SPOOL '&spoolname'

SELECT    'NSN'
       || CHR (9)
       || 'SRAN'
       || CHR (9)
       || 'RSP_ON_HAND'
       || CHR(9)
       || 'RSP_OBJECTIVE'
  FROM DUAL;

SELECT    nsn
       || CHR (9)
       || sran
       || CHR (9)
       || rsp_on_hand
       || CHR (9)
       || rsp_objective
  FROM amd_rsp_on_hand_n_objective_v
  ORDER BY 1;

SPOOL OFF

QUIT
