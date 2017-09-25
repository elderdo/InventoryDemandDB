SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_USER_V;

/* Formatted on 2009/07/08 16:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_user_v (name,
                                                 email_address,
                                                 attribute_1,
                                                 attribute_2,
                                                 attribute_3,
                                                 attribute_4,
                                                 attribute_5,
                                                 attribute_6,
                                                 attribute_7,
                                                 attribute_8,
                                                 last_modified
                                                )
as
   select TO_CHAR (TO_NUMBER (users.bems_id)) name,
          replace (stable_email, ' ', '') email_address,
          TRIM (last_name) || ', ' || TRIM (first_name) attribute_1,
          mgr.comments attribute_2, null attribute_3, null attribute_4,
          null attribute_5, null attribute_6, null attribute_7,
          'A' attribute_8, users.last_update_dt last_modified
     from amd_users_v users, amd_site_asset_mgr mgr
    where users.bems_id = mgr.bems_id(+);


DROP PUBLIC SYNONYM X_USER_V;

CREATE PUBLIC SYNONYM X_USER_V FOR AMD_OWNER.X_USER_V;


GRANT SELECT ON AMD_OWNER.X_USER_V TO AMD_READER_ROLE;

