/* 
 V_8_Capability-Requirement-Level-4.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file V_8_Capability-Requirement-Level-4_$TimeStamp.TXT
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

DEFINE spoolname = &1 "V_8_Capability-Requirement-Level-4.TXT"

SPOOL '&spoolname'

SELECT    'NSN'
       || CHR (9)
       || 'CAPABILITY REQUIREMENT'
  FROM DUAL;

SELECT    NSN
       || CHR (9)
       || Capability_requirement
  FROM V8_CAPABILITYREQUIREMENTLVL4_V
  ORDER BY 1;

SPOOL OFF

QUIT
