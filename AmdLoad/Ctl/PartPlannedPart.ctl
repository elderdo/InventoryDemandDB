--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:27:00  $
--    $Workfile:   PartPlannedPart.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

LOAD DATA
infile '/apps/CRON/AMD/data/PartPlannedPart.csv'
Append INTO TABLE spoc17v2.X_IMP_PART_PLANNED_PART
fields terminated by "," optionally enclosed by '"'
(PART,
 PLANNED_PART,
 SPO_USER,
 SUPERSESSION_TYPE,
 BEGIN_DATE,
 END_DATE,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
