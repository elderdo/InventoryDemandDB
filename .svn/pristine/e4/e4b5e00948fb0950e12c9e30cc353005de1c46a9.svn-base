/*
	$Author:   zf297a  $
      $Revision:   1.0  $
          $Date:   01 May 2008 11:23:22  $
      $Workfile:   spo_lp_in_transit_v.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\spo_lp_in_transit_v.sql.-arc  $
/*   
/*      Rev 1.0   01 May 2008 11:23:22   zf297a
/*   Initial revision.
	
*/
SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_IN_TRANSIT_V;

/* Formatted on 2008/05/01 11:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_in_transit_v (LOCATION,
                                                            part,
                                                            in_transit_type,
                                                            quantity,
                                                            TIMESTAMP
                                                           )
AS
   SELECT "LOCATION", "PART", "IN_TRANSIT_TYPE", "QUANTITY", "TIMESTAMP"
     FROM spoc17v2.v_lp_in_transit@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM SPO_LP_IN_TRANSIT_V FOR AMD_OWNER.SPO_LP_IN_TRANSIT_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_IN_TRANSIT_V TO AMD_READER_ROLE;

