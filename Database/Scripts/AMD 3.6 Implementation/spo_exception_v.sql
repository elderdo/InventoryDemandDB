SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_EXCEPTION_V;

/* Formatted on 2008/11/26 10:16 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_exception_v (ID,
                                                        exception_type,
                                                        CLASS,
                                                        MESSAGE
                                                       )
AS
   SELECT "ID", "EXCEPTION_TYPE", "CLASS", "MESSAGE"
     FROM spoc17v2.v_exception@stl_escm_link;


DROP PUBLIC SYNONYM SPO_EXCEPTION_V;

CREATE PUBLIC SYNONYM SPO_EXCEPTION_V FOR AMD_OWNER.SPO_EXCEPTION_V;


GRANT SELECT ON AMD_OWNER.SPO_EXCEPTION_V TO AMD_READER_ROLE;


