DROP PACKAGE AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_on_order_date_filters_pkg AS
/******************************************************************************
       $Author:   zf297a  $
     $Revision:   1.4  $
         $Date:   Jun 09 2006 12:34:00  $
     $Workfile:   AMD_ON_ORDER_DATE_FILTERS_PKG.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_ON_ORDER_DATE_FILTERS_PKG.pks.-arc  $
/*
/*      Rev 1.4   Jun 09 2006 12:34:00   zf297a
/*   added interface version
/*
/*      Rev 1.3   May 17 2006 14:58:36   zf297a
/*   removed start_date - not needed
/*
/*      Rev 1.2   May 17 2006 14:21:24   zf297a
/*   Added setScheduledReceiptDateCalDays and
/*   getScheduledReceiptDateCalDays
/*
/*      Rev 1.1   May 17 2006 13:25:08   zf297a
/*   Implemented procedures and functions using amd_on_order_date_filters table.
/*
/*      Rev 1.0   May 17 2006 12:24:26   zf297a
/*   Initial revision.
******************************************************************************/

	sched_receipt_date_exception EXCEPTION ;

	FUNCTION getOrderCreateDate(filter_name in amd_on_order_date_filters.FILTER_NAME%type, voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type) RETURN DATE ;
	PROCEDURE setOrderCreateDate(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  					voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
								orderCreateDate IN amd_on_order_date_filters.ORDER_CREATE_DATE%type) ;

	FUNCTION getScheduledReceiptDateFrom(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			 				voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type) RETURN DATE ;

	FUNCTION getScheduledReceiptDateTo(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			 				voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type) RETURN DATE ;

	PROCEDURE setScheduledReceiptDates(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  							voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
										fromDate IN DATE, toDate DATE) ;

	procedure getScheduledReceiptDateCalDays(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  							voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
										calendar_days out amd_on_order_date_filters.CALENDAR_DAYS%type ) ;

	PROCEDURE setScheduledReceiptDateCalDays(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  							voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
										calendar_days IN NUMBER) ;

	PROCEDURE getOnOrderDateFilters(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
			  orderCreateDate 		  OUT amd_on_order_date_filters.ORDER_CREATE_DATE%type,
			  schedReceiptDateFrom 	  OUT amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_FROM%type,
			  schedReceiptDateTo 	  OUT amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_TO%type,
			  schedReceiptCalDays 	  OUT amd_on_order_date_filters.CALENDAR_DAYS%type) ;

	PROCEDURE setOnOrderDateFilters(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
			  orderCreateDate 		  in amd_on_order_date_filters.ORDER_CREATE_DATE%type,
			  schedReceiptDateFrom 	  in amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_FROM%type,
			  schedReceiptDateTo 	  in amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_TO%type,
			  schedReceiptCalDays 	  in amd_on_order_date_filters.CALENDAR_DAYS%type) ;

	FUNCTION isVoucher(voucher IN VARCHAR2) RETURN BOOLEAN ;
	PROCEDURE clearOnOrderParams(filter_name in amd_on_order_date_filters.FILTER_NAME%type) ;
	FUNCTION numberOfOnOrderParams(filter_name in amd_on_order_date_filters.FILTER_NAME%type) RETURN NUMBER ;
	TYPE ref_cursor IS REF CURSOR ;
	FUNCTION getVouchers RETURN ref_cursor ;

	-- added 6/9/2006 by dse
	procedure version ;

END amd_on_order_date_filters_pkg;
 
/


DROP PUBLIC SYNONYM AMD_ON_ORDER_DATE_FILTERS_PKG;

CREATE PUBLIC SYNONYM AMD_ON_ORDER_DATE_FILTERS_PKG FOR AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_PKG TO AMD_WRITER_ROLE;
