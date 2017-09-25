/*
	$Author:   zf297a  $
      $Revision:   1.0  $
          $Date:   14 Nov 2007 13:22:00  $
      $Workfile:   amd_interface_seq.sql  $
	   $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\ddl\amd_interface_seq.sql.-arc  $
/*   
/*      Rev 1.0   14 Nov 2007 13:22:00   zf297a
/*   Initial revision.
*/

DROP SEQUENCE AMD_OWNER.AMD_INTERFACE_SEQ;

CREATE SEQUENCE AMD_OWNER.AMD_INTERFACE_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


DROP PUBLIC SYNONYM AMD_INTERFACE_SEQ;

CREATE PUBLIC SYNONYM AMD_INTERFACE_SEQ FOR AMD_OWNER.AMD_INTERFACE_SEQ;


GRANT SELECT ON AMD_OWNER.AMD_INTERFACE_SEQ TO AMD_WRITER_ROLE;


