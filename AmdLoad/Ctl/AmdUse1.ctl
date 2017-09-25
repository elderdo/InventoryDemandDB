--      $Author:   zf297a  $
--    $Revision:   1.0  $
--        $Date:   19 Sep 2008 09:26:58  $
--    $Workfile:   AmdUse1.ctl  $
--    Load users to the amd_use1 table

LOAD DATA
infile '/apps/CRON/AMD/data/AmdUse1.txt'
Append INTO TABLE amd_owner.amd_use1
fields terminated by "," optionally enclosed by '"'
(USERID,
 USER_NAME,
 EMPLOYEE_NO,
 PHONE,
 IMS_DESIGNATOR_CODE,
 EMPLOYEE_STATUS,
 LAST_UPDATE_DT  SYSDATE
)
