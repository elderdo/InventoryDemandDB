    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:26  $
     $Workfile:   amd_retrofit_sched_blocks.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_retrofit_sched_blocks.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:26   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_RETROFIT_SCHED_BLOCKS
(
  BLOCK_NAME  VARCHAR2(20 BYTE)                 NOT NULL,
  BLOCK_DESC  VARCHAR2(100 BYTE)                NOT NULL
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


CREATE UNIQUE INDEX AMD_RETROFIT_SCHED_BLOCKS_PK ON AMD_RETROFIT_SCHED_BLOCKS
(BLOCK_NAME)
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


CREATE PUBLIC SYNONYM AMD_RETROFIT_SCHED_BLOCKS FOR AMD_RETROFIT_SCHED_BLOCKS;


ALTER TABLE AMD_RETROFIT_SCHED_BLOCKS ADD (
  CONSTRAINT AMD_RETROFIT_SCHED_BLOCKS_PK PRIMARY KEY (BLOCK_NAME)
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


GRANT SELECT ON  AMD_RETROFIT_SCHED_BLOCKS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_RETROFIT_SCHED_BLOCKS TO AMD_WRITER_ROLE;


