-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run rspSumDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready rspSumDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE UNLIMITED

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



prompt rows in amd_rsp_sum 
select count(*) from amd_rsp_sum where action_code <> 'D';

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
        SELECT spo_prime_part_no part_no,
               (mob) || '_RSP' rsp_location,
               CASE
                  WHEN amd_utils.isPartRepairableYorN (spo_prime_part_no) = 'Y'
                  THEN
                     'TSL Fixed'
                  ELSE
                     'ROP Fixed'
               END
                  override_type,
               SUM (rsp_inv) qty_on_hand,
               SUM (rsp_level) rsp_level
          FROM AMD_RSP a, AMD_SENT_TO_A2A b, AMD_SPARE_NETWORKS c
         WHERE     a.loc_sid = c.loc_sid
               AND a.part_no = b.part_no
               AND a.action_code != 'D'
               AND b.action_code != 'D'
               AND c.mob IS NOT NULL
               AND spo_prime_part_no IS NOT NULL
               AND (   amd_utils.isPartRepairableYorN (spo_prime_part_no) = 'Y'
                    OR amd_utils.isPartConsumableYorN (spo_prime_part_no) = 'Y')
      GROUP BY spo_prime_part_no, c.mob
      ORDER BY spo_prime_part_no;

   CURSOR deleteRecs
   IS
      SELECT part_no,
             rsp_location,
             override_type,
             qty_on_hand,
             rsp_level
        FROM amd_rsp_sum cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (  SELECT spo_prime_part_no part_no,
                                          (mob) || '_RSP' rsp_location,
                                          CASE
                                             WHEN amd_utils.isPartRepairableYorN (
                                                     spo_prime_part_no) = 'Y'
                                             THEN
                                                'TSL Fixed'
                                             ELSE
                                                'ROP Fixed'
                                          END
                                             override_type,
                                          SUM (rsp_inv) qty_on_hand,
                                          SUM (rsp_level) rsp_level
                                     FROM AMD_RSP a,
                                          AMD_SENT_TO_A2A b,
                                          AMD_SPARE_NETWORKS c
                                    WHERE     a.loc_sid = c.loc_sid
                                          AND a.part_no = b.part_no
                                          AND a.action_code != 'D'
                                          AND b.action_code != 'D'
                                          AND c.mob IS NOT NULL
                                          AND spo_prime_part_no IS NOT NULL
                                          AND (   amd_utils.isPartRepairableYorN (
                                                     spo_prime_part_no) = 'Y'
                                               OR amd_utils.isPartConsumableYorN (
                                                     spo_prime_part_no) = 'Y')
                                 GROUP BY spo_prime_part_no, c.mob) rspSum
                          WHERE     rspSum.part_no = cur.part_no
                                AND rspSum.rsp_location = cur.rsp_location
                                AND rspSum.override_type = cur.override_type)
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
         partNo          amd_rsp_sum.part_no%TYPE,
         rspLocation     amd_rsp_sum.rsp_location%TYPE,
         overrideType    amd_rsp_sum.override_type%TYPE)
      IS
           SELECT *
             FROM amd_rsp_sum
            WHERE     action_code != 'D'
                  AND part_no = partNo
                  AND rsp_location = rspLocation
                  AND override_type = overrideType
         ORDER BY part_no, rsp_location, override_type;

      result   BOOLEAN := FALSE;
      cnt      NUMBER := 0;
   BEGIN
      FOR oldRec
         IN curRecs (newRec.part_no,
                     newRec.rsp_location,
                     newRec.override_type)
      LOOP
         result := amd_utils.isDiff (newRec.qty_on_hand, oldRec.qty_on_hand);
         result :=
            result OR amd_utils.isDiff (newRec.rsp_level, oldRec.rsp_level);

         cnt := cnt + 1;
      END LOOP;

      IF cnt = 0 OR cnt > 1
      THEN
         DBMS_OUTPUT.put_line (
               'diff error:part_no='
            || newRec.part_no
            || ' rsp_location='
            || newRec.rsp_location
            || ' override_type='
            || newRec.override_type
            || ' cnt='
            || cnt);
         diffError := TRUE;
      END IF;

      RETURN result;
   END isDiff;

   FUNCTION isInsert (partNo          amd_rsp_sum.part_no%TYPE,
                      rspLocation     amd_rsp_sum.rsp_location%TYPE,
                      overrideType    amd_rsp_sum.override_type%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_rsp_sum
          WHERE     part_no = partNo
                AND rsp_location = rspLocation
                AND override_type = overrideType
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
      RETURN amd_inventory.doRspSumDiff (rec.part_no,
                                         rec.rsp_location,
                                         rec.override_type,
                                         rec.qty_on_hand,
                                         rec.rsp_level,
                                         'A');
   END insertRow;

   FUNCTION updateRow (rec newRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.doRspSumDiff (rec.part_no,
                                         rec.rsp_location,
                                         rec.override_type,
                                         rec.qty_on_hand,
                                         rec.rsp_level,
                                         'C');
   END updateRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_inventory.doRspSumDiff (rec.part_no,
                                         rec.rsp_location,
                                         rec.override_type,
                                         rec.qty_on_hand,
                                         rec.rsp_level,
                                         'D');
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.part_no, newRec.rsp_location, newRec.override_type)
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

prompt rows inserted into amd_rsp_sum 
select count(*) from amd_rsp_sum where action_code  = 'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows updated for amd_rsp_sum 
select count(*) from amd_rsp_sum where action_code  = 'C' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_rsp_sum 
select count(*) from amd_rsp_sum where action_code  = 'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_rsp_sum 
select count(*) from amd_rsp_sum where action_code  <> 'D';

PROMPT end rspSumDiff.sql
EXIT :rc
