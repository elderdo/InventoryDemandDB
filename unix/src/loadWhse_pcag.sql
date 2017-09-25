WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET SQLBLANKLINES ON
SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

DEFINE link = &1
DEFINE linksa = &2


SET SERVEROUT ON SIZE 100000
variable program_id varchar2(30);

begin
select amd_defaults.getProgramId into :program_id from dual;
end;
/

print :program_id



DECLARE
   TYPE whseGold_tab IS TABLE OF whse@&&linksa.%ROWTYPE;

   TYPE whse_tab IS TABLE OF whse%ROWTYPE;

   whseGoldRecs    whseGold_tab := whseGold_tab ();
   cnt             NUMBER := 0;
   whseRecs        whse_tab := whse_tab ();
   ex_dml_errors   EXCEPTION;
   PRAGMA EXCEPTION_INIT (ex_dml_errors, -24381);
   l_error_count   NUMBER := 0;
   msg             VARCHAR2 (2000);
   errIndx         NUMBER := 0;
BEGIN
   SELECT *
     BULK COLLECT INTO whseGoldRecs
     FROM whse@&&link
    WHERE sc = :program_id || 'PCAG';

   IF whseGoldRecs.FIRST IS NOT NULL AND whseGoldRecs.LAST IS NOT NULL
   THEN
      FOR i IN whseGoldRecs.FIRST .. whseGoldRecs.LAST
      LOOP
         whseRecs.EXTEND;
         whseRecs (i).part := TRIM (whseGoldRecs (i).part);
         whseRecs (i).sc := TRIM (whseGoldRecs (i).sc);
         whseRecs (i).prime := TRIM (whseGoldRecs (i).prime);
         whseRecs (i).created_datetime := whseGoldRecs (i).created_datetime;
         whseRecs (i).stock_level := whseGoldRecs (i).stock_level;

         IF     whseGoldRecs (i).reorder_point < 1
            AND whseGoldRecs (i).reorder_point > 0
         THEN
            whseRecs (i).reorder_point := 0;
         ELSE
            whseRecs (i).reorder_point := whseGoldRecs (i).reorder_point;
         END IF;

         whseRecs (i).last_update_dt := SYSDATE;
      END LOOP;
   END IF;

   FORALL i IN whseRecs.FIRST .. whseRecs.LAST SAVE EXCEPTIONS
      INSERT INTO whse
           VALUES whseRecs (i);

   SELECT COUNT (*) INTO cnt FROM whse;

   DBMS_OUTPUT.put_line ('cnt=' || TO_CHAR (cnt));
EXCEPTION
   WHEN ex_dml_errors
   THEN
      l_error_count := SQL%BULK_EXCEPTIONS.COUNT;
      DBMS_OUTPUT.put_line (a => 'number of rows read: ' || whseRecs.LAST);
      DBMS_OUTPUT.put_line (
         a   =>    'number of rows loaded to whse: '
                || TO_CHAR (whseRecs.LAST - l_error_count));
      DBMS_OUTPUT.put_line (a => 'number of failures: ' || l_error_count);
      amd_warnings_pkg.insertWarningMsg (
         pData_line_no   => 10,
         pData_line      => 'loadWhse.sql',
         pWarning        => 'number of failures: ' || 1);

      FOR i IN 1 .. l_error_count
      LOOP
         errIndx := SQL%BULK_EXCEPTIONS (i).ERROR_INDEX;
         DBMS_OUTPUT.put_line (
               whseRecs (errIndx).part
            || ' '
            || whseRecs (errIndx).sc
            || ' '
            || whseRecs (errIndx).prime
            || ' not inserted to whse because of '
            || SQLERRM (-SQL%BULK_EXCEPTIONS (i).ERROR_CODE));
         amd_warnings_pkg.insertWarningMsg (
            pData_line_no   => 20,
            pData_line      => 'loadWhse.sql',
            pKey_1          => whseRecs (errIndx).part,
            pKey_2          => whseRecs (errIndx).sc,
            pKey_3          => whseRecs (errIndx).prime,
            pWarning        =>    'row not inserted to whse because of '
                               || SQLERRM (
                                     -SQL%BULK_EXCEPTIONS (i).ERROR_CODE));
      END LOOP;
END;
/

EXIT
