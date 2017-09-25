/*
   	  $Author:   c970183  $
	$Revision:   1.3  $
	    $Date:   02 Aug 2004 12:12:22  $
	$Workfile:   tmp_a2a_parts.sql  $
	     $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_a2a_parts.sql-arc  $
/*   
/*      Rev 1.3   02 Aug 2004 12:12:22   c970183
/*   added synonym and grant statement
/*   
/*      Rev 1.2   02 Aug 2004 12:10:10   c970183
/*   added pvcs keywords
*/
CREATE TABLE TMP_A2A_PARTS
(
  SOURCE_SYSTEM             VARCHAR2(20 BYTE),
  CAGE_CODE                 VARCHAR2(5 BYTE),
  PART_NO                   VARCHAR2(50 BYTE)   NOT NULL,
  UNIT_ISSUE                VARCHAR2(2 BYTE),
  NOUN                      VARCHAR2(50 BYTE),
  RCM_IND                   VARCHAR2(1 BYTE),
  HAZMAT_CODE               VARCHAR2(1 BYTE),
  SHELF_LIFE                VARCHAR2(3 BYTE),
  EQUIPMENT_TYPE            VARCHAR2(1 BYTE),
  NSN_COG                   VARCHAR2(2 BYTE),
  NSN_MCC                   VARCHAR2(1 BYTE),
  NSN_FSC                   VARCHAR2(4 BYTE),
  NSN_NIIN                  VARCHAR2(9 BYTE),
  NSN_SMIC_MMAC             VARCHAR2(2 BYTE),
  NSN_ACTY                  VARCHAR2(2 BYTE),
  ESSENTIALITY_CODE         VARCHAR2(20 BYTE),
  RESP_ASSET_MGR            VARCHAR2(20 BYTE),
  UNIT_PACK_CUBE            VARCHAR2(10 BYTE),
  UNIT_PACK_QTY             VARCHAR2(20 BYTE),
  UNIT_PACK_WEIGHT          VARCHAR2(9 BYTE),
  UNIT_PACK_WEIGHT_MEASUR   VARCHAR2(10 BYTE),
  ELECTRO_STATIC_DISCHARGE  VARCHAR2(1 BYTE),
  PERF_BASED_LOG_INFO       VARCHAR2(20 BYTE),
  PLANNED_PART              VARCHAR2(1 BYTE),
  THIRD_PARTY_FLAG          VARCHAR2(1 BYTE),
  MTBF                      VARCHAR2(9 BYTE),
  MTBF_TYPE                 VARCHAR2(32 BYTE),
  SHELF_LIFE_ACTION_CODE    VARCHAR2(2 BYTE),
  PREFERRED_SMRCODE         VARCHAR2(6 BYTE),
  DECAY_RATE                VARCHAR2(10 BYTE),
  PRIME_CAGE                VARCHAR2(5 BYTE),
  PRIME_PART                VARCHAR2(50 BYTE),
  LEAD_TIME                 NUMBER,
  LEAD_TIME_TYPE            VARCHAR2(20 BYTE),
  PRICE_TYPE                VARCHAR2(20 BYTE),
  PRICE                     NUMBER,
  PRICE_FISCAL_YEAR         VARCHAR2(4 BYTE),
  INDENTURE                 VARCHAR2(2 BYTE),
  AVAILABILITY_FLAG         VARCHAR2(1 BYTE),
  LAST_UPDATE_DT            DATE                DEFAULT sysdate               NOT NULL,
  ACTION_CODE               VARCHAR2(1 BYTE)
)
TABLESPACE AMD_INDEX
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


CREATE PUBLIC SYNONYM TMP_A2A_PARTS FOR TMP_A2A_PARTS;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_A2A_PARTS TO BSRM_LOADER;

