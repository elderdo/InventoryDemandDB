--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:56  $
--    $Workfile:   BomLocationContract.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.bom_location_contract

LOAD DATA
infile '/apps/CRON/AMD/data/BomLocationContract.csv'
Append INTO TABLE spoc17v2.X_IMP_BOM_LOCATION_CONTRACT
fields terminated by "," optionally enclosed by '"'
(LOCATION,
 BOM,
 CONTRACT,
 CONTRACT_TYPE,
 CUSTOMER_LOCATION,
 BEGIN_DATE,
 END_DATE,
 QUANTITY,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
