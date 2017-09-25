--      $Author:   zf297a  $
--    $Revision:   1.3  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   LpDemand.ctl  $

LOAD DATA
infile '/apps/CRON/AMD/data/LpDemand.csv'
Append INTO TABLE spoc17v2.X_IMP_LP_DEMAND
fields terminated by "," optionally enclosed by '"'
(TRANSACTION_ID,
 LOCATION,
 PART,
 CONTRACT,
 DEMAND_TYPE,
 DEMAND_DATE,
 CUSTOMER_LOCATION NULLIF (CUSTOMER_LOCATION="null") ,
 PRODUCT_SERIAL_NUMBER NULLIF (PRODUCT_SERIAL_NUMBER="null"),
 QUANTITY,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
