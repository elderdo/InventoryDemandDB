    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:16  $
     $Workfile:   amd_nsns.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_nsns.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:16   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_NSNS
(
  NSN            VARCHAR2(15 BYTE)              NOT NULL,
  NSN_TYPE       VARCHAR2(1 BYTE),
  NSI_SID        NUMBER,
  CREATION_DATE  DATE
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


CREATE INDEX AMD_NSNS_NK01 ON AMD_NSNS
(NSI_SID)
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


CREATE UNIQUE INDEX AMD_NSNS_PK ON AMD_NSNS
(NSN)
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


CREATE PUBLIC SYNONYM AMD_NSNS FOR AMD_NSNS;


ALTER TABLE AMD_NSNS ADD (
  CHECK ("NSN_TYPE" IS NOT NULL) DISABLE);

ALTER TABLE AMD_NSNS ADD (
  CHECK ("CREATION_DATE" IS NOT NULL) DISABLE);

ALTER TABLE AMD_NSNS ADD (
  CONSTRAINT AMD_NSNS_PK PRIMARY KEY (NSN)
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


ALTER TABLE AMD_NSNS ADD (
  CONSTRAINT AMD_NSNS_FK01 FOREIGN KEY (NSI_SID) 
    REFERENCES AMD_NATIONAL_STOCK_ITEMS (NSI_SID));


GRANT SELECT ON  AMD_NSNS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_NSNS TO AMD_WRITER_ROLE;


