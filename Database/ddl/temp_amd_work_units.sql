    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:48  $
     $Workfile:   temp_amd_work_units.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\temp_amd_work_units.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:48   c970183
/*   Initial revision.
*/

CREATE TABLE TEMP_AMD_WORK_UNITS
(
  WUC             VARCHAR2(9 BYTE),
  NOMENCLATURE    VARCHAR2(65 BYTE),
  ACT_EST_IND     VARCHAR2(1 BYTE),
  EFFECTIVE_DATE  VARCHAR2(8 BYTE),
  MTBDR           VARCHAR2(15 BYTE)
)
TABLESPACE AMD_DATA
PCTUSED    40
PCTFREE    5
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


CREATE PUBLIC SYNONYM TEMP_AMD_WORK_UNITS FOR TEMP_AMD_WORK_UNITS;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_AMD_WORK_UNITS TO AMD_DATALOAD;

GRANT SELECT ON  TEMP_AMD_WORK_UNITS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_AMD_WORK_UNITS TO AMD_WRITER_ROLE;


