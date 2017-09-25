/*
*      $Author:   Douglas Elder
*    $Revision:   1.11
*        $Date:   16 Nov 2015
*    $Workfile:   loadWhse.sql  $
*   
*      Rev 1.11   16 Nov 2015 Addeed dup check
*      Rev 1.10  23 Sep 2015 use program_id
*      Rev 1.9   15 Dec 2014 make sure the symbolic variables are used for
*                 db linkes and got rid of the extra slashes for the comments
*                 which are not really needed - just the asterish is good enough
*
*      Rev 1.8   29 Jul 2014 added SC C17%KIT%G and reformatted query with Toad

*      Rev 1.3   20 Feb 2009 09:37:40   zf297a
*   Added link variable and implemented warnings
*   
*      Rev 1.2   28 Jan 2009 14:17:12   zf297a
*   Added some edit checks when inserting data to whse so that the load keeps on going.  When the amd_load_warnings table and its amd_warnings_pkg package get implemented, the errors will get reported this way.
*   
*      Rev 1.1   20 May 2008 13:23:14   zf297a
*   Added Canada to whse query.
*   
*      Rev 1.0   20 May 2008 13:18:28   zf297a
*   Initial revision.
**/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE 100000
SET TIME ON
SET TIMING ON
SET ECHO ON

variable program_id varchar2(30);

begin
select amd_defaults.getProgramId into :program_id from dual;
end;
/

print :program_id


EXEC amd_owner.mta_truncate_table('whse','reuse storage');

DEFINE link = &1
DEFINE linksa = &2

DECLARE
   cnt   NUMBER := 0;
   dup   NUMBER := 0;

   CURSOR whse_data
   IS
      SELECT TRIM (sc) sc,
             TRIM (part) part,
             TRIM (prime) prime,
             TRIM (user_ref3) user_ref3,
             TRIM (user_ref4) user_ref4,
             TRIM (user_ref5) user_ref5,
             created_datetime,
             created_userid,
             stock_level,
             CASE
                WHEN reorder_point < 1 AND reorder_point > 0 THEN 0 -- Requirement from GOLD that AMD must comply to get data for SPO 3/11/2008
                ELSE reorder_point
             END
                reorder_point,
             planner_code
        FROM whse@&&link
    WHERE    sc LIKE :program_id || '%CODUKBG'
          OR sc LIKE :program_id || '%CODAUSG'
          OR sc LIKE :program_id || '%CTLATLG'
          OR sc LIKE :program_id || '%CODCANG'
          OR sc LIKE :program_id || '%CODSACG'
          OR sc LIKE :program_id || '%ICP%'
          OR sc LIKE :program_id || '%KIT%G';
BEGIN
   FOR rec IN whse_data
   LOOP
      BEGIN
         INSERT INTO whse (sc,
                           part,
                           prime,
                           user_ref3,
                           user_ref4,
                           user_ref5,
                           created_datetime,
                           created_userid,
                           stock_level,
                           reorder_point,
                           planner_code)
              VALUES (rec.sc,
                      rec.part,
                      rec.prime,
                      rec.user_ref3,
                      rec.user_ref4,
                      rec.user_ref5,
                      rec.created_datetime,
                      rec.created_userid,
                      rec.stock_level,
                      rec.reorder_point,
                      rec.planner_code);

         cnt := cnt + 1;
      EXCEPTION
         WHEN dup_val_on_index
         THEN
            dup := dup + 1;
            DBMS_OUTPUT.put_line ('part: ' || rec.part || ' sc: (' || rec.sc || ')');
      END;

   END LOOP;
   DBMS_OUTPUT.put_line ('cnt=' || cnt);
   DBMS_OUTPUT.put_line ('dup=' || dup);
END;
/

EXIT
