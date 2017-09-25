/*
      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   28 Oct 2014
    $Workfile:   loadVenn.sql  $
/*   
/*      Rev 1.3   28 Oct 2014
           have an inline proc ignore duplicates
/*      Rev 1.2   28 Jun 2013
/*   changed insert/select into merge without
/*   filtering data with only valid cage_codes and
/*   allowing for duplicate vendor_codes which get recorded
/*   in user_ref6 with the number of duplicates.  If there
/*   are no duplicates, user_ref6 should be null
/*      Rev 1.1   20 Feb 2009 09:17:28   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:54   zf297a
/*   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE 100000

DEFINE link = &1

DECLARE
   CURSOR source_data
   IS
      SELECT TRIM (vendor_code) vendor_code,
             TRIM (vendor_name) vendor_name,
             TRIM (cage_code) cage_code,
             TRIM (user_ref1) user_ref1
        FROM venn@&&link;

   cnt   NUMBER := 0;
   dup   NUMBER := 0;
BEGIN
   amd_owner.mta_truncate_table ('venn', 'reuse storage');

   FOR rec IN source_data
   LOOP
      BEGIN
         INSERT INTO venn (vendor_code,
                           vendor_name,
                           cage_code,
                           user_ref1)
              VALUES (rec.vendor_code,
                      rec.vendor_name,
                      rec.cage_code,
                      rec.user_ref1);

         cnt := cnt + 1;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            dup := dup + 1;
            DBMS_OUTPUT.put_line (
                  'vendor_code: '
               || rec.vendor_code
               || ' for '
               || rec.vendor_name
               || ' is a duplicate');

            UPDATE VENN
               SET user_ref1 = 'dup in GOLD'
             WHERE vendor_code = rec.vendor_code;
         WHEN OTHERS
         THEN
            RAISE;
      END;
   END LOOP;

   DBMS_OUTPUT.put_line ('rows inserted=' || cnt);
   DBMS_OUTPUT.put_line ('dup rows=' || dup);
   COMMIT;
END;
/

EXIT;
