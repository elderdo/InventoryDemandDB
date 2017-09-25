CREATE OR REPLACE PROCEDURE AMD_OWNER.LOAD_AMD_ACTUAL_AC_USAGES
IS
   /* -----------------------------------------------------------
    * Program Name : AMD_OWNER.LOAD_AMD_ACTUAL_AC_USAGES
    * Version      : 1.0
    * Author       : Bob Menk
    * Created Date : June 30, 2017
    * Purpose      : This program inserts the last 6 full months of data from TMP_G081
    *                into AMD_ACTUAL_AC_USAGES.
    * 
    * This program performs :
    * 1) Evaluate the time frame of data to be deleted from AMD_ACTUAL_AC_USAGES
    * 2) Delete last 5 months of records from AMD_ACTUAL_AC_USAGES table.
    * 3) Insert only the last 6 full months of data into AMD_ACTUAL_AC_USAGES
    *
    * -----------------------------------------------------------
    * Modify by    Mod. Date   Changes
    * ---------    ---------   -------------------------------------
    * Bob Menk     30/Jun/17  Created this procedure based on ins_usages_from_g081.sql 
    *                         as part of converting the Load Oracle RMADS interface to
    *                         Oracle to Oracle processing
    */

   SDATE         DATE;
   EDATE         DATE;

   MAXOPDATE     DATE;
   LDMAXOPDATE   DATE;
   
   v_table_nm                        VARCHAR2(30) := 'AMD_ACTUAL_AC_USAGES';
   v_pkg_proc_nm                     VARCHAR2(30) := 'LOAD_AMD_ACTUAL_AC_USAGES';
   v_rows_deleted                    NUMBER := 0;
   v_flight_hour_rows_inserted       NUMBER := 0;
   v_hard_stop_rows_inserted         NUMBER := 0;
   v_landing_rows_inserted           NUMBER := 0;
   v_total_rows_inserted             NUMBER := 0;
   v_rows_updated                    NUMBER := 0;
   
BEGIN
   DBMS_OUTPUT.ENABLE (1000000);

   SELECT MAX (DAY_FLOWN),
          LAST_DAY (MAX (DAY_FLOWN)),
          ADD_MONTHS (LAST_DAY (MAX (DAY_FLOWN)), -6) + 1
     INTO MAXOPDATE, LDMAXOPDATE, SDATE
     FROM RMAD_OWNER.TMP_G081;

   IF MAXOPDATE = LDMAXOPDATE
   THEN
      EDATE := MAXOPDATE;
   ELSIF MAXOPDATE < LDMAXOPDATE
   THEN
      SELECT ADD_MONTHS (LAST_DAY (MAX (DAY_FLOWN)), -1),
             ADD_MONTHS (LAST_DAY (MAX (DAY_FLOWN)), -7) + 1
        INTO EDATE, SDATE
        FROM RMAD_OWNER.TMP_G081;
   END IF;

   --
   --   Delete last 6 months of the data from AMD_ACTUAL_AC_USAGES,
   --

   DELETE FROM AMD_ACTUAL_AC_USAGES
         WHERE EFFECTIVE_DATE >= SDATE;
         
   v_rows_deleted := SQL%ROWCOUNT;

   --
   --   Start loading data from TMP_G081 into AMD_ACTUAL_AC_USAGES
   --

   INSERT INTO AMD_ACTUAL_AC_USAGES (TAIL_NO,
                                     EFFECTIVE_DATE,
                                     USAGE,
                                     UOM_CODE,
                                     DW_LOAD_DT)
        SELECT A.TAIL_NO,
               LAST_DAY (DAY_FLOWN),
               SUM (NVL (FLY_HRS, 0) * (DECODE (ADD_DEL, 'DEL', -1, 1))),
               'FH',
               SYSDATE
          FROM RMAD_OWNER.TMP_G081 G, AMD_AIRCRAFTS A
         WHERE G.R_ID = A.AC_NO AND G.DAY_FLOWN BETWEEN SDATE AND EDATE
      GROUP BY A.TAIL_NO, LAST_DAY (DAY_FLOWN);
      
   v_flight_hour_rows_inserted := SQL%ROWCOUNT;
   DBMS_OUTPUT.PUT_LINE ('ins flight_hours: ' || v_flight_hour_rows_inserted);
   v_total_rows_inserted := v_flight_hour_rows_inserted;
      
   INSERT INTO AMD_ACTUAL_AC_USAGES (TAIL_NO,
                                     EFFECTIVE_DATE,
                                     USAGE,
                                     UOM_CODE,
                                     DW_LOAD_DT)
        SELECT A.TAIL_NO,
               LAST_DAY (DAY_FLOWN),
               SUM (NVL (FULL_STOP, 0) * (DECODE (ADD_DEL, 'DEL', -1, 1))),
               'HS',
               SYSDATE
          FROM RMAD_OWNER.TMP_G081 G, AMD_AIRCRAFTS A
         WHERE G.R_ID = A.AC_NO AND G.DAY_FLOWN BETWEEN SDATE AND EDATE
      GROUP BY A.TAIL_NO, LAST_DAY (DAY_FLOWN);
      
   v_hard_stop_rows_inserted := SQL%ROWCOUNT;
   DBMS_OUTPUT.PUT_LINE ('ins hard_stops: ' || v_hard_stop_rows_inserted);
   v_total_rows_inserted := v_total_rows_inserted + v_hard_stop_rows_inserted;

   INSERT INTO AMD_ACTUAL_AC_USAGES (TAIL_NO,
                                     EFFECTIVE_DATE,
                                     USAGE,
                                     UOM_CODE,
                                     DW_LOAD_DT)
        SELECT A.TAIL_NO,
               LAST_DAY (DAY_FLOWN),
               SUM (NVL (NBR_LDG, 0) * (DECODE (ADD_DEL, 'DEL', -1, 1))),
               'LD',
               SYSDATE
          FROM RMAD_OWNER.TMP_G081 G, AMD_AIRCRAFTS A
         WHERE G.R_ID = A.AC_NO AND G.DAY_FLOWN BETWEEN SDATE AND EDATE
      GROUP BY A.TAIL_NO, LAST_DAY (DAY_FLOWN);
      
   v_landing_rows_inserted := SQL%ROWCOUNT;
   DBMS_OUTPUT.PUT_LINE ('ins landings: ' || v_landing_rows_inserted);
   v_total_rows_inserted := v_total_rows_inserted + v_landing_rows_inserted;
   
   RMAD_OWNER.LOAD_BATCH_TBL_COUNTS (v_table_nm,
                          v_pkg_proc_nm,
                          v_rows_deleted,
                          v_total_rows_inserted,
                          v_rows_updated,
                          SYSDATE);
                          
   COMMIT;
   
END LOAD_AMD_ACTUAL_AC_USAGES;
/