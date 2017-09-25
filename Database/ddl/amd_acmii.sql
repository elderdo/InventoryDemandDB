    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:52:52  $
     $Workfile:   amd_acmii.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_acmii.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:52:52   c970183
/*   Initial revision.
*/
CREATE TABLE AMD_ACMII
(
  NSN   VARCHAR2(15 BYTE)                       NOT NULL,
  SRAN  VARCHAR2(10 BYTE)                       NOT NULL,
  ROP   NUMBER,
  ROQ   NUMBER
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


CREATE UNIQUE INDEX AMD_ACMII_PK ON AMD_ACMII
(NSN, SRAN)
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


CREATE PUBLIC SYNONYM AMD_ACMII FOR AMD_ACMII;


ALTER TABLE AMD_ACMII ADD (
  CONSTRAINT AMD_ACMII_PK PRIMARY KEY (NSN, SRAN)
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


GRANT SELECT ON  AMD_ACMII TO AMD_READER_ROLE;

GRANT DELETE, INSERT, UPDATE ON  AMD_ACMII TO AMD_WRITER_ROLE;


