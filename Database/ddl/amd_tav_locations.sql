    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:32  $
     $Workfile:   amd_tav_locations.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_tav_locations.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:32   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_TAV_LOCATIONS
(
  SRAN      VARCHAR2(15 BYTE),
  LOC_NAME  VARCHAR2(50 BYTE),
  LOC_TYPE  VARCHAR2(25 BYTE)
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


CREATE UNIQUE INDEX AMD_TAV_LOCATIONS_PK ON AMD_TAV_LOCATIONS
(SRAN)
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


CREATE PUBLIC SYNONYM AMD_TAV_LOCATIONS FOR AMD_TAV_LOCATIONS;


ALTER TABLE AMD_TAV_LOCATIONS ADD (
  CONSTRAINT AMD_TAV_LOCATIONS_PK PRIMARY KEY (SRAN)
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


GRANT SELECT ON  AMD_TAV_LOCATIONS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, UPDATE ON  AMD_TAV_LOCATIONS TO AMD_WRITER_ROLE;


