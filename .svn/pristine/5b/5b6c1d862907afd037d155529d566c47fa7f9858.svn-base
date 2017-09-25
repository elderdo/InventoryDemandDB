--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:27:00  $
--    $Workfile:   NetworkPart.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

LOAD DATA
infile '/apps/CRON/AMD/data/NetworkPart.csv'
Append INTO TABLE spoc17v2.X_IMP_NETWORK_PART
fields terminated by "," optionally enclosed by '"'
(PART,
 NETWORK,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
