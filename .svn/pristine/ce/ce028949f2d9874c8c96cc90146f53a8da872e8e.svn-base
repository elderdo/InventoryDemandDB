--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:56  $
--    $Workfile:   ConfirmedRequest.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

LOAD DATA
infile '/apps/CRON/AMD/data/ConfirmedRequest.csv'
Append INTO TABLE spoc17v2.X_IMP_CONFIRMED_REQUEST
fields terminated by "," optionally enclosed by '"'
(NAME,
 REQUEST_TYPE,
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
