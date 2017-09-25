/* 
   $Author:   c970183  $
 $Revision:   1.1  $
     $Date:   06 Aug 2004 13:59:20  $
 $Workfile:   tmp_amd_in_repair.sql  $
      $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_amd_in_repair.sql-arc  $
/*   
/*      Rev 1.1   06 Aug 2004 13:59:20   c970183
/*   Removed repair_type 

*/

CREATE TABLE TMP_AMD_IN_REPAIR
(
  PART_NO         VARCHAR2(50 BYTE)             NOT NULL,
  LOC_SID         NUMBER                        NOT NULL,
  REPAIR_DATE     DATE                          NOT NULL,
  REPAIR_QTY      NUMBER                        NOT NULL,
  ORDER_SID       NUMBER,
  ACTION_CODE     VARCHAR2(1 BYTE)              NOT NULL,
  LAST_UPDATE_DT  DATE                          NOT NULL
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


CREATE UNIQUE INDEX TMP_AMD_IN_REPAIR_PK ON TMP_AMD_IN_REPAIR
(PART_NO, LOC_SID, REPAIR_DATE)
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


CREATE PUBLIC SYNONYM TMP_AMD_IN_REPAIR FOR TMP_AMD_IN_REPAIR;


ALTER TABLE TMP_AMD_IN_REPAIR ADD (
  CONSTRAINT TMP_AMD_IN_REPAIR_PK PRIMARY KEY (PART_NO, LOC_SID, REPAIR_DATE)
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


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_IN_REPAIR TO BSRM_LOADER;

