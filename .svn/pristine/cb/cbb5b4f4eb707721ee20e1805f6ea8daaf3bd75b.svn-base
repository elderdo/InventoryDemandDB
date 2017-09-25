SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_IN_TRANSIT_V;

/* Formatted on 2009/07/08 15:55 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_in_transit_v (location,
                                                          part,
                                                          in_transit_type,
                                                          quantity,
                                                          last_modified
                                                         )
as
   select site_location location, transits.part_no part,
          DECODE (serviceable_flag,
                  'Y', general_in_transit,
                  'N', defective_in_transit,
                  serviceable_flag
                 ) in_transit_type,
          quantity, transits.last_update_dt last_modified
     from amd_in_transits_sum transits, amd_spare_parts parts,
          amd_spo_types_v
    where transits.action_code <> 'D'
      and transits.part_no = parts.part_no
      and parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM X_LP_IN_TRANSIT_V FOR AMD_OWNER.X_LP_IN_TRANSIT_V;


GRANT SELECT ON AMD_OWNER.X_LP_IN_TRANSIT_V TO AMD_READER_ROLE;

