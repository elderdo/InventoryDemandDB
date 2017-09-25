--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:56  $
--    $Workfile:   BomDetail.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.bom_detail

LOAD DATA
infile '/apps/CRON/AMD/data/BomDetail.csv'
Append INTO TABLE spoc17v2.X_IMP_BOM_DETAIL
fields terminated by "," optionally enclosed by '"'
(BOM,
 PART,
 INCLUDED_PART,
 quantity,
 begin_date nullif (begin_date="null"),
 end_date nullif (end_date="null"),
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
