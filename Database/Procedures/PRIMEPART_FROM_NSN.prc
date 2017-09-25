    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:30:46  $
     $Workfile:   PRIMEPART_FROM_NSN.prc  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Procedures\PRIMEPART_FROM_NSN.prc-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:30:46   c970183
/*   Initial revision.
*/
CREATE OR REPLACE PROCEDURE           PrimePart_from_NSN(
NSN	  		  IN  VARCHAR2,
PRIME_Part		  OUT VARCHAR2)
as
/******************************************************************************
   NAME:       PrimePart_from_NIIN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/3/2004          1. Created this function.


******************************************************************************/
vNSN varchar2(50);

BEGIN
vNSN := NSN;
   select a.part_no
   into PRIME_PART
   from  amd_owner.amd_spare_parts a, amd_owner.amd_nsi_parts b
   where a.part_no = b.part_no and
   b.unassignment_date is null and b.prime_ind = 'Y'
   and a.nsn = vNSN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Prime_part := 'Not Found';
     WHEN OTHERS THEN
       Prime_part := 'Not Found';

END PrimePart_from_NSN;
/

