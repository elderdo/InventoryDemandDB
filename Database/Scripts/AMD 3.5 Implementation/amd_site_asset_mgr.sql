SET DEFINE OFF;
ALTER TABLE AMD_OWNER.AMD_SITE_ASSET_MGR
 DROP PRIMARY KEY CASCADE;
DROP TABLE AMD_OWNER.AMD_SITE_ASSET_MGR CASCADE CONSTRAINTS;

CREATE TABLE AMD_OWNER.AMD_SITE_ASSET_MGR
(
  BEMS_ID         VARCHAR2(8 BYTE)              NOT NULL,
  COMMENTS        VARCHAR2(2000 BYTE),
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


CREATE UNIQUE INDEX AMD_OWNER.AMD_SITE_ASSET_MGR_PK01 ON AMD_OWNER.AMD_SITE_ASSET_MGR
(BEMS_ID)
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


CREATE OR REPLACE TRIGGER AMD_OWNER.amd_site_asset_mgr_before_TRIG
before INSERT
ON AMD_OWNER.AMD_SITE_ASSET_MGR REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   05 Nov 2008 09:50:04  $
    $Workfile:   AMD_SITE_ASSET_MGR_BEFORE_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SITE_ASSET_MGR_BEFORE_TRIG.trg.-arc  $
/*   
/*      Rev 1.0   05 Nov 2008 09:50:04   zf297a
/*   Initial revision.

*/         
wk_bems_id amd_people_all_v.bems_id%type ;
BEGIN
    select bems_id into wk_bems_id from amd_people_all_v
    where :new.bems_id = amd_people_all_v.bems_id;
exception when standard.no_data_found then     
    raise_application_error(-20900,'bems_id ' || :new.bems_id || ' does not exist in amd_people_all_v.') ;
END ;
/
SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_SITE_ASSET_MGR;

CREATE PUBLIC SYNONYM AMD_SITE_ASSET_MGR FOR AMD_OWNER.AMD_SITE_ASSET_MGR;


ALTER TABLE AMD_OWNER.AMD_SITE_ASSET_MGR ADD (
  CONSTRAINT AMD_SITE_ASSET_MGR_PK01
 PRIMARY KEY
 (BEMS_ID)
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

GRANT SELECT ON AMD_OWNER.AMD_SITE_ASSET_MGR TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_SITE_ASSET_MGR TO AMD_WRITER_ROLE;


