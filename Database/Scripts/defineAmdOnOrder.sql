/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   26 Jan 2007 14:30:56  $
    $Workfile:   defineAmdOnOrder.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\defineAmdOnOrder.sql.-arc  $
/*   
/*      Rev 1.1   26 Jan 2007 14:30:56   zf297a
/*   added sqlplus "set define off" command
/*   
/*      Rev 1.0   26 Jan 2007 11:47:10   zf297a
/*   Initial revision.
*/

set define off

ALTER TABLE AMD_ON_ORDER
 DROP PRIMARY KEY CASCADE;
DROP TABLE AMD_ON_ORDER CASCADE CONSTRAINTS;

CREATE TABLE AMD_ON_ORDER
(
  PART_NO             VARCHAR2(50 BYTE)         NOT NULL,
  LOC_SID             NUMBER                    NOT NULL,
  LINE                NUMBER			NOT NULL,
  ORDER_DATE          DATE,
  ORDER_QTY           NUMBER                    NOT NULL,
  GOLD_ORDER_NUMBER   VARCHAR2(20 BYTE),
  ACTION_CODE         VARCHAR2(1 BYTE)          NOT NULL,
  LAST_UPDATE_DT      DATE                      NOT NULL,
  SCHED_RECEIPT_DATE  DATE
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
NOCOMPRESS 
NOCACHE
NOPARALLEL
NOMONITORING;


CREATE UNIQUE INDEX AMD_ON_ORDER_PK ON AMD_ON_ORDER
(GOLD_ORDER_NUMBER, ORDER_DATE, LINE)
LOGGING
TABLESPACE AMD_INDEX
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


CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_ON_ORDER_BEF_INS_TRIG
BEFORE INSERT
ON AMD_OWNER.AMD_ON_ORDER REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   26 Jan 2007 14:30:56  $
    $Workfile:   defineAmdOnOrder.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_ON_ORDER_BEF_INS_TRIG.trg.-arc  $
/*
/*      Rev 1.0   22 Jan 2007 10:35:22   zf297a
/*   Initial revision.
*/
maxLine NUMBER;
BEGIN

   select max(line) into maxLine
   from amd_on_order
   where gold_order_number = :NEW.gold_order_number ;
   if maxLine is null then
        maxLine := 0 ;
   end if ;

   :NEW.line := maxLine + 1 ;

END AMD_ON_ORDER_BEF_TRIG;
/

SHOW ERRORS;

whenever sqlerror continue

DROP PUBLIC SYNONYM AMD_ON_ORDER;

CREATE PUBLIC SYNONYM AMD_ON_ORDER FOR AMD_ON_ORDER;


ALTER TABLE AMD_ON_ORDER ADD (
  PRIMARY KEY
 (GOLD_ORDER_NUMBER, ORDER_DATE, LINE)
    USING INDEX 
    TABLESPACE AMD_INDEX
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


GRANT SELECT ON  AMD_ON_ORDER TO AMD_READER_ROLE;

GRANT DELETE, INSERT, UPDATE ON  AMD_ON_ORDER TO AMD_WRITER_ROLE;

