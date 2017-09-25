/* Formatted on 1/25/2017 4:12:34 PM (QP5 v5.287) */
/*
      $Author:   zf297a  $
    $Revision:   1.5  $
        $Date:   27 Sep 2013 
    $Workfile:   updateAmdAllBaseCleaned.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\updateAmdAllBaseCleaned.sql.-arc  $
/*   
/*      Rev 1.5   27 Sep 2013    zf297a
/*       simplify retries using a loop
/*
/*      Rev 1.4   07 Aug 2009 11:54:52   zf297a
/*   Use new common sleep procedure
/*   
/*      Rev 1.3   15 Jun 2009 10:40:32   zf297a
/*   Fixed sleep procedure - add the number of seconds to sleep to the current date/time giving the end_date_time, then loop while the current date/time is less than the end_date_time.
/*   
/*   Add some start/stop times for the sleep procedure so we can see when it does get executed.
/*   
/*      Rev 1.2   13 Oct 2008 11:30:56   zf297a
/*   Fixed DEADLOCK constant .. should be negative for all sqlcodes except data not found which is +100 and +1 for user defined exceptions.
/*   
/*      Rev 1.1   20 Aug 2008 01:01:58   zf297a
/*   Add a check for a potential deadlock condition and sleep for a few seconds and try again.
/*   
/*      Rev 1.0   19 Jun 2008 10:25:54   zf297a
/*   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO OFF
SET FEEDBACK OFF

VARIABLE ret_val NUMBER

SET SERVEROUTPUT ON SIZE 100000

DECLARE
   executed            BOOLEAN := FALSE;
   cnt                 NUMBER := 0;
   DEADLOCK   CONSTANT NUMBER := -60;
BEGIN
   :ret_val := 4;

   LOOP
      cnt := cnt + 1;

      BEGIN
         amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned;
         DBMS_OUTPUT.put_line (
            'amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned executed successfully');
         executed := TRUE;
         :ret_val := 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = DEADLOCK
            THEN
               sleep (20);
            ELSE
               RAISE;
            END IF;
      END;

      EXIT WHEN executed OR cnt >= 6;
   END LOOP;

   IF :ret_val <> 0
   THEN
      DBMS_OUTPUT.put_line (
         'Error: amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned failed to execute');
   END IF;
END;
/

@@analyzeAmdPartLocs.sql


EXIT :ret_val
