    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:30:46  $
     $Workfile:   PART_MASTER_IN.prc  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Procedures\PART_MASTER_IN.prc-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:30:46   c970183
/*   Initial revision.
*/
CREATE OR REPLACE PROCEDURE           part_master_in (
NIIN 	  		  	  IN  VARCHAR2,
NSN				      IN  VARCHAR2,
Part				  IN  VARCHAR2,
Prime_Part			  IN  VARCHAR2,
Alternate_Parts		  OUT VARCHAR2,
AAC					  OUT VARCHAR2,
ISG					  OUT CHAR,
Nomenclature		  OUT VARCHAR2,
smrc				  OUT VARCHAR2,
errc				  OUT VARCHAR2,
remarks				  OUT VARCHAR2,
manuf_cage            OUT VARCHAR2,
source_code			  OUT VARCHAR2,
ims_designator_code   OUT VARCHAR2,
order_lead_time		  OUT NUMBER,
cap_price			  OUT VARCHAR2,
um_issue_code		  OUT VARCHAR2,
user_name			  OUT VARCHAR2,
phone				  OUT VARCHAR2,
rop					  OUT NUMBER,
roq					  OUT NUMBER,
part_type			  OUT VARCHAR2,
ror_admin			  OUT VARCHAR2,
ror_phone			  OUT VARCHAR2,
mtbdr_cleaned		  OUT NUMBER,
serd 				  OUT VARCHAR2,
hazmt			  	  OUT VARCHAR2,
auto_process 		  OUT VARCHAR2)
as
/******************************************************************************
   NAME:       PrimePart_from_NIIN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/3/2004          1. Created this function.


******************************************************************************/
v_part varchar2(50);
partchar char(50);
isgchar char(50);
primechar char(50);
alting integer;
vims_designator_code varchar2(20);
verrc char(3);
vnsn varchar2(15);

BEGIN
    If part is null
	Then
	  v_part := prime_part;
	Else
	  v_part := part;
	End if;
	If part is null
	Then
	  partchar := prime_part;
	Else
	  partchar := part;
	End if;


   begin

	  select acquisition_advice_code, Nomenclature, order_lead_time
	  into AAC, Nomenclature, order_lead_time
	  from amd_owner.amd_spare_parts
	  where part_no = v_part;
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       AAC := null;
     WHEN OTHERS THEN
	   begin
       AAC := null;
	   end;
   end;

    begin

	  select mtbdr
	  into mtbdr_cleaned
	  from amd_owner.amd_rmads_source_tmp
	  where part_no = v_part;
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       mtbdr_cleaned := 99999;
     WHEN OTHERS THEN
	   begin
       mtbdr_cleaned := 99999;
	   end;
   end;

    begin

	  select  distinct(to_char(cap_price))
	  into cap_price
	  from amd_owner.prc1
	  where part = v_part;
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Cap_price := 'Not Available';
     WHEN OTHERS THEN
	   begin
       cap_price := 'Price Varies';
	   end;
   end;

   begin

   select ISGP_GROUP_NO, smrc, errc, remarks, manuf_cage, source_code, ims_designator_code, um_issue_code,
   		  user_ref4, hazardous_material_code, mils_auto_process_b
   into ISG, smrc, verrc, remarks, manuf_cage, source_code, vims_designator_code, um_issue_code,
          serd, hazmt, auto_process
   from  amd_owner.CAT1
   where part = partchar;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       ISG := null;
     WHEN OTHERS THEN
	   begin
       ISG := null;
	   end;

   end;
   errc := verrc;
   If substr(smrc,6,1) in ('N','P')
   Then
   	   part_type := 'C';
   Else
   	   part_type := 'R';
   End if;

   primechar := prime_part;
   If trim(verrc) = 'T'
   Then
   begin
   select c.user_name, c.phone
   into ror_admin, ror_phone
   from VENC a, VENN b, amd_USE1 c
   where a.vendor_code = b.vendor_code
   and a.USER_REF1 = c.userid
   and a.part = partchar;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       ror_admin := 'Not Found';
     WHEN OTHERS THEN
	   ror_admin := 'Not Found';
   end;
   Else
   	   ror_admin := 'N/A';
   End if;


   vnsn := trim(nsn);
   If trim(verrc) in ('N','P')
   Then
   	   begin

	  select rop, roq
	  into rop, roq
	  from amd_owner.amd_acmii
	  where nsn = vnsn and
	        sran = 'CTLATL';
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       rop := null;
	   roq := null;
     WHEN OTHERS THEN
	   rop := null;
	   roq := null;
   end;
   else
   	   rop := null;
	   roq := null;
   End if;



   ims_designator_code := vims_designator_code;
   If vims_designator_code is not null
   Then
   	   begin

	  select distinct user_name, phone
	  into user_name, phone
	  from amd_owner.amd_use1
	  where ims_designator_code = trim(vims_designator_code);
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       user_name := 'Not Available';
     WHEN OTHERS THEN
	   begin
       user_name := 'Not Available';
	   end;
   end;
   else
   	  user_name := 'Not Available';
   End if;


--If ISG is null then
   begin
   select count(distinct(b.part_no)) - 1
   into Alternate_Parts
   from  amd_owner.amd_spare_parts a, amd_owner.amd_nsi_parts b
   where a.part_no = b.part_no and
   b.unassignment_date is null
   and substr(a.nsn,5,9) = NIIN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Alternate_Parts := '0';
     WHEN OTHERS THEN
	   begin
       Alternate_Parts := '0';
	   end;
   end;
/*Else
  isgchar := isg;
   begin
   select count(distinct(part)) - 1
   into alting
   from cat1
	where isgp_group_no = isgchar;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Alternate_Parts := '0';
     WHEN OTHERS THEN
	   begin
       Alternate_Parts:= '0';
	   end;
   end;
   Alternate_parts := to_char(alting);
 End if; */

END part_master_in;
/

