SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_PLANNED_PART_V;

/* Formatted on 2008/09/26 20:16 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_part_planned_part_v (part,
                                                              planned_part,
                                                              supersession_type,
                                                              begin_date,
                                                              end_date,
                                                              TIMESTAMP,
                                                              spo_user,
                                                              SOURCE
                                                             )
AS
   SELECT part, parts2.spo_prime_part_no planned_part, supersession_type,
          assignment_date begin_date,
          TO_DATE ('12/31/4100', 'MM/DD/YYYY') end_date, SYSDATE TIMESTAMP,
          'SPO' spo_user, 'RBL_PAIRS' SOURCE
     FROM (SELECT old_prime_part_no part,
                  amd_utils.getprimepartno (planned_nsn) planned_part,
                  supersession_type
             FROM amd_twoway_rbl_pairs_v twoway,
                  (SELECT old_nsn planned_nsn, new_nsn
                     FROM amd_rbl_pairs a
                    WHERE subgroup_code = (SELECT subgroup_code
                                             FROM amd_rbl_pairs
                                            WHERE old_nsn = a.new_nsn)
                      AND part_pref_code =
                             (SELECT MAX (part_pref_code)
                                FROM amd_rbl_pairs
                               WHERE new_nsn = a.new_nsn
                                 AND subgroup_code =
                                                  (SELECT subgroup_code
                                                     FROM amd_rbl_pairs
                                                    WHERE old_nsn = a.new_nsn))) planned
            WHERE twoway.new_nsn = planned.new_nsn) twoway_planned,
          amd_nsi_parts nsi,
          amd_spare_parts parts1,
          amd_spare_parts parts2
    WHERE twoway_planned.part = parts1.part_no
      AND parts1.is_spo_part = 'Y'
      AND twoway_planned.planned_part = parts2.part_no
      AND parts2.is_spo_part = 'Y'
      AND nsi.part_no = twoway_planned.part
      AND nsi.unassignment_date IS NULL
   UNION
   SELECT parts.part_no, parts.spo_prime_part_no planned_part,
          'TWO-WAY' supersession_type, alts.assignment_date begin_date,
          CASE
             WHEN parts.action_code = 'D'
                THEN parts.last_update_dt
             ELSE TO_DATE ('12/31/4100', 'MM/DD/YYYY')
          END end_date,
          SYSDATE TIMESTAMP, 'SPO' spo_user, 'ALTERNATE_PARTS' SOURCE
     FROM amd_spare_parts parts,
          amd_national_stock_items items,
          amd_nsi_parts alts
    WHERE parts.is_spo_part = 'Y'
      AND parts.nsn = items.nsn
      AND items.action_code <> 'D'
      AND parts.part_no <> items.prime_part_no
      AND parts.part_no = alts.part_no
      AND alts.unassignment_date IS NULL
      AND alts.prime_ind = 'N';


DROP PUBLIC SYNONYM X_PART_PLANNED_PART_V;

CREATE PUBLIC SYNONYM X_PART_PLANNED_PART_V FOR AMD_OWNER.X_PART_PLANNED_PART_V;


GRANT SELECT ON AMD_OWNER.X_PART_PLANNED_PART_V TO AMD_READER_ROLE;


