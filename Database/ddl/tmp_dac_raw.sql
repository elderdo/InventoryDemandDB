    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:54:00  $
     $Workfile:   tmp_dac_raw.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_dac_raw.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:54:00   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_DAC_RAW
(
  DIC                 VARCHAR2(6 BYTE),
  TTPC                VARCHAR2(6 BYTE),
  REASON              VARCHAR2(10 BYTE),
  DIC_A               VARCHAR2(6 BYTE),
  RI                  VARCHAR2(6 BYTE),
  F1                  VARCHAR2(10 BYTE),
  STOCK_NO            VARCHAR2(20 BYTE),
  MMC                 VARCHAR2(4 BYTE),
  UI                  VARCHAR2(6 BYTE),
  ACTION_QTY          NUMBER,
  DOC_NO              VARCHAR2(20 BYTE),
  F2                  VARCHAR2(10 BYTE),
  REPAIR_CYCLE        NUMBER,
  F3                  VARCHAR2(10 BYTE),
  F4                  VARCHAR2(10 BYTE),
  TYPE_ACCOUNT_CODE   VARCHAR2(6 BYTE),
  F5                  VARCHAR2(10 BYTE),
  REPAIR_ACTIVITY     VARCHAR2(10 BYTE),
  WUC                 VARCHAR2(9 BYTE),
  O_P_CODE            VARCHAR2(6 BYTE),
  CONDITION_CODE      VARCHAR2(6 BYTE),
  SRAN                VARCHAR2(6 BYTE),
  O_P_CODE_2          VARCHAR2(6 BYTE),
  CONDITION_CODE_2    VARCHAR2(6 BYTE),
  F6                  VARCHAR2(10 BYTE),
  DATE_PROCESSED      NUMBER,
  MX_ATC              VARCHAR2(6 BYTE),
  SUPPLY_DEMAND_CODE  VARCHAR2(4 BYTE),
  STD_RPTG_DESIG      VARCHAR2(6 BYTE),
  F7                  VARCHAR2(10 BYTE),
  TRANS_DATE          DATE,
  NSN                 VARCHAR2(16 BYTE)
)
TABLESPACE AMD_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCACHE
NOPARALLEL;


CREATE INDEX TMP_DAC_RAW_FK1 ON TMP_DAC_RAW
(NSN)
LOGGING
TABLESPACE AMD_NDX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE PUBLIC SYNONYM TMP_DAC_RAW FOR TMP_DAC_RAW;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_DAC_RAW TO AMD_DATALOAD;

GRANT SELECT ON  TMP_DAC_RAW TO AMD_MAINT;

GRANT SELECT ON  TMP_DAC_RAW TO AMD_USER;

GRANT SELECT ON  TMP_DAC_RAW TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_DAC_RAW TO AMD_WRITER_ROLE;


