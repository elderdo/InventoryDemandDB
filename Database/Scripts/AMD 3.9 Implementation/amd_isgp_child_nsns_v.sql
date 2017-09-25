SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_ISGP_CHILD_NSNS_V;

/* Formatted on 2009/06/25 13:21 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_isgp_child_nsns_v (group_no,
                                                              old_nsn,
                                                              new_nsn,
                                                              subgroup_code,
                                                              part_pref_code
                                                             )
as
   select distinct amd_isgp.group_no, parts.nsn old_nsn,
                   master_nsns.new_nsn new_nsn,
                   SUBSTR (amd_isgp.group_priority, 1, 2) subgroup_code,
                   SUBSTR (amd_isgp.group_priority, 3, 1) part_pref_code
              from amd_isgp,
                   amd_isgp_groups_v,
                   amd_spare_parts parts,
                   amd_isgp_master_nsns_v master_nsns
             where amd_isgp.group_no = amd_isgp_groups_v.group_no
               and parts.part_no = amd_isgp.part
               and parts.action_code <> 'D'
               and amd_isgp.group_priority <> amd_isgp_groups_v.group_priority
               and amd_isgp.group_no = master_nsns.group_no
          order by group_no, subgroup_code desc, part_pref_code desc;


DROP PUBLIC SYNONYM AMD_ISGP_CHILD_NSNS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_CHILD_NSNS_V FOR AMD_OWNER.AMD_ISGP_CHILD_NSNS_V;


GRANT SELECT ON AMD_OWNER.AMD_ISGP_CHILD_NSNS_V TO AMD_READER_ROLE;

