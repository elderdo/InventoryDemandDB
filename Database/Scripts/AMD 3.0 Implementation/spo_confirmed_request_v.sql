SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_V;

/* Formatted on 2008/05/16 12:16 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_confirmed_request_v (ID,
                                                                NAME,
                                                                request_type,
                                                                TIMESTAMP
                                                               )
AS
   SELECT ID, NAME, request_type, TIMESTAMP
     FROM spoc17v2.v_confirmed_request@stl_escm_link;


DROP PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_V FOR AMD_OWNER.SPO_CONFIRMED_REQUEST_V;


GRANT SELECT ON AMD_OWNER.SPO_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;


