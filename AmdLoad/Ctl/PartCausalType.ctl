--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:27:00  $
--    $Workfile:   PartCausalType.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.part_causal_type

LOAD DATA
infile '/apps/CRON/AMD/data/PartCausalType.csv'
Append INTO TABLE spoc17v2.X_IMP_PART_CAUSAL_TYPE
fields terminated by "," optionally enclosed by '"'
(PART,
CAUSAL_TYPE,
 QUANTITY,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
