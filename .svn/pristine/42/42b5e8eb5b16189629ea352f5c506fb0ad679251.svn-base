--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:27:00  $
--    $Workfile:   SpoPartLeadTime.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.part_lead_time

LOAD DATA
infile '/apps/CRON/AMD/data/SpoPartLeadTime.csv'
Append INTO TABLE spoc17v2.X_IMP_PART_LEAd_TIME
fields terminated by "," optionally enclosed by '"'
(part,
 lead_time_type,
quantity,
variance,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
