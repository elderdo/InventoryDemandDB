CREATE OR REPLACE PACKAGE AMD_OWNER.amd_nsl_sequence_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.8  $
     $Date:   16 Oct 2007 10:05:38  $
    $Workfile:   amd_nsl_sequence_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_nsl_sequence_pkg.pks-arc  $
   
      Rev 1.8   16 Oct 2007 10:05:38   zf297a
   Added version interface
   
      Rev 1.7   Dec 01 2005 09:36:48   zf297a
   added pvcs keywords
*/
   --
   -- SCCSID: amd_nsl_sequence_pkg.sql  1.8  Modified: 03/05/03 13:24:55
   --
	/*
		Purpose: Use the following function to sequence
		an NSL.
		Douglas S. Elder	10/14/01	Initial Implementation
		Fernando Fajardo  11/27/01 Added GetNslFromAmd() and
		                           mod to GetNslFromBssm().
		Fernando Fajardo  11/29/01 Fixed GetNslFromAmd().
		Fernando Fajardo  12/18/01 Added distinct keyword to 'select' statement.
		Fernando Fajardo  09/18/02 Added nsn_type='C' qualifier
                                 to GetNslFromAmd().
		Fernando Fajardo  10/14/02 Added anp.unassignment_date is null qualifier
                                 to GetNslFromAmd().
		Fernando Fajardo  11/25/02 Changed datatype of RAW_DATA constant to
											to varchar2 for performance.
		Fernando Fajardo  02/21/03 Fixed GetNslFromAmd() to look for NSL's only.
	*/

	function SequenceTheNSL(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type ;

    procedure version ; -- added 10/16/2007 by dse

end amd_nsl_sequence_pkg ;
/
