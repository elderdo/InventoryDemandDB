SET DEFINE OFF;
DROP PUBLIC SYNONYM ITEM;

CREATE PUBLIC SYNONYM ITEM FOR AMD_OWNER.ITEM;


DROP MATERIALIZED VIEW AMD_OWNER.ITEM;
CREATE MATERIALIZED VIEW AMD_OWNER.ITEM 
TABLESPACE AMD_DATA
PCTUSED    40
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
USING INDEX
            TABLESPACE AMD_INDEX
            PCTFREE    10
            INITRANS   2
            MAXTRANS   255
            STORAGE    (
                        INITIAL          64K
                        MINEXTENTS       1
                        MAXEXTENTS       UNLIMITED
                        PCTINCREASE      0
                        FREELISTS        1
                        FREELIST GROUPS  1
                        BUFFER_POOL      DEFAULT
                       )
REFRESH COMPLETE
START WITH TO_DATE('21-Apr-2009 15:43:03','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48   
WITH ROWID
AS 
/* Formatted on 2009/04/21 15:18 (Formatter Plus v4.8.8) */
select TRIM (item_id) item_id, TRIM (received_item_id) received_item_id,
       TRIM (segregation_code) sc, TRIM (part) part,
       TRIM (prime_part_cage) prime, TRIM (condition_code) condition,
       status_del_when_gone, status_servicable, status_new_order,
       status_accountable, status_avail, status_frozen, status_active,
       status_mai, status_receiving_susp, status_2, status_3,
       last_changed_on last_changed_datetime, status_1,
       created_on created_datetime, TRIM (vendor_code) vendor_code,
       quantity qty, TRIM (order_no) order_no,
       TRIM (receipt_order_no) receipt_order_no
  from item$merged@dgoldlb
 where status_1 != 'D' and condition_code not in ('LDD');

COMMENT ON MATERIALIZED VIEW AMD_OWNER.ITEM IS 'snapshot table for snapshot AMD_OWNER.ITEM';

CREATE INDEX AMD_OWNER.ITEMI7 ON AMD_OWNER.ITEM
(PART, STATUS_AVAIL)
LOGGING
TABLESPACE AMD_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE INDEX AMD_OWNER.ITEMI8 ON AMD_OWNER.ITEM
(PRIME, PART, CONDITION)
LOGGING
TABLESPACE AMD_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE UNIQUE INDEX AMD_OWNER.ITEMP1 ON AMD_OWNER.ITEM
(ITEM_ID)
LOGGING
TABLESPACE AMD_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

GRANT SELECT ON AMD_OWNER.ITEM TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.ITEM TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.ITEM TO WIR_AMD_IF_ROLE;

