SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V;

/* Formatted on 2009/07/08 17:31 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_x_imp_interface_batch_v (interface,
                                                                    batch,
                                                                    batch_mode,
                                                                    action,
                                                                    exception,
                                                                    last_modified,
                                                                    interface_sequence
                                                                   )
as
   select "INTERFACE", "BATCH", "BATCH_MODE", "ACTION", "EXCEPTION",
          last_modified, "INTERFACE_SEQUENCE"
     from spoc17v2.x_imp_interface_batch@stl_escm_link;


DROP PUBLIC SYNONYM SPO_X_IMP_INTERFACE_BATCH_V;

CREATE PUBLIC SYNONYM SPO_X_IMP_INTERFACE_BATCH_V FOR AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V;


GRANT SELECT ON AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V TO AMD_READER_ROLE;

