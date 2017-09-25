SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_PLANNED_PART_V;

/* Formatted on 2009/07/08 16:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_part_planned_part_v (part,
                                                              planned_part,
                                                              supersession_type,
                                                              begin_date,
                                                              end_date,
                                                              last_modified,
                                                              spo_user,
                                                              source
                                                             )
as
   select part, parts2.spo_prime_part_no planned_part, supersession_type,
          assignment_date begin_date,
          to_date ('12/31/4100', 'MM/DD/YYYY') end_date,
          SYSDATE last_modified, 'SPO' spo_user, 'RBL_PAIRS' source
     from (select old_prime_part_no part,
                  amd_utils.getprimepartno (planned_nsn) planned_part,
                  supersession_type
             from amd_twoway_rbl_pairs_v twoway,
                  (select old_nsn planned_nsn, new_nsn
                     from amd_rbl_pairs a
                    where subgroup_code = (select subgroup_code
                                             from amd_rbl_pairs
                                            where old_nsn = a.new_nsn)
                      and part_pref_code =
                             (select max (part_pref_code)
                                from amd_rbl_pairs
                               where new_nsn = a.new_nsn
                                 and subgroup_code =
                                                  (select subgroup_code
                                                     from amd_rbl_pairs
                                                    where old_nsn = a.new_nsn))) planned
            where twoway.new_nsn = planned.new_nsn) twoway_planned,
          amd_nsi_parts nsi,
          amd_spare_parts parts1,
          amd_spare_parts parts2
    where twoway_planned.part = parts1.part_no
      and parts1.is_spo_part = 'Y'
      and twoway_planned.planned_part = parts2.part_no
      and parts2.is_spo_part = 'Y'
      and nsi.part_no = twoway_planned.part
      and nsi.unassignment_date is null
   union
   select parts.part_no, parts.spo_prime_part_no planned_part,
          two_way_supersession supersession_type,
          alts.assignment_date begin_date,
          case
             when parts.action_code = 'D'
                then parts.last_update_dt
             else to_date ('12/31/4100', 'MM/DD/YYYY')
          end end_date,
          SYSDATE last_modified, 'SPO' spo_user, 'ALTERNATE_PARTS' source
     from amd_spare_parts parts,
          amd_national_stock_items items,
          amd_nsi_parts alts,
          amd_spo_types_v
    where parts.is_spo_part = 'Y'
      and parts.nsn = items.nsn
      and items.action_code <> 'D'
      and parts.part_no <> items.prime_part_no
      and parts.part_no = alts.part_no
      and alts.unassignment_date is null
      and alts.prime_ind = 'N';


DROP PUBLIC SYNONYM X_PART_PLANNED_PART_V;

CREATE PUBLIC SYNONYM X_PART_PLANNED_PART_V FOR AMD_OWNER.X_PART_PLANNED_PART_V;


GRANT SELECT ON AMD_OWNER.X_PART_PLANNED_PART_V TO AMD_READER_ROLE;

