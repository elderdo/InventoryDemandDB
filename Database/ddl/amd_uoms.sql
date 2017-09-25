    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:34  $
     $Workfile:   amd_uoms.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_uoms.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:34   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_UOMS
(
  UOM_CODE  VARCHAR2(2 BYTE)                    NOT NULL,
  UOM_TERM  VARCHAR2(30 BYTE)
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


CREATE UNIQUE INDEX AMD_UOMS_PK ON AMD_UOMS
(UOM_CODE)
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


CREATE UNIQUE INDEX AMD_UOMS_UC01 ON AMD_UOMS
(UOM_TERM)
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


CREATE PUBLIC SYNONYM AMD_UOMS FOR AMD_UOMS;


ALTER TABLE AMD_UOMS ADD (
  CHECK ("UOM_TERM" IS NOT NULL) DISABLE);

ALTER TABLE AMD_UOMS ADD (
  CONSTRAINT AMD_UOMS_PK PRIMARY KEY (UOM_CODE)
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

ALTER TABLE AMD_UOMS ADD (
  CONSTRAINT AMD_UOMS_UC01 UNIQUE (UOM_TERM)
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


GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_UOMS TO AMD_DATALOAD;

GRANT SELECT ON  AMD_UOMS TO AMD_USER;

GRANT SELECT ON  AMD_UOMS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_UOMS TO AMD_WRITER_ROLE;


