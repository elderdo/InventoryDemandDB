DROP FUNCTION AMD_OWNER.GETDUEDATE;

CREATE OR REPLACE FUNCTION AMD_OWNER.getDueDate(part_no in AMD_ON_ORDER.PART_NO%TYPE, order_date in AMD_ON_ORDER.ORDER_DATE%TYPE)  RETURN DATE IS
     
               order_lead_time AMD_SPARE_PARTS.ORDER_LEAD_TIME%TYPE ;
              order_lead_time_defaulted AMD_SPARE_PARTS.ORDER_LEAD_TIME_DEFAULTED%TYPE ;
              order_lead_time_cleaned AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE ;
     BEGIN
          <<getOrderLeadTime>>
           BEGIN
                  SELECT order_lead_time, order_lead_time_defaulted INTO order_lead_time, order_lead_time_defaulted FROM AMD_SPARE_PARTS WHERE part_no = getDueDate.part_no ;
          EXCEPTION WHEN standard.NO_DATA_FOUND THEN
                 order_lead_time := NULL ;
          END getOrderLeadTime ;
          
          <<getOrderLeadTimeCleaned>>
          BEGIN
                 SELECT order_lead_time_cleaned INTO order_lead_time_cleaned FROM AMD_NATIONAL_STOCK_ITEMS items, AMD_SPARE_PARTS parts WHERE parts.part_no = getDueDate.part_no AND parts.nsn = items.nsn ;
          EXCEPTION WHEN standard.NO_DATA_FOUND THEN
                 order_lead_time_cleaned := NULL ;       
          END getOrderLeadTimeCleaned ;
          
          RETURN getDueDate.order_date + Amd_Preferred_Pkg.GetPreferredValue(order_lead_time_cleaned, order_lead_time, NVL(order_lead_time_defaulted,1)) ;
      
     END getDueDate ;
/


DROP PUBLIC SYNONYM GETDUEDATE;

CREATE OR REPLACE PUBLIC SYNONYM GETDUEDATE FOR AMD_OWNER.GETDUEDATE;


GRANT EXECUTE ON AMD_OWNER.GETDUEDATE TO AMD_ADMIN;

GRANT EXECUTE ON AMD_OWNER.GETDUEDATE TO AMD_DATALOAD;

GRANT EXECUTE ON AMD_OWNER.GETDUEDATE TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.GETDUEDATE TO AMD_USER;

GRANT EXECUTE ON AMD_OWNER.GETDUEDATE TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.GETDUEDATE TO BSRM_LOADER;

