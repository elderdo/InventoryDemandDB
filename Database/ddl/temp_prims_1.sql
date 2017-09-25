    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:52  $
     $Workfile:   temp_prims_1.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\temp_prims_1.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:52   c970183
/*   Initial revision.
*/

CREATE TABLE TEMP_PRIMS_1
(
  COMPONENT_PART_NO        VARCHAR2(20 BYTE),
  COMPONENT_MFGR           VARCHAR2(5 BYTE),
  NEXT_ASSEMBLY_PART_NO    VARCHAR2(20 BYTE),
  NEXT_ASSEMBLY_CAGE_CODE  VARCHAR2(5 BYTE),
  SCRAP_FLAG               VARCHAR2(1 BYTE),
  QPA                      VARCHAR2(10 BYTE),
  START_BUN                VARCHAR2(6 BYTE),
  END_BUN                  VARCHAR2(6 BYTE)
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


CREATE PUBLIC SYNONYM TEMP_PRIMS_1 FOR TEMP_PRIMS_1;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_PRIMS_1 TO AMD_DATALOAD;

GRANT SELECT ON  TEMP_PRIMS_1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_PRIMS_1 TO AMD_WRITER_ROLE;


