SET DEFINE OFF;
DROP PUBLIC SYNONYM ITEMSA;

CREATE PUBLIC SYNONYM ITEMSA FOR AMD_OWNER.ITEMSA;


DROP MATERIALIZED VIEW AMD_OWNER.ITEMSA;
CREATE MATERIALIZED VIEW AMD_OWNER.ITEMSA 
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
START WITH TO_DATE('21-Apr-2009 16:01:00','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48   
WITH ROWID
AS 
/* Formatted on 2009/04/21 15:32 (Formatter Plus v4.8.8) */
select TRIM (item_id) item_id, TRIM (received_item_id) received_item_id,
       TRIM (segregation_code) sc, TRIM (part) part,
       TRIM (prime_part_cage) prime, condition_code condition,
       bin_location location, status_del_when_gone, status_servicable,
       status_new_order, status_accountable, status_avail, status_frozen,
       status_active, status_mai, status_receiving_susp, status_2, status_3,
       last_changed_on last_changed_datetime, status_1,
       created_on created_datetime, vendor_code, quantity qty,
       TRIM (order_no) order_no, TRIM (receipt_order_no) receipt_order_no
  from item$merged@dgoldlb
 where status_1 != 'D'
   and condition_code not in ('LDD', 'B170-ATL')
   and segregation_code = 'C17PCAG';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.ITEMSA IS 'snapshot table for snapshot AMD_OWNER.ITEMSA';

GRANT SELECT ON AMD_OWNER.ITEMSA TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.ITEMSA TO AMD_WRITER_ROLE;

