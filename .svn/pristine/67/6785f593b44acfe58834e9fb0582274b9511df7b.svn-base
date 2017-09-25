/*
       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   29 Nov 2007 08:45:14  $
     $Workfile:   datasys_lp_override_v.sql  $
	  $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\datasys_lp_override_v.sql.-arc  $
/*   
/*      Rev 1.0   29 Nov 2007 08:45:14   zf297a
/*   Initial revision.
**/
DROP VIEW AMD_OWNER.DATASYS_LP_OVERRIDE_V;

/* Formatted on 2007/11/07 11:45 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.datasys_lp_override_v (part,
                                                              cage,
                                                              site_location,
                                                              TYPE,
                                                              quantity,
                                                              begin_date,
                                                              end_date,
                                                              override_user,
                                                              override_reason
                                                             )
AS
   SELECT /*+ driving_site (p) */ 
	  p.part, p.cage, l.site_location, t.VALUE, lpo.quantity,
          lpo.begin_date, lpo.end_date, su.spo_user, r.VALUE
     FROM escmc17v2.lp_override@stl_escm_link lpo,
          escmc17v2.part@stl_escm_link p,
          escmc17v2.LOCATION@stl_escm_link l,
          escmc17v2.TYPE@stl_escm_link t,
          escmc17v2.spo_user@stl_escm_link su,
          escmc17v2.TYPE@stl_escm_link r
    WHERE lpo.part_id = p.part_id
      AND lpo.override_type_id = t.type_id
      AND lpo.location_id = l.location_id
      AND lpo.override_user_id = su.spo_user_id
      AND lpo.override_reason_id = r.type_id;


GRANT SELECT ON AMD_OWNER.DATASYS_LP_OVERRIDE_V TO AMD_READER_ROLE;


