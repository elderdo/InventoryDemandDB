SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_INTERFACE_BATCH_V;

/* Formatted on 2008/11/26 08:23 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_interface_batch_v (INTERFACE,
                                                              batch,
                                                              batch_mode,
                                                              begin_date,
                                                              last_date,
                                                              end_date,
                                                              processed_records,
                                                              TIMESTAMP
                                                             )
AS
   SELECT "INTERFACE", "BATCH", "BATCH_MODE", "BEGIN_DATE", "LAST_DATE",
          "END_DATE", "PROCESSED_RECORDS", "TIMESTAMP"
     FROM spoc17v2.v_interface_batch@stl_escm_link;


DROP PUBLIC SYNONYM SPO_INTERFACE_BATCH_V;

CREATE PUBLIC SYNONYM SPO_INTERFACE_BATCH_V FOR AMD_OWNER.SPO_INTERFACE_BATCH_V;


GRANT SELECT ON AMD_OWNER.SPO_INTERFACE_BATCH_V TO AMD_READER_ROLE;


