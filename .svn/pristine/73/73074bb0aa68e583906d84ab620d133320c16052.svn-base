--      $Author:   zf297a  $
--    $Revision:   1.1  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   ConfirmedRequestLine.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_in_transit

LOAD DATA
infile '/apps/CRON/AMD/data/ConfirmedRequestLine.csv'
Append INTO TABLE spoc17v2.X_IMP_CONFIRMED_REQUEST_LINE
fields terminated by "," optionally enclosed by '"'
(CONFIRMED_REQUEST,
 LINE,
 LOCATION,
 PART,
 PROPOSED_REQUEST NULLIF (PROPOSED_REQUEST="null"),
 REQUEST_DATE,
 DUE_DATE,
 QUANTITY_ORDERED,
 QUANTITY_RECEIVED,
 REQUEST_STATUS,
 SUPPLIER_LOCATION NULLIF (SUPPLIER_LOCATION="null"),
 ATTRIBUTE_1 NULLIF (ATTRIBUTE_1="null"),
 ATTRIBUTE_2 NULLIF (ATTRIBUTE_2="null"),
 ATTRIBUTE_3 NULLIF (ATTRIBUTE_3="null"),
 ATTRIBUTE_4 NULLIF (ATTRIBUTE_4="null"),
 ATTRIBUTE_5 NULLIF (ATTRIBUTE_5="null"),
 ATTRIBUTE_6 NULLIF (ATTRIBUTE_6="null"),
 ATTRIBUTE_7 NULLIF (ATTRIBUTE_7="null"),
 ATTRIBUTE_8 NULLIF (ATTRIBUTE_8="null"),
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
