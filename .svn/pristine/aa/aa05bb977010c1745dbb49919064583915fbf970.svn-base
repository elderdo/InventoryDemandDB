--      $Author$
--    $Revision$
--        $Date$
--    $Workfile$
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
