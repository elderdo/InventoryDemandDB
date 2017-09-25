SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_LP_OVERRIDE_WK_V;

/* Formatted on 2009/07/14 13:54 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_lp_override_wk_v (location,
                                                             part,
                                                             override_type,
                                                             quantity,
                                                             override_reason,
                                                             override_user,
                                                             begin_date,
                                                             end_date,
                                                             source,
                                                             last_modified
                                                            )
as
   select   spo_location location, locov.part_no,
            tsl_fixed_override override_type,
            case
               when spo_location =
                      amd_location_part_override_pkg.getthe_warehouse
               and parts.is_repairable = 'Y'
                  then 0
               else tsl_override_qty
            end quantity,
            fixed_tsl_load_override_reason override_reason,
            TO_CHAR (TO_NUMBER (tsl_override_user)) override_user,
            locov.last_update_dt begin_date, null end_date,
            'AMD_LOCATION_PART_OVERRIDE' source,
            locov.last_update_dt last_modified
       from amd_location_part_override locov,
            amd_spare_parts parts,
            amd_spo_types_v,
            amd_spare_networks ntwks
      where locov.loc_sid = ntwks.loc_sid
        and locov.action_code <> 'D'
        and tsl_override_qty is not null
        and locov.part_no = parts.part_no
        and parts.is_spo_part = 'Y'
   union
   select   rsp_location location, part_no, override_type,
            rop_or_roq quantity,
            fixed_tsl_load_override_reason override_reason,
            TO_CHAR
               (TO_NUMBER
                   (amd_location_part_override_pkg.getfirstlogonidforpart
                                       (amd_utils.getnsisidfrompartno (part_no)
                                       )
                   )
               ) override_user,
            last_update_dt begin_date, null end_date,
            'AMD_RSP_SUM_CONSUMABLES_V' source, last_update_dt last_modified
       from amd_owner.amd_rsp_sum_consumables_v, amd_spo_types_v
      where action_code <> 'D' and rop_or_roq is not null
   union
   select   rsp_location location, part_no, override_type, rsp_level quantity,
            fixed_tsl_load_override_reason override_reason,
            TO_CHAR
               (TO_NUMBER
                   (amd_location_part_override_pkg.getfirstlogonidforpart
                                       (amd_utils.getnsisidfrompartno (part_no)
                                       )
                   )
               ) override_user,
            last_update_dt begin_date, null end_date,
            'AMD_RSP_SUM_REPAIRABLES_V' source, last_update_dt last_modified
       from amd_owner.amd_rsp_sum_repairables_v, amd_spo_types_v
      where action_code <> 'D' and rsp_level is not null
   union
   select   spo_location, part_no, tsl_override_type, tsl_override_qty,
            fixed_tsl_load_override_reason override_reason,
            TO_CHAR (TO_NUMBER (tsl_override_user)),
            last_update_dt begin_date, null end_date,
            'AMD_LOCPART_OVERID_CONSUMABLES' source,
            last_update_dt last_modified
       from amd_locpart_overid_consumables, amd_spo_types_v
      where action_code <> 'D' and tsl_override_qty is not null
   order by 1, 2, 3;


DROP PUBLIC SYNONYM AMD_LP_OVERRIDE_WK_V;

CREATE PUBLIC SYNONYM AMD_LP_OVERRIDE_WK_V FOR AMD_OWNER.AMD_LP_OVERRIDE_WK_V;


GRANT SELECT ON AMD_OWNER.AMD_LP_OVERRIDE_WK_V TO AMD_READER_ROLE;

