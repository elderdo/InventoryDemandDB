/*
  $Author:   c970183  $
$Revision:   1.1  $
    $Date:   May 20 2005 09:28:48  $
$Workfile:   amd_in_repair.sql  $
     $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_in_repair.sql-arc  $
/*   
/*      Rev 1.1   May 20 2005 09:28:48   c970183
/*   removed repair_type
/*   
/*      Rev 1.0   May 20 2005 09:27:44   c970183
/*   Initial revision.
*/


CREATE TABLE AMD_IN_REPAIR
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


CREATE UNIQUE INDEX AMD_IN_REPAIR_PK ON AMD_IN_REPAIR
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


CREATE PUBLIC SYNONYM AMD_IN_REPAIR FOR AMD_IN_REPAIR;


ALTER TABLE AMD_IN_REPAIR ADD (
  CONSTRAINT AMD_IN_REPAIR_PK PRIMARY KEY (PART_NO, LOC_SID, REPAIR_DATE)
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


ALTER TABLE AMD_IN_REPAIR ADD (
  CONSTRAINT AMD_IN_REPAIR_FK01 FOREIGN KEY (PART_NO) 
    REFERENCES AMD_SPARE_PARTS (PART_NO));

ALTER TABLE AMD_IN_REPAIR ADD (
  CONSTRAINT AMD_IN_REPAIR_FK02 FOREIGN KEY (LOC_SID) 
    REFERENCES AMD_SPARE_NETWORKS (LOC_SID));


GRANT SELECT ON  AMD_IN_REPAIR TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_IN_REPAIR TO AMD_WRITER_ROLE;


