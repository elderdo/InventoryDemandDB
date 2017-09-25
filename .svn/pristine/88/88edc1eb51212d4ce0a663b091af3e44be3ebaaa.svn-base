SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_ISGP_RBL_PAIRS_V;

/* Formatted on 2009/06/25 12:21 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_isgp_rbl_pairs_v (group_no,
                                                             old_nsn,
                                                             new_nsn,
                                                             subgroup_code,
                                                             part_pref_code
                                                            )
as
   select   "GROUP_NO", "OLD_NSN", "NEW_NSN", "SUBGROUP_CODE",
            "PART_PREF_CODE"
       from amd_isgp_master_nsns_v
      where exists (select null
                      from amd_isgp_child_nsns_v
                     where amd_isgp_master_nsns_v.group_no = group_no)
   union
   select   "GROUP_NO", "OLD_NSN", "NEW_NSN", "SUBGROUP_CODE",
            "PART_PREF_CODE"
       from amd_isgp_child_nsns_v
   order by 1, 4 desc, 5 desc;


DROP PUBLIC SYNONYM AMD_ISGP_RBL_PAIRS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_RBL_PAIRS_V FOR AMD_OWNER.AMD_ISGP_RBL_PAIRS_V;


GRANT SELECT ON AMD_OWNER.AMD_ISGP_RBL_PAIRS_V TO AMD_READER_ROLE;

