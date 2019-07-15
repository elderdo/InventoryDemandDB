/*
      $Author:   Douglas S Elder
    $Revision:   1.6
        $Date:   22 Nov 2017
    $Workfile:   updateCostToRepairOffBase.sql  $

      Rev 1.6   22 Nov 2017 DSE changed serveroutput to UNLIMITED
      Rev 1.5   22 Feb 2012 Use the new getCostToRepairOffbase function DSE
	NOTE: this script gets executed after all part data has been updated.
	If it does not run, the SparePart diff will still update the cost_to_repair_off_base
	when it runs the next day.

      Rev 1.4   20 Aug 2009 09:00:08   DSE
   Change to use v_poi1 was requested via ClearQuest LBPSS00002264 
   
      Rev 1.3   19 Aug 2009 11:53:32   DSE
  Commented out set serveroutput - this only needs to be turned on for debugging purposes.
   
      Rev 1.2   19 Aug 2009 11:36:20   DSE
   removed "set termout off"
  
      Rev 1.1   19 Aug 2009 11:32:28   DSE
   Removed rollback, Laurie Compton has approved the data.
   
      Rev 1.0   18 Aug 2009 15:11:54   DSE
   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size UNLIMITED
-- uncomment this and set create_csv_file to true
column dcol new_value mydate noprint
select to_char(sysdate,'YYYYMMDD') dcol from dual;
--spool ../data/&mydate.updateCostToRepairOffBase.csv
set sqlblanklines on

DECLARE
   CURSOR items
   IS
      SELECT nsi_sid,
             items.nsn nsn,
             prime_part_no,
             cost_to_repair_off_base,
             nomenclature
        FROM amd_national_stock_items items, amd_spare_parts parts
       WHERE     items.action_code <> 'D'
             AND items.prime_part_no = parts.part_no
             AND parts.action_code <> 'D';

   same_cnt                      NUMBER := 0;
   null_cnt                      NUMBER := 0;
   update_cnt                    NUMBER := 0;
   recs_in_cnt                   NUMBER := 0;
   nomenclature                  amd_spare_parts.nomenclature%TYPE;
   the_cost_to_repair_off_base   amd_national_stock_items.cost_to_repair_off_base%TYPE;
   create_csv_file               BOOLEAN := FALSE;
BEGIN
   IF create_csv_file
   THEN
      DBMS_OUTPUT.put_line (
         'nsn,nomenclature,old_cost_to_repair_off_base,new_cost_to_repair_off_base');
   END IF;

   FOR rec IN items
   LOOP
      recs_in_cnt := recs_in_cnt + 1;
      the_cost_to_repair_off_base :=
         ROUND (amd_owner.getCostToRepairOffBase (rec.nsi_sid), 2);

      IF NVL (the_cost_to_repair_off_base, 0) <>
            ROUND (NVL (rec.cost_to_repair_off_base, 0), 2)
      THEN
         IF create_csv_file
         THEN
            DBMS_OUTPUT.put_line (
                  rec.nsn
               || ',"'
               || rec.nomenclature
               || '"'
               || ','
               || ROUND (rec.cost_to_repair_off_base, 2)
               || ','
               || the_cost_to_repair_off_base);
         END IF;

         UPDATE amd_national_stock_items
            SET last_update_dt = SYSDATE,
                cost_to_repair_off_base = the_cost_to_repair_off_base,
                cost_to_repair_off_base_chged = 'Y'
          WHERE nsi_sid = rec.nsi_sid;

         update_cnt := update_cnt + 1;
      ELSE
         same_cnt := same_cnt + 1;

         IF rec.cost_to_repair_off_base IS NULL
         THEN
            null_cnt := null_cnt + 1;
         END IF;
      END IF;
   END LOOP;

   DBMS_OUTPUT.put_line (
         'recs_in_cnt='
      || recs_in_cnt
      || ' update_cnt='
      || update_cnt
      || ' same_cnt='
      || same_cnt
      || ' null_cnt='
      || null_cnt);
END;
/


-- uncomment when creating csv file
--spool off

exit 
