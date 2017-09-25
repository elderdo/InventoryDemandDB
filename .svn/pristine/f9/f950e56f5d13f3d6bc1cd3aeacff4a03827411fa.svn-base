CREATE OR REPLACE PACKAGE Amd_Test_Data  AS
	/*
	    PVCS Keywords

       $Author:   c402417  $
     $Revision:   1.12  $
         $Date:   Nov 22 2005 11:06:10  $
     $Workfile:   AMD_TEST_DATA.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_test_data.pks-arc  $
   
      Rev 1.12   Nov 22 2005 11:06:10   c402417
   Removed obsolete codes.

*/
	PROCEDURE setTestProperty(value IN NUMBER) ;
	FUNCTION getTestProperty RETURN NUMBER ;

	/* Cleans out amd_spare_parts and all related tables
		so they are ready for an initial load.
	*/
	FUNCTION DeleteAmdSpareParts RETURN BOOLEAN ;

	/* Cleans out specific amd_spare_parts and all related tables
		so they are ready for an initial load.
	*/
	FUNCTION DeleteAmdSparePart(pNsi_sid IN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN BOOLEAN ;

	/* Cleans out the amd_param_changes and amd_params
		table
	*/
	FUNCTION DeleteParameters RETURN BOOLEAN ;

	/* Loads the amd_params and amd_param_changes with some
		initial values.
	*/
	FUNCTION CreateParameters RETURN BOOLEAN ;

	/* Tests InsertRow and UpdateRow of the
		amd_spare_parts_pkg.
	*/
	FUNCTION test_amd_spare_parts_pkg RETURN BOOLEAN ;

	/* This procedure is necessary, since some back to back
		tests could cause a dup key to be produced, when part
		of the key uses the System Data - sysdate.
	*/
	PROCEDURE sleep(secs IN NUMBER) ;
	/* A Pl/SQL specific version of a Diff function
		for amd_spare_parts
		*/
	FUNCTION Diff RETURN NUMBER ;
	FUNCTION PrimeCheckForTmpAmdSpareParts RETURN BOOLEAN ;
	FUNCTION PrimeCheckForAmdNsiParts RETURN BOOLEAN ;


	FUNCTION TestDefaults RETURN BOOLEAN ;

	FUNCTION TestGetNsiSid RETURN BOOLEAN ;

	FUNCTION revision RETURN VARCHAR2 ;

	PROCEDURE helloWorld ;

	PROCEDURE genXml ;

	--PROCEDURE orderInfoXml ;

	--PROCEDURE orderInfoLineXml ;

	PROCEDURE fix_national_stock_items ;

END;
/
