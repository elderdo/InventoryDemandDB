/* 
 BSSM_2f_RAMP.sql
 Rev:  1.1
 Date: 5/19/2017
 Author: Douglas Elder
 Desc: Create file BSSM_2f_RAMP_$TimeStamp.TXT
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

DEFINE spoolname = &1 "BSSM_2f_RAMP.TXT"

SPOOL '&spoolname'

SELECT    'NSN'
       || CHR (9)
       || 'SRAN'
       || CHR (9)
       || 'PERCENT BASE REPAIR'
       || CHR (9)
       || 'PERCENT BASE CONDEM'
       || CHR (9)
       || 'DAILY DEMAND RATE'
       || CHR (9)
       || 'AVG REPAIR CYCLE TIME'
  FROM DUAL;

SELECT    NSN
       || CHR (9)
       || SRAN
       || CHR (9)
       || PERCENT_BASE_REPAIR
       || CHR (9)
       || PERCENT_BASE_CONDEMN
       || CHR (9)
       || DAILY_DEMAND_RATE
       || CHR (9)
       || AVG_REPAIR_CYCLE_TIME
  FROM bssm_2f_ramp_V
  ORDER BY 1;

SPOOL OFF

QUIT
