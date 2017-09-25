 /*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   23 Aug 2007 10:41:26  $
    $Workfile:   tmp_a2a_loc_part_override.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\tmp_a2a_loc_part_override.sql.-arc  $
/*   
/*      Rev 1.0   23 Aug 2007 10:41:26   zf297a
/*   Initial revision.
*/

set define off

ALTER TABLE AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE
 DROP PRIMARY KEY CASCADE;
DROP TABLE AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE CASCADE CONSTRAINTS;

CREATE TABLE AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE
(
  PART_NO            VARCHAR2(50 BYTE)          NOT NULL,
  SITE_LOCATION      VARCHAR2(30 BYTE)          DEFAULT NULL                  NOT NULL,
  OVERRIDE_TYPE      VARCHAR2(32 BYTE)          DEFAULT 'TSL Fixed',
  OVERRIDE_QUANTITY  NUMBER,
  OVERRIDE_REASON    VARCHAR2(64 BYTE)          DEFAULT 'Fixed TSL Load',
  OVERRIDE_USER      VARCHAR2(8 BYTE),
  BEGIN_DATE         DATE,
  END_DATE           DATE                       DEFAULT to_date('12/31/2057 12:00:00','MM/DD/YYYY HH24:MI:SS'),
  ACTION_CODE        VARCHAR2(1 BYTE)           NOT NULL,
  LAST_UPDATE_DT     DATE                       NOT NULL
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
NOMONITORING;


CREATE UNIQUE INDEX AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE_PK ON AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE
(PART_NO, SITE_LOCATION, OVERRIDE_TYPE)
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


SHOW ERRORS;


CREATE OR REPLACE TRIGGER AMD_OWNER.tmp_a2a_loc_part_override_trg1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   23 Aug 2007 10:41:26  $
    $Workfile:   tmp_a2a_loc_part_override.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\TMP_A2A_LOC_PART_OVERRIDE_TRG1.trg.-arc  $
/*
/*      Rev 1.0   Aug 23 2006 09:35:44   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.site_location = Amd_Location_Part_Override_Pkg.THE_WAREHOUSE
	and amd_utils.isPartRepairable(:new.part_no) then
	:new.override_quantity := 0 ;
	:new.last_update_dt := sysdate ;
  end if ;
END tmp_a2a_loc_part_override_trg1 ;
/
SHOW ERRORS;


DROP PUBLIC SYNONYM TMP_A2A_LOC_PART_OVERRIDE;

CREATE PUBLIC SYNONYM TMP_A2A_LOC_PART_OVERRIDE FOR AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE;


ALTER TABLE AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE ADD (
  CONSTRAINT TMP_A2A_LOC_PART_OVERRIDE_PK
 PRIMARY KEY
 (PART_NO, SITE_LOCATION, OVERRIDE_TYPE)
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

ALTER TABLE AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE ADD (
  CONSTRAINT TMP_A2A_LOC_PART_OVERRIDE_FK01 
 FOREIGN KEY (PART_NO) 
 REFERENCES AMD_OWNER.AMD_SENT_TO_A2A (PART_NO));

GRANT SELECT ON AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.TMP_A2A_LOC_PART_OVERRIDE TO AMD_WRITER_ROLE;


