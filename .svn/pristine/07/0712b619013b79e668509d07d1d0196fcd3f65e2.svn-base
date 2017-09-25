    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:06  $
     $Workfile:   amd_icaos.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_icaos.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:06   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_ICAOS
(
  ICAO      VARCHAR2(4 BYTE)                    NOT NULL,
  LOCATION  VARCHAR2(25 BYTE)                   NOT NULL
)
TABLESPACE AMD_DATA
PCTUSED    40
PCTFREE    0
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


CREATE UNIQUE INDEX AMD_ICAOS_PK ON AMD_ICAOS
(ICAO, LOCATION)
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


CREATE PUBLIC SYNONYM AMD_ICAOS FOR AMD_ICAOS;


ALTER TABLE AMD_ICAOS ADD (
  CONSTRAINT AMD_ICAOS_PK PRIMARY KEY (ICAO, LOCATION)
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


ALTER TABLE AMD_ICAOS ADD (
  CONSTRAINT AMD_ICAOS_FK01 FOREIGN KEY (ICAO) 
    REFERENCES AMD_ICAO_XREF (ICAO) DISABLE);


GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_ICAOS TO AMD_DATALOAD;

GRANT SELECT ON  AMD_ICAOS TO AMD_USER;

GRANT SELECT ON  AMD_ICAOS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_ICAOS TO AMD_WRITER_ROLE;


