SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_TWOWAY_RBL_PAIRS_V;

/* Formatted on 2008/10/07 14:28 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_twoway_rbl_pairs_v (old_nsn,
                                                               old_prime_part_no,
                                                               old_action_code,
                                                               old_last_update_dt,
                                                               new_nsn,
                                                               new_prime_part_no,
                                                               new_action_code,
                                                               new_last_update_dt,
                                                               supersession_type,
                                                               subgroup_code,
                                                               part_pref_code
                                                              )
AS
   SELECT   old_nsn, olditems.prime_part_no old_prime_part_no,
            olditems.action_code old_action_code,
            olditems.last_update_dt old_last_update_dt, new_nsn,
            newitems.prime_part_no new_prime_part_no,
            newitems.action_code new_action_code,
            newitems.last_update_dt old_last_update_dt,
            'TWO-WAY' supersession_type, subgroup_code, part_pref_code
       FROM amd_rbl_pairs a,
            amd_national_stock_items olditems,
            amd_national_stock_items newitems
      WHERE a.action_code <> 'D'
        AND a.old_nsn <> a.new_nsn
        AND subgroup_code = (SELECT subgroup_code
                               FROM amd_rbl_pairs
                              WHERE old_nsn = a.new_nsn)
        AND old_nsn = olditems.nsn
        AND olditems.action_code <> 'D'
        AND new_nsn = newitems.nsn
        AND newitems.action_code <> 'D'
   ORDER BY new_nsn, subgroup_code, part_pref_code;


DROP PUBLIC SYNONYM AMD_TWOWAY_RBL_PAIRS_V;

CREATE PUBLIC SYNONYM AMD_TWOWAY_RBL_PAIRS_V FOR AMD_OWNER.AMD_TWOWAY_RBL_PAIRS_V;

GRANT SELECT ON AMD_OWNER.AMD_twoway_rbl_pairs_V TO AMD_READER_ROLE ;

