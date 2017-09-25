SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_USER_V;

/* Formatted on 2008/10/02 13:17 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_user_v (NAME,
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
   SELECT TO_CHAR (TO_NUMBER (bems_id)) NAME,
          REPLACE (stable_email, ' ', '') email_address,
          TRIM (last_name) || ', ' || TRIM (first_name) attribute_1,
          NULL attribute_2, NULL attribute_3, NULL attribute_4,
          NULL attribute_5, NULL attribute_6, NULL attribute_7,
          'A' attribute_8, last_update_dt TIMESTAMP
     FROM amd_users_v;


DROP PUBLIC SYNONYM X_USER_V;

CREATE PUBLIC SYNONYM X_USER_V FOR AMD_OWNER.X_USER_V;


GRANT SELECT ON AMD_OWNER.X_USER_V TO AMD_READER_ROLE;


