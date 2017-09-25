    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:42  $
     $Workfile:   ord1.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\ord1.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:42   c970183
/*   Initial revision.
*/

CREATE TABLE ORD1
(
  ORDER_NO                CHAR(20 BYTE)         NOT NULL,
  ORDER_TYPE              CHAR(1 BYTE),
  STEP                    CHAR(2 BYTE),
  MILSTRIP_PROCEDURE      CHAR(2 BYTE),
  SC                      CHAR(20 BYTE),
  PART                    CHAR(50 BYTE),
  STATUS                  CHAR(1 BYTE),
  AWO                     CHAR(50 BYTE),
  PO                      CHAR(20 BYTE),
  PO_LINE                 CHAR(6 BYTE),
  QTY_ORDERED             NUMBER(15,5),
  QTY_COMPLETED           NUMBER(15,5),
  QTY_DUE                 NUMBER(15,5),
  QTY_CANC                NUMBER(15,5),
  QTY_ADDED               NUMBER(15,5),
  QTY_ORIGINAL_ORDERED    NUMBER(15,5),
  QTY_SPLIT               NUMBER(15,5),
  UNIT_PRICE              NUMBER(15,5),
  REPLACED_BY_ORDER_NO    CHAR(20 BYTE),
  VENDOR_CODE             CHAR(20 BYTE),
  PRIORITY                NUMBER(2),
  MAKE_BUY_CODE           CHAR(1 BYTE),
  NEED_DATE               DATE,
  ECD                     DATE,
  DODAC                   CHAR(6 BYTE),
  FORM_PRINTED_DATETIME   DATE,
  WORKSTOPAGE_CODE        CHAR(1 BYTE),
  UM_ORDER_CODE           CHAR(3 BYTE),
  UM_ORDER_ISSUE_COUNT    NUMBER(15,5),
  UM_ORDER_CODE_COUNT     NUMBER(15,5),
  UM_ORDER_FACTOR         NUMBER(15,5),
  REMARKS                 CHAR(180 BYTE),
  QTY_PER_PACK            NUMBER(15,5),
  DELIVER_TO_LOCATION     CHAR(20 BYTE),
  INTERFACE_ACK_DATETIME  DATE,
  ORIGINAL_PRICE          NUMBER(15,5),
  REPAIR_TYPE             CHAR(20 BYTE),
  PCT_COMPLETE            NUMBER(3),
  LABOR_HRS               NUMBER(15,5),
  CREATED_DOCDATE         DATE,
  CREATED_DATETIME        DATE,
  PRIORITY_CHG_DATETIME   DATE,
  CREATED_USERID          CHAR(20 BYTE),
  REQUESTED_USERID        CHAR(20 BYTE),
  COMPLETED_DOCDATE       DATE,
  COMPLETED_DATETIME      DATE,
  COMPLETED_USERID        CHAR(20 BYTE),
  LAST_CHANGED_DATETIME   DATE,
  LAST_CHANGED_USERID     CHAR(20 BYTE),
  USER_REF1               CHAR(20 BYTE),
  USER_REF2               CHAR(20 BYTE),
  USER_REF3               CHAR(20 BYTE),
  USER_REF4               CHAR(20 BYTE),
  USER_REF5               CHAR(20 BYTE),
  USER_REF6               CHAR(20 BYTE),
  TOT_MAT_COST            NUMBER(15,5),
  PART_REQUESTED          CHAR(50 BYTE),
  BUYER                   CHAR(8 BYTE),
  TOP_ORDER_NO            CHAR(20 BYTE),
  NH_ORDER_NO             CHAR(20 BYTE),
  LVL                     NUMBER(2),
  WCHD_ID                 VARCHAR2(20 BYTE),
  ACCOUNTABLE_YN          CHAR(1 BYTE),
  SERIAL                  VARCHAR2(20 BYTE),
  CONDITION               VARCHAR2(20 BYTE),
  ORIGINAL_CONDITION      VARCHAR2(20 BYTE),
  LOT                     VARCHAR2(20 BYTE),
  KEY_REF                 VARCHAR2(20 BYTE),
  LOCATION                VARCHAR2(20 BYTE),
  ITEM_ID                 CHAR(20 BYTE),
  RECEIPT_VOUCHER         VARCHAR2(20 BYTE),
  REVIEWED_USERID         CHAR(20 BYTE),
  REVIEWED_DATETIME       DATE,
  PO_PRICE                NUMBER(15,5),
  ACTIVITY_CODE           VARCHAR2(20 BYTE),
  FURNISHED_BY            CHAR(3 BYTE),
  WPHD_ID                 CHAR(20 BYTE),
  ASSET_ID                CHAR(50 BYTE),
  DEFAULT_B               CHAR(1 BYTE),
  FROM_OUTSIDE            CHAR(1 BYTE),
  FUND_TYPE               CHAR(1 BYTE),
  ACTION_TAKEN            CHAR(1 BYTE),
  JOB_CONTROL_NUMBER      CHAR(30 BYTE),
  REMOVED_FROM            CHAR(30 BYTE),
  TYPE_MAINTENANCE        CHAR(30 BYTE),
  SRD                     CHAR(30 BYTE),
  WHEN_DISCOVERED         CHAR(1 BYTE),
  HOW_MAL                 CHAR(3 BYTE),
  REF_DES                 CHAR(50 BYTE),
  SUPPLY_DOCUMENT         CHAR(30 BYTE),
  DISCREPANCY             CHAR(250 BYTE),
  TCN                     CHAR(30 BYTE),
  ORIGINAL_LOCATION       CHAR(20 BYTE),
  TRAN_ID_IN              CHAR(20 BYTE),
  TRAN_ID_OUT             CHAR(20 BYTE),
  TO_PART_NUMBER          CHAR(50 BYTE),
  DEFAULT_ID              CHAR(20 BYTE),
  PO_SEQ                  NUMBER(8),
  WIP_DATETIME            DATE,
  WIP_STATUS              CHAR(20 BYTE),
  CORRECTIVE_ACTION       CHAR(250 BYTE),
  CONTAINER_Y             CHAR(1 BYTE),
  CONTAINER_N             CHAR(1 BYTE),
  CONTAINER_W             CHAR(1 BYTE),
  CONTAINER_WAIVER        CHAR(20 BYTE),
  CURR_JDD1_ID            VARCHAR2(20 BYTE),
  DJHD_NAME               VARCHAR2(20 BYTE),
  DEFAULT_ORDER           VARCHAR2(20 BYTE),
  MASTER_FORM_TYPE        VARCHAR2(8 BYTE),
  RECURRENCE              NUMBER(8),
  JOB_PROFILE_TYPE        VARCHAR2(7 BYTE),
  JCN_DAY                 VARCHAR2(3 BYTE),
  JCN_ORG                 VARCHAR2(4 BYTE),
  JCN_SER                 VARCHAR2(4 BYTE),
  JCN_SUF                 VARCHAR2(2 BYTE),
  EQUIP_ID                VARCHAR2(20 BYTE),
  MISSION_CAPABILITY      VARCHAR2(5 BYTE),
  STATUS_FROZEN           VARCHAR2(1 BYTE),
  ORDER_PRICE_B           CHAR(1 BYTE),
  NHA_PART                VARCHAR2(50 BYTE),
  MILS_SOURCE_DIC         VARCHAR2(20 BYTE),
  MILS_RECEIPT_SUFFIX     VARCHAR2(1 BYTE),
  DIRECT_SHIP_B           CHAR(1 BYTE),
  ECD_CALC_HLDR           NUMBER(15,5)
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


CREATE INDEX ORD1_PART_INDEX ON ORD1
(PART)
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


CREATE INDEX ORD1_ORDER_TYPE_INDEX ON ORD1
(ORDER_TYPE)
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


CREATE UNIQUE INDEX ORD1P1 ON ORD1
(ORDER_NO)
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


CREATE PUBLIC SYNONYM ORD1 FOR ORD1;


ALTER TABLE ORD1 ADD (
  CHECK ("ORDER_TYPE" IS NOT NULL) DISABLE);

ALTER TABLE ORD1 ADD (
  CHECK ("SC" IS NOT NULL) DISABLE);

ALTER TABLE ORD1 ADD (
  CHECK ("PART" IS NOT NULL) DISABLE);

ALTER TABLE ORD1 ADD (
  CONSTRAINT ORD1P1 PRIMARY KEY (ORDER_NO)
    USING INDEX 
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
               ));


GRANT SELECT ON  ORD1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  ORD1 TO AMD_WRITER_ROLE;


