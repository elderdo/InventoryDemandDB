CREATE OR REPLACE package body amd_maintenance_pkg is
	   -- likely called with sysdate and done once for the year,
	   -- the year is what is important for pReferenceDate for this set up.
	   --
	   -- goes 4 years back from oct of that year till
	   -- 5 years forward till sept of that year.


	 procedure loadAmdTimePeriods(pReferenceDate date)
	 is
	     lastSecInDay constant number := (24*60*60 -1)/(24*60*60);
	   	 monthsHistory constant integer := 48;
		 monthsFuture constant integer := 60;
	     tpStart date;
	     tpEnd date;
	   	 bucketId int;
	   	 startDate date;
	   	 endDate date;
	 begin
	 	  startDate := to_date( ('01-Oct-' || to_char(add_months(pReferenceDate, -monthsHistory), 'YYYY') ), 'DD-MON-YYYY');
		  endDate := to_date( ('01-Sep-' ||  to_char(add_months(pReferenceDate,  monthsFuture ), 'YYYY') ), 'DD-MON-YYYY');
		  for i in 0 .. months_between(endDate, startDate) loop
	      	  bucketId := i + 1;
	     	  tpStart := trunc(add_months(startDate, i));
			  tpEnd := trunc(add_months(startDate, i+1) - 1) + lastSecInDay;
	    	  insert into amd_time_periods (
			       time_period_start,
			       time_period_end,
			       tactical_bucket_name,
			       tactical_bucket_id,
			       action_code,
			       last_update_dt)
			  values (
			  	   tpStart,
	               tpEnd,
	               'FORECAST_BUCKET',
	               bucketId,
	               'A',
	               sysdate
	           );
	      end loop;
		  commit;
	 end loadAmdTimePeriods;
end amd_maintenance_pkg;
/

