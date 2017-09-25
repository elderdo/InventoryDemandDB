--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   LpLeadTime.ctl  $

LOAD DATA
infile '/apps/CRON/AMD/data/LpLeadTime.csv'
Append INTO TABLE spoc17v2.X_IMP_LP_LEAD_TIME
fields terminated by "," optionally enclosed by '"'
(LOCATION,
 PART,
 LEAD_TIME_TYPE,
 QUANTITY NULLIF (QUANTITY="null") ,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
