-- vim: ff=unix:ts=2:sw=2:sts=2:et:
PROMPT run plannerLogonsDiff.sql
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
SET SQLBLANKLINES ON
SET SQLTERMINATOR ';'
SHOW SQLTERMINATOR
SHOW SQLBLANKLINES
PROMPT ready plannerLogonsDiff.sql
SET ECHO ON
SET TIME ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 100000

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



var v_now varchar2(30)

exec :v_now := to_char(sysdate,'MM/DD/YYYY HH:MI:SS PM');



prompt rows in amd_planner_logons 
select count(*) from amd_planner_logons where action_code <> 'D';

VARIABLE rc NUMBER


DECLARE
   CURSOR newRecs
   IS
      SELECT DISTINCT
             ims_designator_code planner_code,
             amd_load.getBemsId (employee_no) logon_id,
             '1' data_source
        FROM amd_use1
       WHERE     employee_status = 'A'
             AND LENGTH (ims_designator_code) = 3
             AND amd_load.getBemsId (employee_no) IS NOT NULL
      UNION
      SELECT designator_code planner_code,
             amd_load.getBemsId (userid) logon_id,
             '2' data_source
        FROM uims
       WHERE     LENGTH (designator_code) = 3
             AND amd_load.getBemsId (userid) IS NOT NULL
             AND UPPER (ALT_IMS_DES_CODE_B) = 'T'
      UNION
      SELECT planner_code, logon_id, data_source
        FROM amd_default_planner_logons_v
      ORDER BY planner_code, logon_id, data_source;

   CURSOR deleteRecs
   IS
      SELECT planner_code, logon_id, data_source
        FROM amd_planner_logons cur
       WHERE     NOT EXISTS
                        (SELECT NULL
                           FROM (SELECT DISTINCT
                                        ims_designator_code planner_code,
                                        amd_load.getBemsId (employee_no)
                                           logon_id,
                                        '1' data_source
                                   FROM amd_use1
                                  WHERE     employee_status = 'A'
                                        AND LENGTH (ims_designator_code) = 3
                                        AND amd_load.getBemsId (employee_no)
                                               IS NOT NULL
                                 UNION
                                 SELECT designator_code planner_code,
                                        amd_load.getBemsId (userid) logon_id,
                                        '2' data_source
                                   FROM uims
                                  WHERE     LENGTH (designator_code) = 3
                                        AND amd_load.getBemsId (userid)
                                               IS NOT NULL
                                        AND UPPER (ALT_IMS_DES_CODE_B) = 'T'
                                 UNION
                                 SELECT planner_code, logon_id, data_source
                                   FROM amd_default_planner_logons_v)
                                plannerLogons
                          WHERE     plannerLogons.planner_code =
                                       cur.planner_code
                                AND plannerLogons.logon_id = cur.logon_id
                                AND plannerLogons.data_source =
                                       cur.data_source)
             AND action_code <> 'D';

   insertCnt      NUMBER := 0;
   insertErrCnt   NUMBER := 0;
   deleteCnt      NUMBER := 0;
   deleteErrCnt   NUMBER := 0;
   newCnt         NUMBER := 0;



   FUNCTION isInsert (plannerCode    amd_planner_logons.planner_code%TYPE,
                      logonId        amd_planner_logons.logon_id%TYPE,
                      dataSource     amd_planner_logons.data_source%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      hit      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO hit
           FROM amd_planner_logons
          WHERE     planner_code = plannerCode
                AND logon_id = logonId
                AND data_source = dataSource
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
      RETURN amd_load.insertPlannerLogons (rec.planner_code,
                                           rec.logon_id,
                                           rec.data_source);
   END insertRow;

   FUNCTION deleteRow (rec deleteRecs%ROWTYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN amd_load.deletePlannerLogons (rec.planner_code,
                                           rec.logon_id,
                                           rec.data_source);
   END;
BEGIN
   FOR newRec IN newRecs
   LOOP
      newCnt := newCnt + 1;
      IF isInsert (newRec.planner_code, newRec.logon_id, newRec.data_source)
      THEN
         IF insertRow (newRec) = 0
         THEN
            insertCnt := insertCnt + 1;
         ELSE
            insertErrCnt := insertErrCnt + 1;
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

   DBMS_OUTPUT.put_line ('deleteCnt=' || deleteCnt);

   IF deleteErrCnt > 0
   THEN
      DBMS_OUTPUT.put_line ('deleteErrCnt=' || deleteErrCnt);
   END IF;

   IF insertErrCnt > 0 OR deleteErrCnt > 0
   THEN
      :rc := 4;
   ELSE
      :rc := 0;
   END IF;
END;
/

prompt rows inserted into amd_planner_logons 
select count(*) from amd_planner_logons where action_code =  'A' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows deleted for amd_planner_logons 
select count(*) from amd_planner_logons where action_code =  'D' and last_update_dt >= to_date(:v_now,'MM/DD/YYYY HH:MI:SS PM');

prompt rows in amd_planner_logons 
select count(*) from amd_planner_logons where action_code <>  'D' ;

PROMPT end plannerLogonsDiff.sql
EXIT :rc
