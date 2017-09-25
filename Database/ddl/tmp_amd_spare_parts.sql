    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:58  $
     $Workfile:   tmp_amd_spare_parts.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_amd_spare_parts.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:58   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_AMD_SPARE_PARTS
(
  PART_NO                  VARCHAR2(50 BYTE)    NOT NULL,
  MFGR                     VARCHAR2(13 BYTE),
  DATE_ICP                 DATE,
  DISPOSAL_COST            NUMBER,
  ERC                      VARCHAR2(1 BYTE),
  ICP_IND                  VARCHAR2(3 BYTE)     NOT NULL,
  ITEM_TYPE                VARCHAR2(1 BYTE),
  NOMENCLATURE             VARCHAR2(512 BYTE)   NOT NULL,
  NSN                      VARCHAR2(15 BYTE),
  NSN_TYPE                 VARCHAR2(1 BYTE),
  ORDER_LEAD_TIME          NUMBER,
  ORDER_QUANTITY           NUMBER,
  ORDER_UOM                VARCHAR2(2 BYTE),
  PLANNER_CODE             VARCHAR2(8 BYTE),
  PRIME_IND                VARCHAR2(1 BYTE),
  SCRAP_VALUE              NUMBER,
  SERIAL_FLAG              VARCHAR2(1 BYTE),
  SHELF_LIFE               NUMBER,
  SMR_CODE                 VARCHAR2(6 BYTE),
  ACQUISITION_ADVICE_CODE  VARCHAR2(20 BYTE),
  UNIT_COST                NUMBER,
  UNIT_VOLUME              NUMBER,
  MIC                      VARCHAR2(1 BYTE),
  LAST_UPDATE_DT           DATE                 DEFAULT sysdate               NOT NULL,
  MMAC                     VARCHAR2(2 BYTE),
  UNIT_OF_ISSUE            VARCHAR2(2 BYTE)
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


CREATE INDEX TMPAMD_SPARE_PART_CAGE_I ON TMP_AMD_SPARE_PARTS
(PART_NO, MFGR)
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


CREATE INDEX TMPAMD_SPARE_PART_NSN_I ON TMP_AMD_SPARE_PARTS
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


CREATE PUBLIC SYNONYM TMP_AMD_SPARE_PARTS FOR TMP_AMD_SPARE_PARTS;


GRANT SELECT ON  TMP_AMD_SPARE_PARTS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_SPARE_PARTS TO AMD_WRITER_ROLE;


