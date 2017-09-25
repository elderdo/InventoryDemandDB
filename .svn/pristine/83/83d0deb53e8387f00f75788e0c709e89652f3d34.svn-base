--      $Author:   zf297a  $
--    $Revision:   1.0  $
--        $Date:   29 Jun 2011 18:56 $
--    $Workfile:   VendorMaster.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

OPTIONS (SKIP=1)
LOAD DATA
infile '/apps/CRON/AMD/data/VendorMaster.csv'
Append INTO TABLE amd_owner.vendor_master
fields terminated by "," optionally enclosed by '"'
(DUPS,
 PO_DATE DATE "MM/DD/YYYY HH24:MI:SS",
 PURCHASE_ORDERS,
 PO_SUFX,
 ITEM_NO,
 PART_NUMBER,
 PART_NAME,
 SUPPLIER_NO,
 SUPPLIER_NAME
)
