    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:54:02  $
     $Workfile:   tmp_lcf_icp.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_lcf_icp.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:54:02   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_LCF_ICP
(
  NSN                   VARCHAR2(16 BYTE),
  MMC                   VARCHAR2(4 BYTE),
  STOCK_NO              VARCHAR2(20 BYTE),
  ERC                   VARCHAR2(4 BYTE),
  DIC                   VARCHAR2(6 BYTE),
  TTPC                  VARCHAR2(6 BYTE),
  DMD_CD                VARCHAR2(4 BYTE),
  REASON                VARCHAR2(30 BYTE),
  DOC_NO                VARCHAR2(20 BYTE),
  TRANS_DATE            DATE,
  TRANS_SER             VARCHAR2(10 BYTE),
  ACTION_QTY            NUMBER,
  SRAN                  VARCHAR2(10 BYTE),
  NOMENCLATURE          VARCHAR2(32 BYTE),
  MARKED_FOR            VARCHAR2(14 BYTE),
  DATE_OF_LAST_DEMAND   DATE,
  UNIT_OF_ISSUE         VARCHAR2(2 BYTE),
  SUPPLEMENTAL_ADDRESS  VARCHAR2(6 BYTE)
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


CREATE INDEX TMP_LCF_ICP_NK1 ON TMP_LCF_ICP
(DOC_NO)
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


CREATE PUBLIC SYNONYM TMP_LCF_ICP FOR TMP_LCF_ICP;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_LCF_ICP TO AMD_DATALOAD;

GRANT SELECT ON  TMP_LCF_ICP TO AMD_USER;

GRANT SELECT ON  TMP_LCF_ICP TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_LCF_ICP TO AMD_WRITER_ROLE;


