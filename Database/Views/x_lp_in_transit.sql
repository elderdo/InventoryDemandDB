/*
	$Author:   zf297a  $
      $Revision:   1.0  $
          $Date:   01 May 2008 11:23:22  $
      $Workfile:   x_lp_in_transit.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_lp_in_transit.sql.-arc  $
/*   
/*      Rev 1.0   01 May 2008 11:23:22   zf297a
/*   Initial revision.
	
*/
SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_IN_TRANSIT_V;

/* Formatted on 2008/05/01 11:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_in_transit_v (LOCATION,
                                                          part,
                                                          in_transit_type,
                                                          quantity,
                                                          TIMESTAMP
                                                         )
AS
   SELECT site_location LOCATION, part_no part,
          DECODE (serviceable_flag,
                  'Y', 'General',
                  'N', 'Defective',
                  serviceable_flag
                 ) in_transit_type,
          quantity, last_update_dt TIMESTAMP
     FROM amd_in_transits_sum
    WHERE action_code <> 'D';


DROP PUBLIC SYNONYM X_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM X_LP_IN_TRANSIT_V FOR AMD_OWNER.X_LP_IN_TRANSIT_V;


GRANT SELECT ON AMD_OWNER.X_LP_IN_TRANSIT_V TO AMD_READER_ROLE;

