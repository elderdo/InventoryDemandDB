DROP PACKAGE AMD_OWNER.AMD_REQS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Reqs_Pkg AS
	/*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.7  $
         $Date:   15 Jan 2009 15:57:06  $
     $Workfile:   AMD_REQS_PKG.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_REQS_PKG.pks-arc  $
/*
/*      Rev 1.7   15 Jan 2009 15:57:06   zf297a
/*   converted from loc_sid to spo_location for amd_backorder_sum
/*
/*      Rev 1.6   Nov 29 2006 13:40:36   c402417
/*   Modified functions for Backorder Diff using spo_prime_part_no due to modified table amd_backorder_sum.
/*
/*      Rev 1.5   Jun 28 2006 13:15:06   zf297a
/*   Added the interfaces for the amd_backorder_spo_sum diff
/*
/*      Rev 1.4   Jun 09 2006 12:25:06   zf297a
/*   added interface version
/*
/*      Rev 1.3   Apr 28 2006 13:51:00   zf297a
/*   updated package end statment: end amd_reqs_pkg ;
/*
/*      Rev 1.2   12 Aug 2005 10:48:46   c402417
/*   Added amd_reqs and amd_backorder_sum diff fucntions
/*
/*      Rev 1.1   May 06 2005 09:07:02   c970183
/*   fixed deleteRow and added PVCS keywords

*/
	   -------------------------------------------------------------------
	   -- SCCSID: amd_reqs_pkg.sql 1.2 Modified: 06/26/02 10:36:43
	   --
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  12/10/01		  ks			initial implementation
	   --  06/26/02		  ks			modified action code from not Deleted to in
	   --  				  		add or change - performance issue
	   -------------------------------------------------------------------

	SUCCESS							CONSTANT  NUMBER := 0;
	FAILURE							   CONSTANT  NUMBER := 4;

	PROCEDURE LoadAmdReqs;
	 /* amd_reqs  diff  function */

	FUNCTION InsertRow(
			 		   		  	REQ_ID 			 		IN VARCHAR2,
								PART_NO					IN VARCHAR2,
								LOC_SID					IN NUMBER,
								QUANTITY_DUE			   IN NUMBER) RETURN NUMBER;

	FUNCTION UpdateRow(
			 		   			 REQ_ID					   	  IN VARCHAR2,
								 PART_NO					  IN VARCHAR2,
								 LOC_SID 					  IN NUMBER,
								 QUANTITY_DUE				  IN NUMBER) RETURN NUMBER;

	FUNCTION DeleteRow(
			 		   			 REQ_ID						   IN VARCHAR2,
								 PART_NO					   IN VARCHAR2,
								 LOC_SID					   IN NUMBER) RETURN NUMBER;


	/* amd_backorder_sum diff function */

	FUNCTION InsertRowBackorder(
			 		   	 SPO_PRIME_PART_NO	In varchar2,
						 spo_location							   IN varchar2,
						 QTY								   IN NUMBER) RETURN NUMBER;

	FUNCTION UpdateRowBackorder(
			 		   	 SPO_PRIME_PART_NO		In varchar2,
						 spo_location							   IN varchar2,
						 QTY								   IN NUMBER) RETURN NUMBER;


	FUNCTION DeleteRowBackorder(
			 		   	 SPO_PRIME_PART_NO		In varchar2,
						 spo_location							   IN varchar2) RETURN NUMBER;

	-- added 6/9/2006 by dse
	procedure version ;

	-- added 6/28/2006 by dse
	FUNCTION InsertRowSpoSum(
	  		   			 spo_prime_part_no	IN amd_backorder_spo_sum.SPO_PRIME_PART_NO%type,
						 qty		IN amd_backorder_spo_sum.QTY%type) RETURN NUMBER ;
	FUNCTION UpdateRowSpoSum(
	  		   			 spo_prime_part_no	IN amd_backorder_spo_sum.SPO_PRIME_PART_NO%type,
						 qty		IN amd_backorder_spo_sum.QTY%type) RETURN NUMBER ;
	FUNCTION DeleteRowSpoSum(
	  		   			 spo_prime_part_no	IN amd_backorder_spo_sum.SPO_PRIME_PART_NO%type) RETURN NUMBER ;

END Amd_Reqs_Pkg;
 
/


DROP PUBLIC SYNONYM AMD_REQS_PKG;

CREATE PUBLIC SYNONYM AMD_REQS_PKG FOR AMD_OWNER.AMD_REQS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_REQS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_REQS_PKG TO AMD_WRITER_ROLE;
