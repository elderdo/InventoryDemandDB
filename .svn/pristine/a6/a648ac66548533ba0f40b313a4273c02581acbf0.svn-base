SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V;

/* Formatted on 2008/11/26 10:29 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_x_imp_interface_batch_v (INTERFACE,
                                                                    batch,
                                                                    batch_mode,
                                                                    action,
                                                                    EXCEPTION,
                                                                    TIMESTAMP,
                                                                    interface_sequence
                                                                   )
AS
   SELECT "INTERFACE", "BATCH", "BATCH_MODE", "ACTION", "EXCEPTION",
          "TIMESTAMP", "INTERFACE_SEQUENCE"
     FROM spoc17v2.x_imp_interface_batch@stl_escm_link;


DROP PUBLIC SYNONYM SPO_X_IMP_INTERFACE_BATCH_V;

CREATE PUBLIC SYNONYM SPO_X_IMP_INTERFACE_BATCH_V FOR AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V;


GRANT SELECT ON AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V TO AMD_READER_ROLE;


