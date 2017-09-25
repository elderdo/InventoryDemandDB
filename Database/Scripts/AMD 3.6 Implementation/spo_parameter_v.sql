SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PARAMETER_V;

/* Formatted on 2008/11/26 07:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_parameter_v (NAME,
                                                        description,
                                                        parameter_type,
                                                        VALUE,
                                                        TIMESTAMP
                                                       )
AS
   SELECT "NAME", "DESCRIPTION", "PARAMETER_TYPE", "VALUE", "TIMESTAMP"
     FROM spoc17v2.v_parameter@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PARAMETER_V;

CREATE PUBLIC SYNONYM SPO_PARAMETER_V FOR AMD_OWNER.SPO_PARAMETER_V;


GRANT SELECT ON AMD_OWNER.SPO_PARAMETER_V TO AMD_READER_ROLE;


