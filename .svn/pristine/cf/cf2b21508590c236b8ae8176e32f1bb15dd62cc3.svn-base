--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   LPOverrideLoad.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_override

LOAD DATA
infile '/apps/CRON/AMD/data/LpOverride.csv'
Append INTO TABLE spoc17v2.X_IMP_LP_OVERRIDE
fields terminated by "," optionally enclosed by '"'
(PART,
 LOCATION,
 OVERRIDE_TYPE,
 OVERRIDE_USER,
 QUANTITY,
 OVERRIDE_REASON,
 BEGIN_DATE,
 END_DATE,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
