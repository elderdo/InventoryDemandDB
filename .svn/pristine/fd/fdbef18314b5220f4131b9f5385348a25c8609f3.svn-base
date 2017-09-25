/* 
 AMDII_di_Demands_SRANS-Conv.sql
 Rev:  1.0
 Date: 4/7/2017
 Author: Douglas Elder
 Desc: Create file AMDII_di_Demands_SRANS-Conv_$TimeStamp.TXT

**/
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET LINESIZE 32767
SET TERMOUT OFF
SET VERIFY OFF

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
                'C:\Users\zf297a\Documents\AMD\AMDD\data\'
             ELSE
                'C:\Users\' || USER || '\Documents\'
          END
       || 'AMDII_di_Demands_SRANS-Conv_'
       || TO_CHAR (SYSDATE, 'yyyymmdd')
       || '.TXT'
          spoolname
  FROM DUAL;


SPOOL '&spoolname'


SELECT 'NSN' || CHR (9) || 'SRAN' || CHR (9) || 'DATE' || CHR (9) || 'DEMAND'
  FROM DUAL;


SELECT nsn || CHR (9) || sran || CHR (9) || doc_date || CHR (9) || demand
  FROM AMDII_DI_DEMANDS_SRANS_CONV_V;

SPOOL OFF

QUIT
