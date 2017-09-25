    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:28  $
     $Workfile:   amd_rmads_source_tmp.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_rmads_source_tmp.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:28   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_RMADS_SOURCE_TMP
(
  PART_NO        VARCHAR2(50 BYTE)              NOT NULL,
  QPEI_WEIGHTED  NUMBER,
  MTBDR          NUMBER
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


CREATE UNIQUE INDEX AMD_RMADS_SOURCE_TMP_PK ON AMD_RMADS_SOURCE_TMP
(PART_NO)
LOGGING
TABLESPACE AMD_DATA
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


CREATE PUBLIC SYNONYM AMD_RMADS_SOURCE_TMP FOR AMD_RMADS_SOURCE_TMP;


ALTER TABLE AMD_RMADS_SOURCE_TMP ADD (
  CONSTRAINT AMD_RMADS_SOURCE_TMP_PK PRIMARY KEY (PART_NO)
    USING INDEX 
    TABLESPACE AMD_DATA
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


GRANT SELECT ON  AMD_RMADS_SOURCE_TMP TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_RMADS_SOURCE_TMP TO AMD_WRITER_ROLE;


