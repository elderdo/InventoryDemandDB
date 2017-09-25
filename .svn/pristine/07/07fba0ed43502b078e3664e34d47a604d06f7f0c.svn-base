CREATE OR REPLACE PACKAGE BODY amd_flight_hours_pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Jul 27 2005 12:08:56  $
    $Workfile:   amd_flight_hours_pkg.pkb  $
         $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\amd_flight_hours_pkg.pkb-arc  $
/*   
/*      Rev 1.0   Jul 27 2005 12:08:56   zf297a
/*   Initial revision.
*/
  PROCEDURE amd_base_history IS
    
  BEGIN
 -- We want to completely overwrite the stuff over in SPO because there's not
 -- that many records (20) at the time of this program creation.
 --   1)  Delete the deletes ('D') from previous runs in 
 --       tmp_a2a_org_deployment table.
 --   2)  Update the adds ('A's) from previous run to 
 --       'D' for deletes to refresh SPO.
 --   3)  Re run the query to pick up any new MOBs or FSLs
    DELETE FROM tmp_a2a_org_deployment
      WHERE action_code = 'D';
 
    UPDATE tmp_a2a_org_deployment
       SET action_code = 'D'
     WHERE action_code = 'A';
   
    INSERT INTO tmp_a2a_org_deployment
       (base_name, qty, action_code )
    SELECT a.spo_location, count(b.tail_no), 'A'
      FROM amd_spare_networks a,
           amd_ac_assigns b
     WHERE a.loc_sid = b.loc_sid
       AND a.loc_type = 'MOB'
       AND nvl(b.assignment_start,sysdate) <= sysdate
       AND nvl(b.assignment_end,sysdate) >= sysdate
     GROUP BY a.spo_location
     UNION
    SELECT spo_location, 0, 'A'
      FROM amd_spare_networks 
     WHERE loc_type = 'FSL'
     GROUP BY spo_location;
  EXCEPTION
    WHEN others THEN
      rollback;
  END amd_base_history;
  
  PROCEDURE amd_base_forecast IS
  
  BEGIN
	 NULL;
  END amd_base_forecast ;

END amd_flight_hours_pkg;
/
