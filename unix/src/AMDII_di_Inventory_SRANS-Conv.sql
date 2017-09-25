/* 
 AMDII_di_Inventory_SRANS-Conv.sql
 Rev:  1.0
 Date: 4/7/2017
 Author: Douglas Elder
 Desc: Create file AMDII_di_Inventory_SRANS-Conv_$TimeStamp.TXT

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
       || 'AMDII_di_Inventory_SRANS-Conv_'
       || TO_CHAR (SYSDATE, 'yyyymmdd')
       || '.TXT'
          spoolname
  FROM DUAL;

SPOOL '&spoolname'


SELECT 'NSN' || CHR (9) || 'SRAN' || CHR (9) || 'INVENTORY'
  FROM DUAL;

SELECT nsn || CHR (9) || sran || CHR (9) || inventory
  FROM AMDII_DI_INVENTORY_SRAN_CONV_V;



SPOOL OFF

QUIT
