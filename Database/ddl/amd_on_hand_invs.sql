    /*   				
       $Author:   c970183  $
     $Revision:   1.1  $
         $Date:   May 20 2005 09:10:22  $
     $Workfile:   amd_on_hand_invs.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_on_hand_invs.sql-arc  $
/*   
/*      Rev 1.1   May 20 2005 09:10:22   c970183
/*   Removed inv_date for SCM 
/*   
/*      Rev 1.0   May 20 2005 08:57:52   c970183
/*   Initial revision.
*/

CREATE TABLE AMD_ON_HAND_INVS
(
  PART_NO         VARCHAR2(50 BYTE)             NOT NULL,
  LOC_SID         NUMBER                        NOT NULL,
  INV_QTY         NUMBER                        NOT NULL,
  ACTION_CODE     VARCHAR2(1 BYTE)              NOT NULL,
  LAST_UPDATE_DT  DATE                          NOT NULL
)
TABLESPACE AMD_INDEX
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


CREATE UNIQUE INDEX AMD_ON_HAND_INVS_PK ON AMD_ON_HAND_INVS
(PART_NO, LOC_SID)
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


CREATE PUBLIC SYNONYM AMD_ON_HAND_INVS FOR AMD_ON_HAND_INVS;


ALTER TABLE AMD_ON_HAND_INVS ADD (
  CONSTRAINT AMD_ON_HAND_INVS_PK PRIMARY KEY (PART_NO, LOC_SID)
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


GRANT SELECT ON  AMD_ON_HAND_INVS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  AMD_ON_HAND_INVS TO AMD_WRITER_ROLE;



