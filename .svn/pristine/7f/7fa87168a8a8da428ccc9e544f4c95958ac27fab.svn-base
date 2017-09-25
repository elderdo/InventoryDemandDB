--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:27:00  $
--    $Workfile:   PartMtbf.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

LOAD DATA
infile '/apps/CRON/AMD/data/PartMtbf.csv'
Append INTO TABLE spoc17v2.X_IMP_PART_MTBF
fields terminated by "," optionally enclosed by '"'
(PART,
 MTBF_TYPE,
 quantity,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
