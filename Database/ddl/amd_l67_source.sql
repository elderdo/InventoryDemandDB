    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:08  $
     $Workfile:   amd_l67_source.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_l67_source.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:08   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_L67_SOURCE
(
  DIC           VARCHAR2(6 BYTE),
  RI            VARCHAR2(3 BYTE),
  NSN           VARCHAR2(16 BYTE),
  MMC           VARCHAR2(4 BYTE),
  NOMENCLATURE  VARCHAR2(32 BYTE),
  DOC_NO        VARCHAR2(20 BYTE),
  ATC           VARCHAR2(1 BYTE),
  TRIC          VARCHAR2(3 BYTE),
  TTPC          VARCHAR2(6 BYTE),
  DMD_CD        VARCHAR2(4 BYTE),
  TRANS_DATE    DATE,
  TRANS_SER     VARCHAR2(10 BYTE),
  MARKED_FOR    VARCHAR2(14 BYTE),
  ACTION_QTY    NUMBER,
  REASON        VARCHAR2(30 BYTE),
  SRAN          VARCHAR2(10 BYTE),
  DOFD          DATE,
  DOLD          DATE,
  UI            VARCHAR2(2 BYTE),
  SUPP_ADDRESS  VARCHAR2(6 BYTE),
  ERC           VARCHAR2(4 BYTE),
  MIC           VARCHAR2(1 BYTE),
  FILENAME      VARCHAR2(50 BYTE)
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


CREATE UNIQUE INDEX AMD_L67_SOURCE_PK ON AMD_L67_SOURCE
(NSN, DOC_NO, TRANS_DATE, TRANS_SER, SRAN)
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


CREATE PUBLIC SYNONYM AMD_L67_SOURCE FOR AMD_L67_SOURCE;


ALTER TABLE AMD_L67_SOURCE ADD (
  CONSTRAINT AMD_L67_SOURCE_PK PRIMARY KEY (NSN, DOC_NO, TRANS_DATE, TRANS_SER, SRAN)
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


GRANT SELECT ON  AMD_L67_SOURCE TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_L67_SOURCE TO AMD_WRITER_ROLE;


