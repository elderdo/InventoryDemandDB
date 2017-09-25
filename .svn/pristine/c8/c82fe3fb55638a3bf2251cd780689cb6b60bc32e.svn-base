    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:54  $
     $Workfile:   tmp_amd_icp_sbss_intersect.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_amd_icp_sbss_intersect.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:54   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_AMD_ICP_SBSS_INTERSECT
(
  NSN        VARCHAR2(13 BYTE),
  LOAD_DATE  DATE
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


CREATE PUBLIC SYNONYM TMP_AMD_ICP_SBSS_INTERSECT FOR TMP_AMD_ICP_SBSS_INTERSECT;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_ICP_SBSS_INTERSECT TO AMD_DATALOAD;

GRANT SELECT ON  TMP_AMD_ICP_SBSS_INTERSECT TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_ICP_SBSS_INTERSECT TO AMD_WRITER_ROLE;


