CREATE OR REPLACE PACKAGE BODY amd_org_deployment_pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.2  $
     $Date:   Jun 09 2006 12:38:20  $
    $Workfile:   amd_org_deployment_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_org_deployment_pkg.pkb-arc  $
/*   
/*      Rev 1.2   Jun 09 2006 12:38:20   zf297a
/*   implemented version
/*   
/*      Rev 1.1   Dec 01 2005 09:39:04   zf297a
/*   added pvcs keywords
*/

	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_org_deployment_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
  PROCEDURE load_org_deployment IS

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
  END load_org_deployment;
  
	procedure version is
	begin
		 writeMsg(pTableName => 'amd_org_deployment_pkg', 
		 		pError_location => 10, pKey1 => 'amd_org_deployment_pkg', pKey2 => '$Revision:   1.2  $') ;
	end version ;

END amd_org_deployment_pkg;
/
