--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:27:02  $
--    $Workfile:   UserUserType.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.user_user_type

LOAD DATA
infile '/apps/CRON/AMD/data/UserUserType.csv'
Append INTO TABLE spoc17v2.X_IMP_USER_USER_TYPE
fields terminated by "," optionally enclosed by '"'
(SPO_USER,
 USER_TYPE NULLIF (USER_TYPE="null"),
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
