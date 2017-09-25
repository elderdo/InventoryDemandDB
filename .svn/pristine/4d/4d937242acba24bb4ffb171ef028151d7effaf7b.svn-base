/* Formatted on 4/18/2017 3:27:28 PM (QP5 v5.287) */
/* 
 AMDII_Part_Info_B.sql
 Rev:  1.0
 Date: 4/7/2017
 Author: Douglas Elder
 Desc: Create file Part_Info_B_$TimeStamp.TXT

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
       || 'AMDII_Part_Info_B_'
       || TO_CHAR (SYSDATE, 'yyyymmdd')
       || '.TXT'
          spoolname
  FROM DUAL;

SPOOL '&spoolname'


SELECT 'NSN' || CHR (9) || 'NOMENCLATURE'
  FROM DUAL;

SELECT NSN || CHR (9) || NOMENCLATURE
  FROM AMDII_PART_INFO_B_V;



SPOOL OFF

QUIT
