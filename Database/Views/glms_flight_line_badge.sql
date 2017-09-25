    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:40:38  $
     $Workfile:   glms_flight_line_badge.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Views\glms_flight_line_badge.sql-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:40:38   c970183
/*   Initial revision.
*/
select "SERN","BEMSID" from glms_owner.glms_flight_line_badge@AMD_GLMS_link
