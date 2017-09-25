    /*   				
       $Author:   c970183  $
     $Revision:   1.1  $
         $Date:   May 31 2005 10:49:16  $
     $Workfile:   amd_planner_logons.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_planner_logons.sql-arc  $
/*   
/*      Rev 1.1   May 31 2005 10:49:16   c970183
/*   Fixed ddl (was incorrectly defining amd_planners).  Added Last_Update_Date and Action_code.
/*   
/*      Rev 1.0   May 20 2005 08:53:22   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_PLANNER_LOGONS
(
  PLANNER_CODE    VARCHAR2(8 BYTE)              NOT NULL,
  LOGON_ID        VARCHAR2(8 BYTE)              NOT NULL,
  DEFAULT_IND     VARCHAR2(1 BYTE),
  ACTION_CODE     VARCHAR2(1 BYTE)              DEFAULT 'A',
  LAST_UPDATE_DT  DATE                          DEFAULT SYSDATE
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


CREATE UNIQUE INDEX AMD_PLANNER_LOGONS_PK ON AMD_PLANNER_LOGONS
(PLANNER_CODE, LOGON_ID)
LOGGING
TABLESPACE AMD_INDEX
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


CREATE PUBLIC SYNONYM AMD_PLANNER_LOGONS FOR AMD_PLANNER_LOGONS;


ALTER TABLE AMD_PLANNER_LOGONS ADD (
  CONSTRAINT AMD_PLANNER_LOGONS_PK PRIMARY KEY (PLANNER_CODE, LOGON_ID)
    USING INDEX 
    TABLESPACE AMD_INDEX
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


ALTER TABLE AMD_PLANNER_LOGONS ADD (
  CONSTRAINT AMD_PLANNER_LOGONS_FK01 FOREIGN KEY (PLANNER_CODE) 
    REFERENCES AMD_PLANNERS (PLANNER_CODE)
    ON DELETE CASCADE);


GRANT SELECT ON  AMD_PLANNER_LOGONS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_PLANNER_LOGONS TO AMD_WRITER_ROLE;


