/*
   	  $Author:   c970183  $
	$Revision:   1.0  $
	    $Date:   02 Aug 2004 12:06:22  $
	$Workfile:   amd_a2a_on_order.sql  $
	     $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_a2a_on_order.sql-arc  $
/*   
/*      Rev 1.0   02 Aug 2004 12:06:22   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_A2A_ON_ORDER
(
  PART_NO             VARCHAR2(50 BYTE)         NOT NULL,
  LOC_SID             NUMBER                    NOT NULL,
  SCHED_RECEIPT_DATE  DATE                      NOT NULL,
  ORDER_QTY           NUMBER                    NOT NULL,
  GOLD_ORDER_NUMBER   VARCHAR2(20 BYTE),
  ACTION_CODE         VARCHAR2(1 BYTE)          NOT NULL,
  LAST_UPDATE_DT      DATE                      NOT NULL
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


CREATE UNIQUE INDEX TMP_A2A_ON_ORDER_PK ON TMP_A2A_ON_ORDER
(GOLD_ORDER_NUMBER)
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


CREATE PUBLIC SYNONYM TMP_A2A_ON_ORDER FOR TMP_A2A_ON_ORDER;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_A2A_ON_ORDER TO BSRM_LOADER;
