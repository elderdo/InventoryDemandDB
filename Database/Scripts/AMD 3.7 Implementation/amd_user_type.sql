SET DEFINE OFF;
ALTER TABLE AMD_OWNER.AMD_USER_TYPE
 DROP PRIMARY KEY CASCADE;
DROP TABLE AMD_OWNER.AMD_USER_TYPE CASCADE CONSTRAINTS;

CREATE TABLE AMD_OWNER.AMD_USER_TYPE
(
  BEMS_ID         VARCHAR2(8 BYTE)              NOT NULL,
  USER_TYPE       VARCHAR2(16 BYTE)             NOT NULL,
  ACTION_CODE     VARCHAR2(1 BYTE)              DEFAULT 'A',
  LAST_UPDATE_DT  DATE                          DEFAULT sysdate
)
TABLESPACE AMD_INDEX
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX AMD_OWNER.AMD_USER_TYPE_PK ON AMD_OWNER.AMD_USER_TYPE
(BEMS_ID, USER_TYPE)
LOGGING
TABLESPACE AMD_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER AMD_OWNER.amd_USER_TYPE_before_TRIG
before INSERT
ON AMD_OWNER.AMD_USER_TYPE REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   09 Feb 2009 10:53:14  $
    $Workfile:   amd_user_type.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 3.7 Implementation\amd_user_type.sql.-arc  $
/*   
/*      Rev 1.0   09 Feb 2009 10:53:14   zf297a
/*   Initial revision.

*/         
wk_bems_id amd_people_all_v.bems_id%type ;
wk_user_type spo_user_type_v.NAME%type ;
BEGIN
    begin
        select bems_id into wk_bems_id from amd_people_all_v
        where :new.bems_id = amd_people_all_v.bems_id;
    exception when standard.no_data_found then     
        raise_application_error(-20800,'bems_id ' || :new.bems_id || ' does not exist in amd_people_all_v.') ;
    end   ;         
    begin
        select name into wk_user_type from spo_user_type_v
        where :new.user_type = spo_user_type_v.name ;
    exception when standard.no_data_found then     
        raise_application_error(-20900,'user_type ' || :new.bems_id || ' does not exist in spo_user_type_v.') ;
    end ;     
END ;
/
SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_USER_TYPE;

CREATE PUBLIC SYNONYM AMD_USER_TYPE FOR AMD_OWNER.AMD_USER_TYPE;


ALTER TABLE AMD_OWNER.AMD_USER_TYPE ADD (
  CONSTRAINT AMD_USER_TYPE_PK
 PRIMARY KEY
 (BEMS_ID, USER_TYPE)
    USING INDEX 
    TABLESPACE AMD_INDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                FREELISTS        1
                FREELIST GROUPS  1
               ));

GRANT SELECT ON AMD_OWNER.AMD_USER_TYPE TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_USER_TYPE TO AMD_WRITER_ROLE;


