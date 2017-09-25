--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   LpInTransit.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

LOAD DATA
infile '/apps/CRON/AMD/data/LpInTransit.csv'
Append INTO TABLE spoc17v2.X_IMP_LP_IN_TRANSIT
fields terminated by "," optionally enclosed by '"'
(PART,
 LOCATION,
 IN_TRANSIT_TYPE,
 QUANTITY,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
