CREATE OR REPLACE PACKAGE BODY amd_on_order_date_filters_pkg AS
/******************************************************************************
       $Author:   zf297a  $
     $Revision:   1.4  $
         $Date:   Jun 09 2006 12:34:12  $
     $Workfile:   AMD_ON_ORDER_DATE_FILTERS_PKG.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_ON_ORDER_DATE_FILTERS_PKG.pkb.-arc  $
/*   
/*      Rev 1.4   Jun 09 2006 12:34:12   zf297a
/*   implemented version
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


	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_on_order_date_filters_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	FUNCTION getOrderCreateDate(filter_name in amd_on_order_date_filters.FILTER_NAME%type, voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type) RETURN DATE IS
			 theDate date ;
	BEGIN
		 select order_create_date into theDate
		 from amd_on_order_date_filters
		 where filter_name = getOrderCreateDate.filter_name
		 and voucher_prefix = getOrderCreateDate.voucher_prefix ;
		 RETURN theDate ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getOrderCreateDate ;


	PROCEDURE setOrderCreateDate(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  					voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
								orderCreateDate IN amd_on_order_date_filters.ORDER_CREATE_DATE%type) IS
	BEGIN
		 update amd_on_order_date_filters
		 set order_create_date = orderCreateDate
		 where filter_name = setOrderCreateDate.filter_name
		 and voucher_prefix = setOrderCreateDate.voucher_prefix ;
	END setOrderCreateDate ;

	FUNCTION getScheduledReceiptDateFrom(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			 				voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type) RETURN DATE IS
			 theDate date ;
	BEGIN
		 select scheduled_receipt_date_from into theDate
		 from amd_on_order_date_filters
		 where filter_name = getScheduledReceiptDateFrom.filter_name
		 and voucher_prefix = getScheduledReceiptDateFrom.voucher_prefix ;
		 RETURN theDate ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getScheduledReceiptDateFrom ;

	FUNCTION getScheduledReceiptDateTo(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			 				voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type) RETURN DATE IS
			 theDate date ;
	BEGIN
		 select scheduled_receipt_date_to into theDate
		 from amd_on_order_date_filters
		 where filter_name = getScheduledReceiptDateTo.filter_name
		 and voucher_prefix = getScheduledReceiptDateTo.voucher_prefix ;
		 RETURN theDate ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getScheduledReceiptDateTo ;

	PROCEDURE setScheduledReceiptDates(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  							voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
										fromDate IN DATE, toDate DATE) IS
	BEGIN
		 update amd_on_order_date_filters
		 set scheduled_receipt_date_from = fromDate,
		 scheduled_receipt_date_to = toDate,
		 calendar_days = null
		 where filter_name = setScheduledReceiptDates.filter_name
		 and voucher_prefix = setScheduledReceiptDates.voucher_prefix ;
	END setScheduledReceiptDates ;

	PROCEDURE setScheduledReceiptDateCalDays(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  							voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
										calendar_days IN NUMBER) IS
	BEGIN
		 update amd_on_order_date_filters
		 set scheduled_receipt_date_from = null,
		 scheduled_receipt_date_to = null,
		 calendar_days = setScheduledReceiptDateCalDays.calendar_days
		 where filter_name = setScheduledReceiptDateCalDays.filter_name
		 and voucher_prefix = setScheduledReceiptDateCalDays.voucher_prefix ;
	END setScheduledReceiptDateCalDays ;

   	procedure getScheduledReceiptDateCalDays(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  							voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
										calendar_days out amd_on_order_date_filters.CALENDAR_DAYS%type) IS
	BEGIN
		 select calendar_days into calendar_days
		 from amd_on_order_date_filters
		 where filter_name = getScheduledReceiptDateCalDays.filter_name
		 and voucher_prefix = getScheduledReceiptDateCalDays.voucher_prefix ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		 calendar_days := null ;
	END getScheduledReceiptDateCalDays ;

	PROCEDURE getOnOrderDateFilters(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
			  orderCreateDate 		  OUT amd_on_order_date_filters.ORDER_CREATE_DATE%type,
			  schedReceiptDateFrom 	  OUT amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_FROM%type,
			  schedReceiptDateTo 	  OUT amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_TO%type,
			  schedReceiptCalDays 	  OUT amd_on_order_date_filters.CALENDAR_DAYS%type) is
	BEGIN
		 select order_create_date, scheduled_receipt_date_from, scheduled_receipt_date_to, calendar_days
		 into orderCreateDate, schedReceiptDateFrom, schedReceiptDateTo, schedReceiptCalDays
		 from amd_on_order_date_filters
		 where filter_name = getOnOrderDateFilters.filter_name
		 and voucher_prefix = getOnOrderDateFilters.voucher_prefix ;
	END getOnOrderDateFilters ;

	PROCEDURE setOnOrderDateFilters(filter_name in amd_on_order_date_filters.FILTER_NAME%type,
			  voucher_prefix IN amd_on_order_date_filters.VOUCHER_PREFIX%type,
			  orderCreateDate 		  in amd_on_order_date_filters.ORDER_CREATE_DATE%type,
			  schedReceiptDateFrom 	  in amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_FROM%type,
			  schedReceiptDateTo 	  in amd_on_order_date_filters.SCHEDULED_RECEIPT_DATE_TO%type,
			  schedReceiptCalDays 	  in amd_on_order_date_filters.CALENDAR_DAYS%type) is
	BEGIN
		 begin
			 insert into amd_on_order_date_filters
			 (filter_name, voucher_prefix, order_create_date, scheduled_receipt_date_from, scheduled_receipt_date_to, calendar_days)
			 values( filter_name, voucher_prefix, orderCreateDate, schedReceiptDateFrom, schedReceiptDateTo, schedReceiptCalDays) ;
		 exception when standard.DUP_VAL_ON_INDEX then
		 	 update amd_on_order_date_filters
			 set order_create_date = orderCreateDate,
			 scheduled_receipt_date_from = schedReceiptDateFrom,
			 scheduled_receipt_date_to = schedReceiptDateTo,
			 calendar_days = schedReceiptCalDays
			 where filter_name = setOnOrderDateFilters.filter_name
			 and voucher_prefix = setOnOrderDateFilters.voucher_prefix ;
		 end ;
	END setOnOrderDateFilters ;

	FUNCTION isVoucher(voucher IN VARCHAR2) RETURN BOOLEAN IS
			theVoucher VARCHAR2(2) ;
	BEGIN
		 SELECT DISTINCT SUBSTR(gold_order_number,1,2) INTO theVoucher FROM AMD_ON_ORDER
		 WHERE LOWER(SUBSTR(gold_order_number,1,2)) = LOWER(isVoucher.voucher) ;
		 RETURN TRUE ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		 RETURN FALSE ;
	END isVoucher ;

	PROCEDURE clearOnOrderParams(filter_name in amd_on_order_date_filters.FILTER_NAME%type) IS
	BEGIN
		 update amd_on_order_date_filters
		 set order_create_date = null,
		 scheduled_receipt_date_from = null,
		 scheduled_receipt_date_to = null,
		 calendar_days = null
		 where filter_name = clearOnOrderParams.filter_name ;
	END clearOnOrderParams ;

	FUNCTION numberOfOnOrderParams(filter_name in amd_on_order_date_filters.FILTER_NAME%type) RETURN NUMBER IS
			 cnt NUMBER ;
	BEGIN
		SELECT COUNT(*) INTO cnt FROM AMD_ON_ORDER_DATE_FILTERS where filter_name = numberOfOnOrderParams.filter_name ;
		RETURN cnt ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		RETURN 0 ;
	END numberOfOnOrderParams ;

	FUNCTION getVouchers RETURN ref_cursor IS
		 vouchers_cursor ref_cursor ;
	BEGIN
		 OPEN vouchers_cursor FOR
		 SELECT DISTINCT SUBSTR(gold_order_number,1,2) voucher
		 FROM AMD_ON_ORDER
		 ORDER BY voucher ;
		 RETURN vouchers_cursor ;
	END getVouchers ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_on_order_date_filters_pkg', 
		 		pError_location => 10, pKey1 => 'amd_on_order_date_filters_pkg', pKey2 => '$Revision:   1.4  $') ;
	end version ;

END amd_on_order_date_filters_pkg;
/
