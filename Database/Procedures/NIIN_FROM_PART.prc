    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:30:46  $
     $Workfile:   NIIN_FROM_PART.prc  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Procedures\NIIN_FROM_PART.prc-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:30:46   c970183
/*   Initial revision.
*/
CREATE OR REPLACE PROCEDURE           NIIN_FROM_PART (

PARTNO   	IN	VARCHAR2,
FSC 		OUT	VARCHAR2,
NIIN 		OUT	VARCHAR2,
PRIME_Ind		OUT VARCHAR2,
PRIME_PART	OUT VARCHAR2,
NSN			OUT VARCHAR2)
as
/******************************************************************************
   NAME:       NIIN_FROM_PART
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/4/2004          1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     NIIN_FROM_PART
      Sysdate:         11/4/2004
      Date and Time:   11/4/2004, 1:57:47 PM, and 11/4/2004 1:57:47 PM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
v_nsn varchar2(50);
BEGIN

   begin
   select substr(a.nsn,1,4), substr(a.nsn,5,9), b.PRIME_IND, NSN
   into FSC, NIIN, PRIME_IND, v_nsn
   from  amd_spare_parts a, amd_nsi_parts b
   where a.part_no = b.part_no
   and b.unassignment_date is null
   and a.part_no = partno;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NIIN := 'Not Found';
	   Prime_ind := 'X';
     WHEN OTHERS THEN
       NIIN := 'Not Found';
	   Prime_ind := 'X';

   end;
   nsn := v_nsn;
   If Prime_ind = 'N' then
   	  begin
	  select a.part_no
   	  into  PRIME_PART
      from  amd_owner.amd_spare_parts a, amd_owner.amd_nsi_parts b
      where a.part_no = b.part_no and
            b.unassignment_date is null and b.prime_ind = 'Y' and
			a.nsn = v_NSN;
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       PRIME_PART := 'Not Found';
     WHEN OTHERS THEN
       PRIME_PART := 'Not Found';
	 end;
   else
   	   Prime_part := partno;
   end if;

END NIIN_FROM_PART;
/

