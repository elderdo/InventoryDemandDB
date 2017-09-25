SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_ISGP_GROUPS_V;

/* Formatted on 2009/06/25 13:17 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_isgp_groups_v (group_no,
                                                          rank,
                                                          group_priority,
                                                          sequence_no
                                                         )
as
   select   amd_isgp.group_no, amd_utils.rank (amd_isgp.group_priority) rank,
            amd_isgp.group_priority, max (sequence_no) sequence_no
       from amd_isgp,
            (select   group_no, max (amd_utils.rank (group_priority)) rank,
                      amd_utils.grouppriority
                          (max (amd_utils.rank (group_priority))
                          ) group_priority
                 from amd_isgp a, amd_spare_parts parts
                where group_priority is not null
                  and part = part_no
                  and action_code <> 'D'
             group by group_no
               having count (nsn) > 1
                  and max (amd_utils.rank (group_priority)) >= 13330
                                                                    --  ie group_priority >= AAA
            ) group_info
      where amd_isgp.group_no = group_info.group_no
        and amd_isgp.group_priority = group_info.group_priority
   group by amd_isgp.group_no, amd_isgp.group_priority
   order by group_no;


DROP PUBLIC SYNONYM AMD_ISGP_GROUPS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_GROUPS_V FOR AMD_OWNER.AMD_ISGP_GROUPS_V;


GRANT SELECT ON AMD_OWNER.AMD_ISGP_GROUPS_V TO AMD_READER_ROLE;

