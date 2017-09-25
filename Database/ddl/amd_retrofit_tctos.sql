    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:28  $
     $Workfile:   amd_retrofit_tctos.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_retrofit_tctos.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:28   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_RETROFIT_TCTOS
(
  TCTO_NUMBER               VARCHAR2(13 BYTE)   NOT NULL,
  TCTO_DESC                 VARCHAR2(512 BYTE)  NOT NULL,
  AVG_MONTHLY_UPGRADE       NUMBER,
  LAST_NSI_PAIRS_UPDATE_DT  DATE,
  LAST_NSI_PAIRS_UPDATE_ID  VARCHAR2(8 BYTE),
  LAST_SCHED_UPDATE_DT      DATE,
  LAST_SCHED_UPDATE_ID      VARCHAR2(8 BYTE)
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


CREATE UNIQUE INDEX AMD_TCTOS_PK ON AMD_RETROFIT_TCTOS
(TCTO_NUMBER)
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


CREATE PUBLIC SYNONYM AMD_RETROFIT_TCTOS FOR AMD_RETROFIT_TCTOS;


ALTER TABLE AMD_RETROFIT_TCTOS ADD (
  CONSTRAINT AMD_TCTOS_PK PRIMARY KEY (TCTO_NUMBER)
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


GRANT SELECT ON  AMD_RETROFIT_TCTOS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_RETROFIT_TCTOS TO AMD_WRITER_ROLE;


