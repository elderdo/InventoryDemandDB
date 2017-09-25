/* 
 AMDII_Part_Info2.sql
 Rev:  1.0
 Date: 4/7/2017
 Author: Douglas Elder
 Desc: Create file AMDII_Part_Info2_$TimeStamp.TXT

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
       || 'AMDII_Part_Info2_'
       || TO_CHAR (SYSDATE, 'yyyymmdd')
       || '.TXT'
          spoolname
  FROM DUAL;

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
  FROM AMDII_PART_INFO2_V;



SPOOL OFF

QUIT
