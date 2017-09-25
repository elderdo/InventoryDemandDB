    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:52  $
     $Workfile:   tmp_amd_causal_factors.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_amd_causal_factors.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:52   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_AMD_CAUSAL_FACTORS
(
  AM_ID      VARCHAR2(10 BYTE),
  NSN        VARCHAR2(20 BYTE),
  CONSTANTS  NUMBER,
  FH         NUMBER,
  LD         NUMBER,
  HS         NUMBER,
  MFGR       VARCHAR2(13 BYTE),
  PART_NO    VARCHAR2(20 BYTE)
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


CREATE PUBLIC SYNONYM TMP_AMD_CAUSAL_FACTORS FOR TMP_AMD_CAUSAL_FACTORS;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_CAUSAL_FACTORS TO AMD_DATALOAD;

GRANT SELECT ON  TMP_AMD_CAUSAL_FACTORS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_CAUSAL_FACTORS TO AMD_WRITER_ROLE;


