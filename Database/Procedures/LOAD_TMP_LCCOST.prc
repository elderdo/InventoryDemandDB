CREATE OR REPLACE PROCEDURE AMD_OWNER.LOAD_TMP_LCCOST
IS
   /* -----------------------------------------------------------
    * Program Name : AMD_OWNER.LOAD_TMP_LCCOST
    * Version      : 1.0
    * Author       : Bob Menk
    * Created Date : June 29, 2017
    * Purpose      : Load AMD_OWNER.TMP_LCCOST from MATWEB01.C17_AEH_TBL
    *
    * Comment      :
    *
    * -----------------------------------------------------------
    * Modify by    Mod. Date   Changes
    * ---------    ---------   -------------------------------------
    * Bob Menk     29/Jun/17   Created this procedure based on 
    *                          MATWEB01.MONTHLY_PROCESSING_SQL
    *                          SQL_NAME = 'AMD_LCCOST' and lccost.ctl
    *                          when converting the monthly Load Oracle RMADS
    *                          interface to Oracle to Oracle processing
    */

   CURSOR c1
   IS
        SELECT A.FRACPR,
               A.DISC_DT,
               A.WUC,
               A.JCN,
               A.AJCN,
               A.PART_NBR AS PART_NUM,
               A.MID AS SHIP,
               TO_CHAR ( ( (A.STOP_DT - A.START_DT) * 24) * A.CREW, '90.99')
                  AS MANHOURS,
               A.FAC AS BASE,
               SYSDATE
          FROM C17_AEH_TBL@DEV_MATWEB.BOEINGDB A
         WHERE     A.RID = 'H'
               AND A.PART_NBR IS NOT NULL
               AND A.DISC_DT >= TO_DATE ('01/01/1998', 'MM/DD/YYYY')
               AND X_STATUS_CD IS NULL
               AND NVL (TPM, '%') NOT IN ('R', 'X', 'Z')
      ORDER BY DISC_DT,
               TRANSLATE (A.AJCN,
                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
               TRANSLATE (A.PART_NBR,
                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
               TRANSLATE (A.FRACPR,
                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
               TO_CHAR ( ( (A.STOP_DT - A.START_DT) * 24) * A.CREW, '90.99');

   TYPE c1_table_type IS TABLE OF c1%ROWTYPE;

   v_c1_table   c1_table_type;

   c1_rec       c1%ROWTYPE;
   
   v_table_nm        VARCHAR2(30) := 'TMP_LCCOST';
   v_pkg_proc_nm     VARCHAR2(30) := 'LOAD_TMP_LCCOST';
   v_rows_deleted    NUMBER := 0;
   v_rows_inserted   NUMBER := 0;
   v_rows_updated    NUMBER := 0;
   
BEGIN
   DBMS_OUTPUT.ENABLE (1000000);

   OPEN c1;

   LOOP
      FETCH c1 BULK COLLECT INTO v_c1_table LIMIT 100;

      FOR i IN 1 .. v_c1_table.COUNT
      LOOP
         c1_rec := v_c1_table (i);

         INSERT INTO TMP_LCCOST
              VALUES c1_rec;
              
          v_rows_inserted := v_rows_inserted + SQL%ROWCOUNT;
              
      END LOOP;

      EXIT WHEN c1%NOTFOUND;
   END LOOP;

   CLOSE c1;

   COMMIT;
   
   RMAD_OWNER.LOAD_BATCH_TBL_COUNTS (v_table_nm,
                          v_pkg_proc_nm,
                          v_rows_deleted,
                          v_rows_inserted,
                          v_rows_updated,
                          SYSDATE);
                          
   COMMIT;
   
END LOAD_TMP_LCCOST;
/
