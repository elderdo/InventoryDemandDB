-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run inTransitSumDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready inTransitSumDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 100000

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE


VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT part_no,
               Amd_Utils.getSpoLocation (to_loc_sid) site_location,
               SUM (quantity) quantity,
               serviceable_flag
          FROM tmp_amd_in_transits
         WHERE amd_utils.getSpoLocation (to_loc_sid) IS NOT NULL
      GROUP BY part_no,
               Amd_Utils.getSpoLocation (to_loc_sid),
               serviceable_flag;

   CURSOR deleteRecs
   IS
      SELECT part_no, site_location, serviceable_flag
        FROM amd_in_transits_sum cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (  SELECT part_no,
                                          Amd_Utils.getSpoLocation (to_loc_sid)
                                             site_location,
                                          SUM (quantity) quantity,
                                          serviceable_flag
                                     FROM tmp_amd_in_transits
                                    WHERE amd_utils.getSpoLocation (to_loc_sid)
                                             IS NOT NULL
                                 GROUP BY part_no,
                                          Amd_Utils.getSpoLocation (
                                             to_loc_sid),
                                          serviceable_flag) inTransitsSum
                          WHERE     inTransitsSum.part_no = cur.part_no
                                AND inTransitsSum.site_location =
                                       cur.site_location
                                AND inTransitsSum.serviceable_flag =
                                       cur.serviceable_flag)
             AND action_code <> 'D';

   updateCnt      NUMBER := 0;
   updateErrCnt   NUMBER := 0;
   insertCnt      NUMBER := 0;
   insertErrCnt   NUMBER := 0;
   deleteCnt      NUMBER := 0;
   deleteErrCnt   NUMBER := 0;
   diffError      BOOLEAN := FALSE;
   newCnt         NUMBER := 0;


   FUNCTION isDiff (newRec newRecs%ROWTYPE)
      RETURN BOOLEAN
   IS
      CURSOR curRecs (
         partNo             amd_in_transits_sum.part_no%TYPE,
         siteLocation       amd_in_transits_sum.site_location%TYPE,
         serviceableFlag    amd_in_transits_sum.serviceable_flag%TYPE)
      IS
           SELECT *
             FROM amd_in_transits_sum
            WHERE     action_code != 'D'
                  AND part_no = partNo
                  AND site_location = siteLocation
                  AND serviceable_flag = serviceableFlag
         ORDER BY part_no, site_location;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec
         IN curRecs (newRec.part_no,
                     newRec.site_location,
                     newRec.serviceable_flag)
      LOOP
         result := amd_utils.isDiff (newRec.quantity, oldRec.quantity);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error:part_no='
            || newRec.part_no
            || ' site_location='
            || newRec.site_location
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (
      partNo             amd_in_transits_sum.part_no%TYPE,
      siteLocation       amd_in_transits_sum.site_location%TYPE,
      serviceableFlag    amd_in_transits_sum.serviceable_flag%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_in_transits_sum
          WHERE     part_no = partNo
                AND site_location = siteLocation
                AND serviceable_flag = serviceableFlag
                AND action_code <> 'D';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            result := TRUE;
      END;

      RETURN result;
   END isInsert;

   FUNCTION insertRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.insertRow (rec.part_no,
                                      rec.site_location,
                                      rec.quantity,
                                      rec.serviceable_flag);
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.updateRow (rec.part_no,
                                      rec.site_location,
                                      rec.quantity,
                                      rec.serviceable_flag);
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.deleteRow (rec.part_no,
                                      rec.site_location,
                                      rec.serviceable_flag);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.part_no,
                   newRec.site_location,
                   newRec.serviceable_flag)
      THEN
         IF insertRow (newRec) = 0
         THEN
            insertCnt := insertCnt + 1;
         ELSE
            insertErrCnt := insertErrCnt + 1;
         END IF;
      ELSIF isDiff (newRec)
      THEN
         IF updateRow (newRec) = 0
         THEN
            updateCnt := updateCnt + 1;
         ELSE
            updateErrCnt := updateErrCnt + 1;
         END IF;
      END IF;
   END LOOP;

   FOR rec IN deleteRecs
   LOOP
      IF deleteRow (rec) = 0
      THEN
         deleteCnt := deleteCnt + 1;
      ELSE
         deleteErrCnt := deleteErrCnt + 1;
      END IF;
   END LOOP;

   DBMS_OUTPUT.put_line ('newCnt=' || newCnt);

   DBMS_OUTPUT.put_line ('insertCnt=' || insertCnt);

   IF insertErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('insertErrCnt=' || insertErrCnt);
   END IF;

   DBMS_OUTPUT.put_line ('updateCnt=' || updateCnt);

   IF updateErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('updateErrCnt=' || updateErrCnt);
   END IF;


   DBMS_OUTPUT.put_line ('deleteCnt=' || deleteCnt);

   IF deleteErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('deleteErrCnt=' || deleteErrCnt);
   END IF;

   IF insertErrCnt > 0 OR updateErrCnt > 0 OR deleteErrCnt > 0 OR diffError
   THEN
      :rc := 4;
   ELSE
      :rc := 0;
   END IF;
END;
/

PROMPT end inTransitSumDiff.sql
EXIT :rc
