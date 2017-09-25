--      $Author:   zf297a  $
--    $Revision:   1.0  $
--        $Date:   11 Feb 2010 10:33  $
--    $Workfile:   UserUserTypeRestore.ctl  $
--    Load data to the SPO from a csv file 
--    target table spoc17v2.user_user_type

OPTIONS (SKIP=1)
LOAD DATA
infile '/apps/CRON/AMD/data/UserUserTypeDump.csv'
Append INTO TABLE spoc17v2.USER_USER_TYPE
fields terminated by "," optionally enclosed by '"'
(SPO_USER,
 USER_TYPE NULLIF (USER_TYPE="null"),
 LAST_MODIFIED "to_date(:last_modified,'MM-DD-YYYY HH24:MI:SS')"
)

