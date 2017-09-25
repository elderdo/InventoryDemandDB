    /*   				
       $Author:   c970183  $
     $Revision:   1.1  $
         $Date:   Jun 15 2005 14:56:48  $
     $Workfile:   amd_sent_to_a2a.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\amd_sent_to_a2a.sql-arc  $
/*   
/*      Rev 1.1   Jun 15 2005 14:56:48   c970183
/*   added PVCS keywords
*/
CREATE TABLE AMD_SENT_TO_A2A
(
  PART_NO                  VARCHAR2(50 BYTE)    NOT NULL,
  SPO_PRIME_PART_NO        VARCHAR2(50 BYTE),
  ACTION_CODE              VARCHAR2(1 BYTE)     NOT NULL,
  TRANSACTION_DATE         DATE                 NOT NULL,
  SPO_PRIME_PART_CHG_DATE  DATE
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


CREATE UNIQUE INDEX AMD_SENT_TO_A2A_PK ON AMD_SENT_TO_A2A
(PART_NO)
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


ALTER TABLE AMD_SENT_TO_A2A ADD (
  CONSTRAINT AMD_SENT_TO_A2A_PK PRIMARY KEY (PART_NO)
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



