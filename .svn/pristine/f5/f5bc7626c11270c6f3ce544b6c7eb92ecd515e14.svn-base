/* 
 BSSM_2f_RAMP.sql
 Rev:  1.0
 Date: 4/7/2017
 Author: Douglas Elder
 Desc: Create file BSSM_2f_RAMP_$TimeStamp.TXT

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

DEFINE data_dir = &1 "AMD\AMDD\data"


COL spoolname NEW_VALUE spoolname

SELECT    CASE
             WHEN USER = 'BSRM_LOADER' and '&data_dir' = 'AMD\AMDD\data'
             THEN
                '/apps/CRON/AMD/data/'
             WHEN USER = 'BSRM_LOADER' and '&data_dir' <> 'AMD\AMDD\data'
             THEN
                '/apps/CRON/AMD/&data_dir./'
             WHEN USER IN ('AMD_OWNER', 'ZF297A')
             THEN
                'C:\Users\zf297a\Documents\&data_dir.\'
             ELSE
                'C:\Users\' || USER || '\Documents\'
          END
       || 'BSSM_2f_RAMP_'
       || TO_CHAR (SYSDATE, 'yyyymmdd')
       || '.TXT'
          spoolname
  FROM DUAL;

SPOOL '&spoolname'


SELECT    'NSN'
       || CHR (9)
       || 'SRAN'
       || CHR (9)
       || 'PERCENT BASE REPAIR'
       || CHR (9)
       || 'PERCENT BASE CONDEMN'
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
  FROM bssm_2f_ramp_V;



SPOOL OFF

QUIT
