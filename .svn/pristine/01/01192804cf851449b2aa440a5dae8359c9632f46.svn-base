/*
	$Author:   zf297a  $
      $Revision:   1.0  $
          $Date:   01 May 2008 11:23:22  $
      $Workfile:   spo_lp_override_v.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\spo_lp_override_v.sql.-arc  $
/*   
/*      Rev 1.0   01 May 2008 11:23:22   zf297a
/*   Initial revision.
	
*/
SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_OVERRIDE_V;

/* Formatted on 2008/05/01 11:10 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_override_v (part,
                                                          LOCATION,
                                                          override_type,
                                                          quantity,
                                                          override_reason,
                                                          override_user,
                                                          begin_date,
                                                          end_date,
                                                          TIMESTAMP
                                                         )
AS
   SELECT "PART", "LOCATION", "OVERRIDE_TYPE", "QUANTITY", "OVERRIDE_REASON",
          "OVERRIDE_USER", "BEGIN_DATE", "END_DATE", "TIMESTAMP"
     FROM spoc17v2.v_lp_override@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM SPO_LP_OVERRIDE_V FOR AMD_OWNER.SPO_LP_OVERRIDE_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_OVERRIDE_V TO AMD_READER_ROLE;

