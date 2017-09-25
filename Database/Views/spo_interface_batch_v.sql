SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_INTERFACE_BATCH_V;

/* Formatted on 2009/07/08 17:16 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_interface_batch_v (interface,
                                                              batch,
                                                              batch_mode,
                                                              begin_date,
                                                              last_date,
                                                              end_date,
                                                              processed_records,
                                                              last_modified
                                                             )
as
   select "INTERFACE", "BATCH", "BATCH_MODE", "BEGIN_DATE", "LAST_DATE",
          "END_DATE", "PROCESSED_RECORDS", last_modified
     from spoc17v2.v_interface_batch@stl_escm_link;


DROP PUBLIC SYNONYM SPO_INTERFACE_BATCH_V;

CREATE PUBLIC SYNONYM SPO_INTERFACE_BATCH_V FOR AMD_OWNER.SPO_INTERFACE_BATCH_V;


GRANT SELECT ON AMD_OWNER.SPO_INTERFACE_BATCH_V TO AMD_READER_ROLE;

