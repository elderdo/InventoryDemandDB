SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_USER_V;

/* Formatted on 2008/08/14 13:08 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_user_v (ID,
                                                   NAME,
                                                   email_address,
                                                   attribute_1,
                                                   attribute_2,
                                                   attribute_3,
                                                   attribute_4,
                                                   attribute_5,
                                                   attribute_6,
                                                   attribute_7,
                                                   attribute_8,
                                                   TIMESTAMP
                                                  )
AS
   SELECT ID, NAME, email_address, attribute_1, attribute_2, attribute_3,
          attribute_4, attribute_5, attribute_6, attribute_7, attribute_8,
          TIMESTAMP
     FROM spoc17v2.v_spo_user@stl_escm_link;


DROP PUBLIC SYNONYM SPO_USER_V;

CREATE PUBLIC SYNONYM SPO_USER_V FOR AMD_OWNER.SPO_USER_V;


GRANT SELECT ON AMD_OWNER.SPO_USER_V TO AMD_READER_ROLE;


