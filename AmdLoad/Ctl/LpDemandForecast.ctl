--      $Author:   zf297a  $
--    $Revision:   1.2  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   LpDemandForecast.ctl  $

LOAD DATA
infile '/apps/CRON/AMD/data/LpDemandForecast.csv'
Append INTO TABLE spoc17v2.X_IMP_LP_DEMAND_FORECAST
fields terminated by "," optionally enclosed by '"'
( LOCATION,
 PART,
 DEMAND_FORECAST_TYPE,
 PERIOD,
 QUANTITY,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
