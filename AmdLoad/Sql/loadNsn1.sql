/* Formatted on 10/9/2018 3:10:09 PM (QP5 v5.294) */
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET TERM ON
SET ECHO ON
SET TIME ON
SET TIMING ON
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

/*
 * Specify a default value for positional parameter 1
 * as amd_pgoldlb_link if it is not passed in as an argument
 * to the script.
 **/
COLUMN 1 NEW_VALUE 1

SELECT '' "1"
  FROM DUAL
 WHERE ROWNUM = 0;

DEFINE link = &1 "amd_pgoldlb_link"

EXEC amd_owner.mta_truncate_table('nsn1','reuse storage');


DECLARE
   cnt            NUMBER := 0;
   bad_data_cnt   NUMBER := 0;

   CURSOR nsns
   IS
      SELECT TRIM (nsn) nsn, TRIM (nsn_smic) nsn_smic FROM nsn1@&&link;
BEGIN
   FOR rec IN nsns
   LOOP
     <<insertNsn1>>
      BEGIN
         INSERT INTO nsn1 (nsn, nsn_smic)
              VALUES (rec.nsn, rec.nsn_smic);

         cnt := cnt + 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
               'SQLERRM=' || SQLERRM || ' SQLCODE=' || SQLCODE);
            DBMS_OUTPUT.put_line (
                  'record: '
               || cnt
               || ' has a bad nsn: **'
               || rec.nsn
               || '** (Asterisks are not part of nsn.) nsn_smic='
               || rec.nsn_smic);
            bad_data_cnt := bad_data_cnt + 1;
      END insertNsn1;
   END LOOP;

   DBMS_OUTPUT.put_line ('Inserted ' || cnt || ' rows to nsn1');
   DBMS_OUTPUT.put_line (
      'Bad data count ' || bad_data_cnt || '. Nsn(s) skipped');
   COMMIT;
END;
/

QUIT