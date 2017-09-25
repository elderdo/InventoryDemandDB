    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 12:04:38  $
     $Workfile:   amd_order_sid_seq.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Sequences\amd_order_sid_seq.sql-arc  $
/*   
/*      Rev 1.0   May 23 2005 12:04:38   c970183
/*   Initial revision.
*/

DROP SEQUENCE AMD_OWNER.AMD_ORDER_SID_SEQ;

CREATE SEQUENCE AMD_OWNER.AMD_ORDER_SID_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


GRANT SELECT ON  AMD_OWNER.AMD_ORDER_SID_SEQ TO AMD_READER_ROLE;

GRANT SELECT ON  AMD_OWNER.AMD_ORDER_SID_SEQ TO AMD_WRITER_ROLE;


