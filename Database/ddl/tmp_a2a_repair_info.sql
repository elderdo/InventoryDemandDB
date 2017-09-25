
CREATE TABLE TMP_A2A_PART_INFO
(
  SOURCE_SYSTEM             VARCHAR2(20 BYTE)   DEFAULT 'LB'                  NOT NULL,
  CAGE_CODE                 VARCHAR2(5 BYTE),
  PART_NO                   VARCHAR2(50 BYTE)   NOT NULL,
  UNIT_ISSUE                VARCHAR2(2 BYTE),
  NOUN                      VARCHAR2(50 BYTE)   NOT NULL,
  RCM_IND                   VARCHAR2(1 BYTE),
  HAZMAT_CODE               VARCHAR2(1 BYTE),
  SHELF_LIFE                VARCHAR2(3 BYTE),
  EQUIPMENT_TYPE            VARCHAR2(1 BYTE)    DEFAULT 'A'                   NOT NULL,
  NSN_COG                   VARCHAR2(2 BYTE),
  NSN_MCC                   VARCHAR2(1 BYTE),
  NSN_FSC                   VARCHAR2(4 BYTE),
  NSN_NIIN                  VARCHAR2(9 BYTE),
  NSN_SMIC_MMAC             VARCHAR2(2 BYTE),
  NSN_ACTY                  VARCHAR2(2 BYTE),
  ESSENTIALITY_CODE         VARCHAR2(20 BYTE),
  RESP_ASSET_MGR            VARCHAR2(20 BYTE),
  UNIT_PACK_CUBE            VARCHAR2(10 BYTE),
  UNIT_PACK_QTY             VARCHAR2(20 BYTE),
  UNIT_PACK_WEIGHT          VARCHAR2(9 BYTE),
  UNIT_PACK_WEIGHT_MEASURE  VARCHAR2(10 BYTE),
  ELECTRO_STATIC_DISCHARGE  VARCHAR2(1 BYTE),
  PERF_BASED_LOG_INFO       VARCHAR2(20 BYTE),
  PLANNED_PART              VARCHAR2(1 BYTE)    DEFAULT 'P'                   NOT NULL,
  THIRD_PARTY_FLAG          VARCHAR2(1 BYTE),
  MTBF                      VARCHAR2(9 BYTE),
  MTBF_TYPE                 VARCHAR2(32 BYTE),
  SHELF_LIFE_ACTION_CODE    VARCHAR2(2 BYTE),
  PREFERRED_SMRCODE         VARCHAR2(6 BYTE),
  DECAY_RATE                VARCHAR2(10 BYTE),
  INDENTURE                 VARCHAR2(7 BYTE),
  LAST_UPDATE_DT            DATE                DEFAULT SYSDATE               NOT NULL,
  ACTION_CODE               VARCHAR2(1 BYTE),
  IS_EXEMPT                 VARCHAR2(10 BYTE)   DEFAULT 'F',
  IGNORE_WEIGHT_AND_VOLUME  VARCHAR2(10 BYTE)   DEFAULT 'F',
  IS_ORDER_POLICY_REQ_BASE  VARCHAR2(10 BYTE)   DEFAULT 'T'
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


CREATE UNIQUE INDEX TMP_A2A_PART_INFO_PK ON TMP_A2A_PART_INFO
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


CREATE OR REPLACE TRIGGER A2A_PART_INFO_AFTER_TRIG
AFTER INSERT
ON TMP_A2A_PART_INFO REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   c970183  $
    $Revision:   1.0  $
	    $Date:   Jun 10 2005 11:14:20  $
    $Workfile:   tmp_a2a_repair_info.sql  $
         $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_a2a_repair_info.sql-arc  $
/*   
/*      Rev 1.0   Jun 10 2005 11:14:20   c970183
/*   Initial revision.
/*   
/*      Rev 1.1   May 31 2005 10:04:24   c970183
/*   Updated amd_sent_to_a2a when a duplicate index exception occurs.
/*   
/*      Rev 1.0   May 13 2005 14:24:12   c970183
/*   Initial revision.
*/		 
	procedure errorMsg is
		sqlFunction constant varchar2(6) := 'insert' ;
		tableName constant varchar2(15) := 'amd_sent_to_a2a' ;
	begin
		dbms_output.put_line('sqlcode('||sqlcode||') sqlerrm('|| sqlerrm||')') ;
		dbms_output.put_line('part_no=' || :new.part_no || ' action_code=' || :new.action_code) ;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => substr(sqlFunction,1,20),
						                        pTableName  => substr(tableName,1,20)),
				pData_line_no => 10,
				pData_line    => 'a2a_part_info_after_trig', 
				pKey_1 => substr(:new.part_no,1,50),
				pKey_2 => substr(:new.action_code,1,50),
				pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MM:SS'),
				pComments => substr('sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')',1,2000));
	end ErrorMsg;
	
BEGIN

   insert into amd_sent_to_a2a 
   (part_no, action_code, transaction_date)  
   values
   (:NEW.part_no, :NEW.action_code, sysdate) ;
EXCEPTION
	 when standard.DUP_VAL_ON_INDEX then
	 	  update amd_sent_to_a2a
		  set action_code = :NEW.action_code,
		  transaction_date = sysdate
		  where part_no = :NEW.part_no ;
     WHEN OTHERS THEN
	   errorMsg ;
       RAISE;
END ;
/
SHOW ERRORS;



CREATE PUBLIC SYNONYM TMP_A2A_PART_INFO FOR TMP_A2A_PART_INFO;


ALTER TABLE TMP_A2A_PART_INFO ADD (
  CONSTRAINT TMP_A2A_PART_INFO_PK PRIMARY KEY (PART_NO)
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


GRANT SELECT ON  TMP_A2A_PART_INFO TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_A2A_PART_INFO TO AMD_WRITER_ROLE;



