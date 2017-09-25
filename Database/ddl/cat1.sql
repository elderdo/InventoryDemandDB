SET DEFINE OFF;
DROP PUBLIC SYNONYM CAT1;

CREATE PUBLIC SYNONYM CAT1 FOR AMD_OWNER.CAT1;


DROP MATERIALIZED VIEW AMD_OWNER.CAT1;
CREATE MATERIALIZED VIEW AMD_OWNER.CAT1 
TABLESPACE AMD_DATA
PCTUSED    40
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
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
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
                        BUFFER_POOL      DEFAULT
                       )
REFRESH COMPLETE
START WITH TO_DATE('20-Apr-2009 15:45:53','dd-mon-yyyy hh24:mi:ss')
NEXT SYSDATE + 1/48  
WITH ROWID
AS 
/* Formatted on 2009/04/20 15:31 (Formatter Plus v4.8.8) */
select TRIM (part) part, TRIM (nsn) nsn, TRIM (description) noun,
       TRIM (prime_part_cage) prime,
       case
          when length (TRIM (um_show_code)) > 2
             then SUBSTR (TRIM (um_show_code), 1, 2)
          else TRIM (um_show_code)
       end um_show_code,
       TRIM (unit_of_issue) um_issue_code, TRIM (um_turn_code) um_turn_code,
       TRIM (um_disp_code) um_disp_code,
       case
          when length (TRIM (um_cap_code)) > 2
             then SUBSTR (TRIM (um_cap_code), 1, 2)
          else TRIM (um_cap_code)
       end um_cap_code,
       TRIM (um_mil_code) um_mil_code, asset_req_on_receipt,
       record_changed1_yn, record_changed2_yn, record_changed3_yn,
       record_changed4_yn, record_changed5_yn, record_changed6_yn,
       record_changed7_yn, record_changed8_yn, TRIM (manuf_cage) manuf_cage,
       TRIM (ims_designator_code) ims_designator_code,
       TRIM (source_code) source_code,
       TRIM (serial_mandatory) serial_mandatory_b, TRIM (smrc) smrc,
       TRIM (isgp_group_no) isgp_group_no, TRIM (abbr_part) abbr_part,
       TRIM (errc) errc, TRIM (user_ref4) user_ref4,
       TRIM (hazardous_material_code) hazardous_material_code,
       TRIM (user_ref7) user_ref7, mils_auto_process mils_auto_process_b,
       TRIM (remarks) remarks, TRIM (ave_cap_lead_time) ave_cap_lead_time
  from cat1$merged@dgoldlb
 where source_code = 'F77' and part not like '% ' and part not like ' %';

COMMENT ON MATERIALIZED VIEW AMD_OWNER.CAT1 IS 'snapshot table for snapshot AMD_OWNER.cat1';

CREATE INDEX AMD_OWNER.CAT1_NK01 ON AMD_OWNER.CAT1
(SOURCE_CODE, NSN, PART)
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

CREATE INDEX AMD_OWNER.CAT1_NK02 ON AMD_OWNER.CAT1
(SOURCE_CODE)
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

CREATE INDEX AMD_OWNER.CAT1_NK03 ON AMD_OWNER.CAT1
(PRIME)
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

CREATE INDEX AMD_OWNER.CAT1_NK04 ON AMD_OWNER.CAT1
(NSN)
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

CREATE UNIQUE INDEX AMD_OWNER.CAT1_NK05 ON AMD_OWNER.CAT1
(PART)
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

GRANT SELECT ON AMD_OWNER.CAT1 TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.CAT1 TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.CAT1 TO LORS_READER_ROLE;

GRANT SELECT ON AMD_OWNER.CAT1 TO LORS_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.CAT1 TO WIR_AMD_IF_ROLE;

