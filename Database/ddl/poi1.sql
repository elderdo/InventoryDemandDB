    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:42  $
     $Workfile:   poi1.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\poi1.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:42   c970183
/*   Initial revision.
*/

CREATE TABLE POI1
(
  ORDER_NO            CHAR(20 BYTE)             NOT NULL,
  SEQ                 NUMBER(20)                NOT NULL,
  ITEM                CHAR(5 BYTE)              NOT NULL,
  QTY                 NUMBER(15,5),
  UM                  CHAR(3 BYTE),
  PART                CHAR(50 BYTE),
  NOUN                CHAR(25 BYTE),
  UNIT_PRICE          NUMBER(15,5),
  EXT_PRICE           NUMBER(15,5),
  FUND_TYPE           CHAR(20 BYTE),
  DELIVERY_DATE       DATE,
  PRIORITY            CHAR(20 BYTE),
  CONTRACT_NUMBER     CHAR(20 BYTE),
  CCN                 CHAR(20 BYTE),
  DISCREPANCY_DATA    VARCHAR2(300 BYTE),
  INVOICE_NO          CHAR(20 BYTE),
  INVOICE_DATE        DATE,
  INVOICE_USERID      CHAR(20 BYTE),
  INTERFACE_DATETIME  DATE,
  ITEM_LINE           CHAR(5 BYTE),
  DO_NOT_INVOICE      CHAR(1 BYTE),
  SC                  VARCHAR2(20 BYTE),
  NEED_DATE           DATE,
  QTY_RECEIVED        NUMBER(15,5),
  OVERRIDE_B          CHAR(1 BYTE)
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


CREATE UNIQUE INDEX POI1P1 ON POI1
(ORDER_NO, SEQ, ITEM)
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


CREATE INDEX POI1_PART_INDEX ON POI1
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


CREATE PUBLIC SYNONYM POI1 FOR POI1;


ALTER TABLE POI1 ADD (
  CHECK ("QTY" IS NOT NULL) DISABLE);

ALTER TABLE POI1 ADD (
  CHECK ("ITEM_LINE" IS NOT NULL) DISABLE);

ALTER TABLE POI1 ADD (
  CONSTRAINT POI1P1 PRIMARY KEY (ORDER_NO, SEQ, ITEM)
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


GRANT SELECT ON  POI1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  POI1 TO AMD_WRITER_ROLE;


