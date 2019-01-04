DROP VIEW AMD_OWNER.ACTIVE_PARTS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.ACTIVE_PARTS_V
(
   NSN,
   PART_NO,
   ASSIGNMENT_DT,
   PRIME_IND,
   PRIME_EQUIV_SEQ
)
   BEQUEATH DEFINER
AS
     SELECT nsn,
            part_no,
            last_update_dt,
            (SELECT prime_ind
               FROM amd_nsi_parts
              WHERE part_no = p.part_no AND unassignment_date IS NULL)
               prime_ind,
            CASE (SELECT prime_ind
                    FROM amd_nsi_parts
                   WHERE part_no = p.part_no AND unassignment_date IS NULL)
               WHEN 'Y' THEN 1
               ELSE 2
            END
               seq
       FROM amd_spare_parts p
      WHERE action_code <> 'D'
   ORDER BY nsn, seq;


DROP VIEW AMD_OWNER.AMDII_2A_CAT1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_2A_CAT1_V
(
   NSN,
   PART_NO,
   PRIME_PART_NO,
   ITEM_TYPE,
   SMR_CODE
)
   BEQUEATH DEFINER
AS
   SELECT sp.nsn,
          sp.part_no part_no,
          nsi.prime_part_no,
          nsi.item_type,
          nsi.smr_code
     FROM amd_spare_parts sp, amd_national_stock_items nsi
    WHERE     sp.nsn = nsi.nsn
          AND sp.action_code != 'D'
          AND nsi.action_code != 'D';


DROP VIEW AMD_OWNER.AMDII_DI_DEMANDS_SRANS_CONV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_DI_DEMANDS_SRANS_CONV_V
(
   NSN,
   SRAN,
   DOC_DATE,
   DEMAND
)
   BEQUEATH DEFINER
AS
     SELECT n.nsn,
            NVL (new_value, s.loc_id)                           sran,
            TO_CHAR (TRUNC (d.doc_date, 'MONTH'), 'mm/"01"/yyyy') doc_date,
            SUM (d.quantity)                                    demand
       FROM amd_demands            d,
            amd_spare_networks     s,
            amd_national_stock_items n,
            amd_substitutions      subs
      WHERE     d.loc_sid = s.loc_sid
            AND subs.substitution_name(+) = 'AMDII_di_Demands_SRANS-Conv'
            AND subs.substitution_type(+) = 'SRAN'
            AND subs.original_value(+) = s.loc_id
            AND subs.action_code(+) <> 'D'
            AND d.nsi_sid = n.nsi_sid
            AND n.action_code IN ('A', 'C')
            AND d.doc_date > TO_DATE ('12/31/2001', 'mm/dd/yyyy')
   GROUP BY n.nsn,
            NVL (subs.new_value, s.loc_id),
            TO_CHAR (TRUNC (d.doc_date, 'MONTH'), 'mm/"01"/yyyy');


DROP VIEW AMD_OWNER.AMDII_DI_DEMANDS_SUM_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_DI_DEMANDS_SUM_V
(
   NSN,
   SRAN,
   DOC_DATE,
   DEMAND
)
   BEQUEATH DEFINER
AS
     SELECT n.nsn,
            NVL (l.list_value, s.loc_id)                      sran,
            TO_CHAR (TRUNC (d.doc_date, 'MONTH'), 'mm/dd/yyyy') doc_date,
            SUM (d.quantity)                                  demand
       FROM amd_for_di_demands_sum_v d,
            amd_spare_networks     s,
            amd_national_stock_items n,
            amd_lists              l
      WHERE     d.loc_sid = s.loc_sid
            AND d.nsi_sid = n.nsi_sid
            AND n.action_code IN ('A', 'C')
            AND d.doc_date > TO_DATE ('12/31/1999', 'mm/dd/yyyy')
            AND l.list_name(+) = 'AMDII_di_Demands_sum'
            AND l.list_value(+) = SUBSTR (d.doc_no, 1, 6)
   GROUP BY n.nsn, NVL (l.list_value, s.loc_id), TRUNC (d.doc_date, 'MONTH');


DROP VIEW AMD_OWNER.AMDII_DI_INVENTORY_SRAN_CONV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_DI_INVENTORY_SRAN_CONV_V
(
   NSN,
   SRAN,
   INVENTORY
)
   BEQUEATH DEFINER
AS
     SELECT asp.nsn, NVL (new_value, asn.loc_id) sran, SUM (invQty) inventory
       FROM (SELECT part_no, loc_sid, repair_qty invQty
               FROM amd_in_repair
              WHERE action_code != 'D'
             UNION ALL
             SELECT part_no, loc_sid, inv_qty invQty
               FROM amd_on_hand_invs
              WHERE action_code != 'D'
             UNION ALL
             SELECT part_no, loc_sid, order_qty invQty
               FROM amd_on_order
              WHERE action_code != 'D'
             UNION ALL
             SELECT RTRIM (part_no), to_loc_sid, quantity invQty
               FROM amd_in_transits
              WHERE action_code != 'D') transQ,
            amd_spare_parts  asp,
            amd_spare_networks asn,
            amd_substitutions subs
      WHERE     transQ.part_no = asp.part_no
            AND transQ.loc_sid = asn.loc_sid
            AND subs.substitution_name(+) = 'AMDII_di_Inventory_SRANS-Conv'
            AND subs.substitution_type(+) = 'SRAN'
            AND subs.original_value(+) = asn.loc_id
            AND subs.action_code(+) <> 'D'
            AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT')
            AND asp.action_code != 'D'
   GROUP BY asp.nsn, NVL (new_value, asn.loc_id);


DROP VIEW AMD_OWNER.AMDII_DI_INVENTORY_SUMMED_W_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_DI_INVENTORY_SUMMED_W_V
(
   NSN,
   SRAN,
   INVENTORY
)
   BEQUEATH DEFINER
AS
     SELECT asp.nsn, 'W', SUM (invQty)
       FROM (SELECT part_no, loc_sid, repair_qty invQty
               FROM amd_in_repair
              WHERE action_code != 'D'
             UNION ALL
             SELECT part_no, loc_sid, inv_qty invQty
               FROM amd_on_hand_invs
              WHERE action_code != 'D'
             UNION ALL
             SELECT part_no, loc_sid, order_qty invQty
               FROM amd_on_order
              WHERE action_code != 'D'
             UNION ALL
             SELECT RTRIM (part_no), to_loc_sid, quantity invQty
               FROM amd_in_transits
              WHERE action_code != 'D') transQ,
            amd_spare_parts  asp,
            amd_spare_networks asn
      WHERE     transQ.part_no = asp.part_no
            AND transQ.loc_sid = asn.loc_sid
            AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT')
            AND asp.action_code != 'D'
            AND (   loc_id LIKE 'FB%'
                 OR loc_id LIKE 'EY%'
                 OR loc_id IN (SELECT cod
                                 FROM bssm_owner.bssm_cods
                                WHERE lock_sid = 0))
   GROUP BY asp.nsn, 'W';


DROP VIEW AMD_OWNER.AMDII_DI_INVENTORY_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_DI_INVENTORY_V
(
   NSN,
   SRAN,
   INVENTORY
)
   BEQUEATH DEFINER
AS
     SELECT TO_CHAR (asp.nsn), asn.loc_id, SUM (invQty)
       FROM (SELECT part_no, loc_sid, repair_qty invQty
               FROM amd_in_repair
              WHERE action_code != 'D'
             UNION ALL
             SELECT part_no, loc_sid, inv_qty invQty
               FROM amd_on_hand_invs
              WHERE action_code != 'D'
             UNION ALL
             SELECT part_no, loc_sid, order_qty invQty
               FROM amd_on_order
              WHERE action_code != 'D'
             UNION ALL
             SELECT RTRIM (part_no), to_loc_sid, quantity invQty
               FROM amd_in_transits
              WHERE action_code != 'D') transQ,
            amd_spare_parts  asp,
            amd_spare_networks asn
      WHERE     transQ.part_no = asp.part_no
            AND transQ.loc_sid = asn.loc_sid
            AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT', 'SUP')
            AND asp.action_code != 'D'
   GROUP BY asp.nsn, asn.loc_id;


DROP VIEW AMD_OWNER.AMDII_IN_REPAIR_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_IN_REPAIR_V
(
   NSN,
   IN_REPAIR
)
   BEQUEATH DEFINER
AS
     SELECT asp.nsn, SUM (repair_qty) in_repair
       FROM amd_in_repair air, amd_spare_parts asp, amd_spare_networks asn
      WHERE     air.part_no = asp.part_no
            AND air.loc_sid = asn.loc_sid
            AND air.action_code != 'D'
            AND asp.action_code != 'D'
            AND asn.action_code != 'D'
            AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT', 'SUP')
   GROUP BY asp.nsn;


DROP VIEW AMD_OWNER.AMDII_PART_INFO2_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_PART_INFO2_V
(
   NSN,
   SRAN,
   RSP_ON_HAND,
   RSP_OBJECTIVE
)
   BEQUEATH DEFINER
AS
   SELECT ansi.nsn,
          asn.loc_id sran,
          (  NVL (wrm_balance, 0)
           + NVL (spram_balance, 0)
           + NVL (hpmsk_balance, 0))
             rsp_on_hand,
          (  NVL (wrm_level, 0)
           + NVL (spram_level, 0)
           + NVL (hpmsk_level_qty, 0))
             rsp_objective
     FROM ramp r, amd_national_stock_items ansi, amd_spare_networks asn
    WHERE     SUBSTR (r.sc, 8, 6) = asn.loc_id
          AND asn.loc_type IN ('MOB', 'FSL')
          AND REPLACE (r.current_stock_number, '-') = ansi.nsn
          AND asn.action_code != 'D'
          AND ansi.action_code != 'D'
          AND (   (  NVL (wrm_balance, 0)
                   + NVL (spram_balance, 0)
                   + NVL (hpmsk_balance, 0)) > 0
               OR (  NVL (wrm_level, 0)
                   + NVL (spram_level, 0)
                   + NVL (hpmsk_level_qty, 0)) > 0);


DROP VIEW AMD_OWNER.AMDII_PART_INFO_A_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_PART_INFO_A_V
(
   NSN,
   MIC,
   PLANNER_CODE,
   SMR_CODE,
   MTBDR,
   MMAC,
   PART_NO,
   MFGR,
   ORDER_LEAD_TIME,
   ORDER_UOM,
   UNIT_OF_ISSUE,
   UNIT_COST,
   ACQUISITION_ADVICE_CODE,
   CURRENT_BACKORDER
)
   BEQUEATH DEFINER
AS
   SELECT nsi.nsn,
          nsi.mic_code_lowest,
          nsi.planner_code,
          nsi.smr_code,
          nsi.mtbdr,
          l.list_value mmac,
          sp.part_no,
          sp.mfgr,
          sp.order_lead_time,
          sp.order_uom,
          sp.unit_of_issue,
          sp.unit_cost,
          sp.acquisition_advice_code,
          nsi.current_backorder
     FROM amd_national_stock_items nsi, amd_spare_parts sp, amd_lists l
    WHERE     nsi.action_code IN ('A', 'C')
          AND sp.action_code IN ('A', 'C')
          AND nsi.nsn = sp.nsn
          AND nsi.prime_part_no = sp.part_no
          AND l.list_name(+) = 'AMDII_Part_Info_A'
          AND l.list_value(+) = nsi.mmac;


DROP VIEW AMD_OWNER.AMDII_PART_INFO_B_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_PART_INFO_B_V
(
   NSN,
   NOMENCLATURE
)
   BEQUEATH DEFINER
AS
   SELECT nsi.nsn,
          SUBSTR (REPLACE (sp.nomenclature, CHR (13), ' '), 1, 40)
             nomenclature
     FROM amd_national_stock_items nsi, amd_spare_parts sp
    WHERE     nsi.action_code IN ('A', 'C')
          AND nsi.nsn = sp.nsn
          AND sp.action_code IN ('A', 'C')
          AND nsi.prime_part_no = sp.part_no;


DROP VIEW AMD_OWNER.AMDII_PART_INFO_C_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMDII_PART_INFO_C_V
(
   NSN,
   OFF_BASE_REPAIR_COST,
   OFF_BASE_TURNAROUND
)
   BEQUEATH DEFINER
AS
   SELECT nsi.nsn,
          DECODE (
             LENGTH (nsi.smr_code),
             6, DECODE (SUBSTR (nsi.smr_code, 6, 1),
                        'N', NULL,
                        'P', NULL,
                        'S', NULL,
                        'U', NULL,
                        cost_to_repair_off_base),
             NULL)
             off_base_repair_cost,
          TO_CHAR (time_to_repair_off_base, '9999999D9999999999')
             off_base_turnaround
     FROM amd_national_stock_items nsi
    WHERE nsi.action_code IN ('A', 'C');


DROP VIEW AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V
(
   NSN,
   PRIME_PART_NO
)
   BEQUEATH DEFINER
AS
   SELECT DISTINCT n.nsn, prime_part_no
     FROM amd_demands d, amd_national_stock_items n
    WHERE     d.doc_no LIKE 'B%'
          AND d.nsi_sid = n.nsi_sid
          AND n.action_code <> 'D';


DROP VIEW AMD_OWNER.AMD_BLIS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_BLIS_V
(
   OLD_NSN,
   NEW_NSN
)
   BEQUEATH DEFINER
AS
   SELECT old_nsn, new_nsn
     FROM bssm_isg_pairs
    WHERE lock_sid = 0
   UNION
   SELECT new_nsn, new_nsn
     FROM bssm_isg_pairs
    WHERE lock_sid = 0
   ORDER BY new_nsn;


DROP VIEW AMD_OWNER.AMD_CONSUMABLE_PARTS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_CONSUMABLE_PARTS_V
(
   PART_NO,
   ACTION_CODE,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT parts.part_no, parts.action_code, parts.last_update_dt
     FROM amd_spare_parts parts
    WHERE parts.is_consumable = 'Y';


DROP VIEW AMD_OWNER.AMD_DEFAULT_PLANNERS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_DEFAULT_PLANNERS_V
(
   PLANNER_CODE,
   DEFAULT_TYPE,
   EFFECTIVE_DATE
)
   BEQUEATH DEFINER
AS
   SELECT param_value, 'CONSUMABLE', effective_date
     FROM amd_param_changes
    WHERE     param_key = 'consumable_planner_code'
          AND effective_date = (SELECT MAX (effective_date)
                                  FROM amd_param_changes
                                 WHERE param_key = 'consumable_planner_code')
   UNION
   SELECT param_value, 'REPAIRABLE', effective_date
     FROM amd_param_changes
    WHERE     param_key = 'repairable_planner_code'
          AND effective_date = (SELECT MAX (effective_date)
                                  FROM amd_param_changes
                                 WHERE param_key = 'repairable_planner_code');


DROP VIEW AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V
(
   PLANNER_CODE,
   PLANNER_CODE_EFFECTIVE_DATE,
   LOGON_ID,
   LOGON_ID_EFFECTIVE_DATE,
   DATA_SOURCE,
   DEFAULT_TYPE
)
   BEQUEATH DEFINER
AS
   SELECT planner.planner_code,
          planner.effective_date,
          users.bems_id,
          users.effective_date,
          '3' data_source,
          users.default_type
     FROM amd_default_planners_v planner, amd_default_users_v users
    WHERE planner.default_type = users.default_type;


DROP VIEW AMD_OWNER.AMD_DEFAULT_USERS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_DEFAULT_USERS_V
(
   BEMS_ID,
   STABLE_EMAIL,
   LAST_NAME,
   FIRST_NAME,
   EFFECTIVE_DATE,
   DEFAULT_TYPE
)
   BEQUEATH DEFINER
AS
   SELECT param_value,
          stable_email,
          last_name,
          first_name,
          effective_date,
          'CONSUMABLE'
     FROM amd_param_changes, amd_people_all_v
    WHERE     param_key = 'consumable_logon_id'
          AND effective_date = (SELECT MAX (effective_date)
                                  FROM amd_param_changes
                                 WHERE param_key = 'consumable_logon_id')
          AND param_value = bems_id
   UNION
   SELECT param_value,
          stable_email,
          last_name,
          first_name,
          effective_date,
          'REPAIRABLE'
     FROM amd_param_changes, amd_people_all_v
    WHERE     param_key = 'repairable_logon_id'
          AND effective_date = (SELECT MAX (effective_date)
                                  FROM amd_param_changes
                                 WHERE param_key = 'repairable_logon_id')
          AND param_value = bems_id;


DROP VIEW AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V
(
   DOC_NO,
   DOC_DATE,
   DOC_DATE_DEFAULTED,
   NSI_SID,
   NSN,
   LOC_SID,
   LOC_ID,
   QUANTITY,
   NTWKS_ACTION_CODE,
   DMNDS_ACTION_CODE,
   NTWKS_LAST_UPDATE_DT,
   DMNDS_LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT doc_no,
          doc_date,
          doc_date_defaulted,
          d.nsi_sid,
          nsn,
          CASE
             WHEN SUBSTR (doc_no, 1, 1) = 'M'
             THEN
                amd_utils.GetLocSid ('FB2065')
             WHEN SUBSTR (doc_no, 1, 3) IN ('C17', 'REQ')
             THEN
                amd_utils.GetLocSid ('EY1746')
             ELSE
                d.loc_sid
          END
             loc__sid,
          loc_id,
          quantity,
          ntwks.action_code    ntwks_action_code,
          d.action_code        dmnds_action_code,
          ntwks.last_update_dt ntwks_last_update_dt,
          d.last_update_dt
     FROM amd_demands              d,
          amd_national_stock_items items,
          amd_spare_networks       ntwks
    WHERE d.nsi_sid = items.nsi_sid AND d.loc_sid = ntwks.loc_sid;


DROP VIEW AMD_OWNER.AMD_ISGP_CHILD_NSNS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_ISGP_CHILD_NSNS_V
(
   GROUP_NO,
   OLD_NSN,
   NEW_NSN,
   SUBGROUP_CODE,
   PART_PREF_CODE
)
   BEQUEATH DEFINER
AS
     SELECT DISTINCT amd_isgp.group_no,
                     parts.nsn                            old_nsn,
                     master_nsns.new_nsn                  new_nsn,
                     SUBSTR (amd_isgp.group_priority, 1, 2) subgroup_code,
                     SUBSTR (amd_isgp.group_priority, 3, 1) part_pref_code
       FROM amd_isgp,
            amd_isgp_groups_v,
            amd_spare_parts      parts,
            amd_isgp_master_nsns_v master_nsns
      WHERE     amd_isgp.group_no = amd_isgp_groups_v.group_no
            AND parts.part_no = amd_isgp.part
            AND parts.action_code <> 'D'
            AND amd_isgp.group_priority <> amd_isgp_groups_v.group_priority
            AND amd_isgp.group_no = master_nsns.group_no
   ORDER BY group_no, subgroup_code DESC, part_pref_code DESC;


DROP VIEW AMD_OWNER.AMD_ISGP_GROUPS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_ISGP_GROUPS_V
(
   GROUP_NO,
   RANK,
   GROUP_PRIORITY,
   SEQUENCE_NO
)
   BEQUEATH DEFINER
AS
     SELECT amd_isgp.group_no,
            amd_utils.RANK (amd_isgp.group_priority) RANK,
            amd_isgp.group_priority,
            MAX (sequence_no)                      sequence_no
       FROM amd_isgp,
            (  SELECT group_no,
                      MAX (amd_utils.RANK (group_priority)) RANK,
                      amd_utils.grouppriority (
                         MAX (amd_utils.RANK (group_priority)))
                         group_priority
                 FROM amd_isgp a, amd_spare_parts parts
                WHERE     group_priority IS NOT NULL
                      AND part = part_no
                      AND action_code <> 'D'
             GROUP BY group_no
               HAVING     COUNT (nsn) > 1
                      AND MAX (amd_utils.RANK (group_priority)) >= 13330 --  ie group_priority >= AAA
                                                                        )
            group_info
      WHERE     amd_isgp.group_no = group_info.group_no
            AND amd_isgp.group_priority = group_info.group_priority
   GROUP BY amd_isgp.group_no, amd_isgp.group_priority
   ORDER BY group_no;


DROP VIEW AMD_OWNER.AMD_ISGP_MASTER_NSNS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_ISGP_MASTER_NSNS_V
(
   GROUP_NO,
   OLD_NSN,
   NEW_NSN,
   SUBGROUP_CODE,
   PART_PREF_CODE
)
   BEQUEATH DEFINER
AS
   SELECT amd_isgp.group_no,
          parts.nsn                              old_nsn,
          parts.nsn                              new_nsn,
          SUBSTR (amd_isgp.group_priority, 1, 2) subgroup_code,
          SUBSTR (amd_isgp.group_priority, 3, 1) part_pref_code
     FROM amd_isgp, amd_isgp_groups_v, amd_spare_parts parts
    WHERE     amd_isgp.group_no = amd_isgp_groups_v.group_no
          AND parts.part_no = amd_isgp.part
          AND parts.action_code <> 'D'
          AND amd_isgp.group_priority = amd_isgp_groups_v.group_priority
          AND amd_isgp.sequence_no = amd_isgp_groups_v.sequence_no;


DROP VIEW AMD_OWNER.AMD_ISGP_RBL_PAIRS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_ISGP_RBL_PAIRS_V
(
   GROUP_NO,
   OLD_NSN,
   NEW_NSN,
   SUBGROUP_CODE,
   PART_PREF_CODE
)
   BEQUEATH DEFINER
AS
   SELECT "GROUP_NO",
          "OLD_NSN",
          "NEW_NSN",
          "SUBGROUP_CODE",
          "PART_PREF_CODE"
     FROM amd_isgp_master_nsns_v
    WHERE EXISTS
             (SELECT NULL
                FROM amd_isgp_child_nsns_v
               WHERE amd_isgp_master_nsns_v.group_no = group_no)
   UNION
   SELECT "GROUP_NO",
          "OLD_NSN",
          "NEW_NSN",
          "SUBGROUP_CODE",
          "PART_PREF_CODE"
     FROM amd_isgp_child_nsns_v
   ORDER BY 1, 4 DESC, 5 DESC;


DROP VIEW AMD_OWNER.AMD_PART_HEADER_V5;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PART_HEADER_V5
(
   PH_CAGE_CODE,
   PH_PART_NO,
   PH_PRIME_CAGE,
   PH_PRIME_PART,
   PH_LEAD_TIME,
   PH_LEAD_TIME_TYPE
)
   BEQUEATH DEFINER
AS
   SELECT asp.mfgr               AS ph_cage_code,
          asp.part_no            AS ph_part_no,
          aspPrime.mfgr          AS ph_prime_mfgr,
          asta.spo_prime_part_no AS ph_prime_part,
          amd_preferred_pkg.GetPreferredValue (ansi.order_lead_time_cleaned,
                                               asp.order_lead_time,
                                               asp.order_lead_time_defaulted)
             AS ph_lead_time,
          'NEW-BUY'              AS ph_lead_time_type
     FROM AMD_NATIONAL_STOCK_ITEMS ansi,
          AMD_SPARE_PARTS          asp,
          AMD_SPARE_PARTS          aspPrime,
          AMD_SENT_TO_A2A          asta
    WHERE     asta.spo_prime_part_no = aspPrime.part_no
          AND asta.part_no = asp.part_no
          AND asp.nsn = ansi.nsn;


DROP VIEW AMD_OWNER.AMD_PART_IDS;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PART_IDS
(
   PART_NO,
   MFGR_CAGE,
   CURRENT_PRIME_PART_NO,
   CURRENT_NSN,
   BEST_NOMENCLATURE
)
   BEQUEATH DEFINER
AS
   SELECT SP.PART_NO,
          SP.MFGR,
          NSI.PRIME_PART_NO,
          NSI.NSN,
          CASE
             WHEN (    NSI.PRIME_PART_NO = SP.PART_NO
                   AND NSI.NOMENCLATURE_CLEANED IS NOT NULL)
             THEN
                NSI.NOMENCLATURE_CLEANED
             ELSE
                SP.NOMENCLATURE
          END
     FROM AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS NSI,
          AMD_OWNER.AMD_NSI_PARTS            NP,
          AMD_OWNER.AMD_SPARE_PARTS          SP
    WHERE     NSI.NSI_SID = NP.NSI_SID
          AND NP.PART_NO = SP.PART_NO
          AND NP.UNASSIGNMENT_DATE IS NULL;


DROP VIEW AMD_OWNER.AMD_PEOPLE_ALL_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PEOPLE_ALL_V
(
   EMP_ID,
   BEMS_ID,
   DOB,
   FIRST_NAME,
   LAST_NAME,
   COMPONENT,
   BUS_UNIT,
   DIVISION,
   SUB_DIV,
   DEPTNO,
   SHIFT,
   EMP_STATUS,
   CONTRACT_VENDOR_CODE,
   ADMIN_NO,
   ADMIN_NAME,
   LAST_UPDATE_DATE,
   HRDEPTID,
   LOCATION,
   FLSA_STATUS,
   MGR_ID,
   HR_MGR_LAST_NAME,
   HR_MGR_FIRST_NAME,
   ACCTG_BUS_UNIT_NM,
   ACCT_DEPT_NM,
   FLOOR,
   MAIL_CODE,
   ROOM_NMBR,
   BLDG,
   STABLE_EMAIL,
   LAST_ORG_LVL_Z,
   REPORTS_TO_HRDEPT_ID,
   WORK_PHONE,
   DEPT_NMW,
   PAYOFFICE_CDM,
   ACCTG_LOC_CDM,
   LA_MGR_ID_BEMS,
   LA_MGR_LAST_NAME,
   LA_MGR_FIRST_NAME,
   MGMT_JOBCODE,
   PS_SUPERVISOR_BEMS,
   JOBCODE,
   JOB_TITLE_NMW,
   LEAD_FLGM,
   LV_EFF_DTW,
   UNION_CD,
   UNION_SENIORITY_DT,
   DIRECT,
   BEMS_IDN,
   STANDARD_ID,
   MGR_IDN,
   LA_MGR_ID_BEMSN,
   PS_SUPERVISOR_BEMSN
)
   BEQUEATH DEFINER
AS
   SELECT a.EMP_ID,
          a.BEMS_ID,
          a.DOB,
          a.FIRST_NAME,
          a.LAST_NAME,
          a.COMPONENT,
          a.BUS_UNIT,
          a.DIVISION,
          a.SUB_DIV,
          a.DEPTNO,
          a.SHIFT,
          a.EMP_STATUS,
          a.CONTRACT_VENDOR_CODE,
          a.ADMIN_NO,
          a.ADMIN_NAME,
          a.LAST_UPDATE_DATE,
          a.HRDEPTID,
          a.LOCATION,
          a.FLSA_STATUS,
          a.MGR_ID,
          a.HR_MGR_LAST_NAME,
          a.HR_MGR_FIRST_NAME,
          a.ACCTG_BUS_UNIT_NM,
          a.ACCT_DEPT_NM,
          a.FLOOR,
          a.MAIL_CODE,
          a.ROOM_NMBR,
          a.BLDG,
          b.email_addr,
          a.LAST_ORG_LVL_Z,
          a.REPORTS_TO_HRDEPT_ID,
          a.WORK_PHONE,
          a.DEPT_NMW,
          a.PAYOFFICE_CDM,
          a.ACCTG_LOC_CDM,
          a.LA_MGR_ID_BEMS,
          a.LA_MGR_LAST_NAME,
          a.LA_MGR_FIRST_NAME,
          a.MGMT_JOBCODE,
          a.PS_SUPERVISOR_BEMS,
          a.JOBCODE,
          a.JOB_TITLE_NMW,
          a.LEAD_FLGM,
          a.LV_EFF_DTW,
          a.UNION_CD,
          a.UNION_SENIORITY_DT,
          a.DIRECT,
          a.BEMS_IDN,
          a.STANDARD_ID,
          a.MGR_IDN,
          a.LA_MGR_ID_BEMSN,
          a.PS_SUPERVISOR_BEMSN
     FROM pdbsr_owner.pdbsr_people_all_mv     a,
          pdbsr_owner.pdbsr_epdw_ns_people_mv b
    WHERE b.bems_idn = TO_NUMBER (a.bems_id);


DROP VIEW AMD_OWNER.AMD_PLANNER_LOGONS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PLANNER_LOGONS_V
(
   PLANNER_CODE,
   LOGON_ID,
   DATA_SOURCE,
   DEFAULT_IND,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT planner_code,
          logon_id,
          data_source,
          default_ind,
          last_update_dt
     FROM amd_planner_logons
    WHERE action_code <> 'D';


DROP VIEW AMD_OWNER.AMD_PREFERRED_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PREFERRED_V
(
   PART_NO,
   PART_LAST_UPDATE_DT,
   ADD_INCREMENT,
   AMC_BASE_STOCK,
   AMC_DAYS_EXPERICENCE,
   AMC_DEMAND,
   CAPABILITY_REQUIREMENT,
   CONDEMN_AVG,
   COST_TO_REPAIR_OFF_BASE,
   TIME_TO_REPAIR_OFF_BASE,
   TIME_TO_REPAIR_ON_BASE_AVG,
   CRITICALITY,
   CURRENT_BACKORDER,
   DLA_DEMAND,
   FEDC_COST,
   ITEM_TYPE,
   MIC_CODE_LOWEST,
   MTBDR,
   NOMENCLATURE,
   NRTS_AVG,
   ORDER_LEAD_TIME,
   ORDER_UOM,
   PLANNER_CODE,
   RTS_AVG,
   RU_IND,
   SMR_CODE,
   UNIT_COST,
   PRIME_PART_NO,
   STK_ITEM_LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT part_no,
          parts.last_update_dt part_last_update_dt,
          amd_preferred_pkg.getpreferredvalue (items.add_increment_cleaned,
                                               add_increment)
             add_increment,
          amd_preferred_pkg.getpreferredvalue (items.amc_base_stock_cleaned,
                                               amc_base_stock)
             amc_base_stock,
          amd_preferred_pkg.getpreferredvalue (
             items.amc_days_experience_cleaned,
             amc_days_experience)
             amc_days_experience,
          amd_preferred_pkg.getpreferredvalue (items.amc_demand_cleaned,
                                               amc_demand)
             amc_demand,
          amd_preferred_pkg.getpreferredvalue (
             items.capability_requirement_cleaned,
             capability_requirement)
             capability_requirement,
          amd_preferred_pkg.getpreferredvalue (items.condemn_avg_cleaned,
                                               condemn_avg)
             condemn_avg,
          amd_preferred_pkg.getpreferredvalue (
             items.cost_to_repair_off_base_cleand,
             cost_to_repair_off_base)
             cost_to_repair_off_base,
          amd_preferred_pkg.getpreferredvalue (
             items.time_to_repair_off_base_cleand,
             time_to_repair_off_base,
             amd_defaults.gettime_to_repair_offbase)
             time_to_repair_off_base,
          amd_preferred_pkg.getpreferredvalue (
             items.time_to_repair_on_base_avg_cl,
             time_to_repair_on_base_avg,
             time_to_repair_on_base_avg_df)
             time_to_repair_on_base_avg,
          amd_preferred_pkg.getpreferredvalue (items.criticality_cleaned,
                                               criticality)
             criticality,
          amd_preferred_pkg.getpreferredvalue (
             items.current_backorder_cleaned,
             current_backorder)
             current_backorder,
          amd_preferred_pkg.getpreferredvalue (items.dla_demand_cleaned,
                                               dla_demand)
             dla_demand,
          amd_preferred_pkg.getpreferredvalue (items.fedc_cost_cleaned,
                                               fedc_cost)
             fedc_cost,
          amd_preferred_pkg.getpreferredvalue (items.item_type_cleaned,
                                               item_type)
             item_type,
          amd_preferred_pkg.getpreferredvalue (items.mic_code_lowest_cleaned,
                                               mic_code_lowest)
             mic_code_lowest,
          amd_preferred_pkg.getpreferredvalue (items.mtbdr_cleaned,
                                               items.mtbdr_computed,
                                               items.mtbdr)
             mtbdr,
          amd_preferred_pkg.getpreferredvalue (items.nomenclature_cleaned,
                                               parts.nomenclature)
             nomenclature,
          amd_preferred_pkg.getpreferredvalue (items.nrts_avg_cleaned,
                                               items.nrts_avg,
                                               items.nrts_avg_defaulted)
             nrts_avg,
          amd_preferred_pkg.getpreferredvalue (
             items.order_lead_time_cleaned,
             parts.order_lead_time,
             parts.order_lead_time_defaulted)
             order_lead_time,
          amd_preferred_pkg.getpreferredvalue (items.order_uom_cleaned,
                                               parts.order_uom,
                                               parts.order_uom_defaulted)
             order_uom,
          amd_preferred_pkg.getpreferredvalue (
             items.planner_code_cleaned,
             items.planner_code,
             amd_defaults.getplannercode (parts.nsn))
             planner_code,
          amd_preferred_pkg.getpreferredvalue (items.rts_avg_cleaned,
                                               items.rts_avg)
             rts_avg,
          amd_preferred_pkg.getpreferredvalue (items.ru_ind_cleaned,
                                               items.ru_ind)
             ru_ind,
          amd_preferred_pkg.getpreferredvalue (items.smr_code_cleaned,
                                               items.smr_code)
             smr_code,
          amd_preferred_pkg.getpreferredvalue (items.unit_cost_cleaned,
                                               parts.unit_cost,
                                               parts.unit_cost_defaulted)
             unit_cost,
          prime_part_no,
          items.last_update_dt item_last_update_dt
     FROM amd_national_stock_items items, amd_spare_parts parts
    WHERE     parts.nsn = items.nsn
          AND parts.action_code <> 'D'
          AND items.action_code <> 'D';


DROP VIEW AMD_OWNER.AMD_PSLMS_HA;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PSLMS_HA
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   REFNUMHA,
   ITNAMEHA,
   INAMECHA,
   REFNCCHA,
   REFNVCHA,
   DLSCRCHA,
   DOCIDCHA,
   ITMMGCHA,
   COGNSNHA,
   SMMNSNHA,
   MATNSNHA,
   FSCNSNHA,
   NIINSNHA,
   ACTNSNHA,
   UICONVHA,
   SHLIFEHA,
   SLACTNHA,
   PPSLSTHA,
   DOCAVCHA,
   PRDLDTHA,
   SPMACCHA,
   SMAINCHA,
   CRITCDHA,
   PMICODHA,
   SAIPCDHA,
   AAPLCCHA,
   BBPLCCHA,
   CCPLCCHA,
   DDPLCCHA,
   EEPLCCHA,
   FFPLCCHA,
   GGPLCCHA,
   HHPLCCHA,
   JJPLCCHA,
   KKPLCCHA,
   LLPLCCHA,
   MMPLCCHA,
   PHYSECHA,
   ADPEQPHA,
   DEMILIHA,
   ACQMETHA,
   AMSUFCHA,
   HMSCOSHA,
   HWDCOSHA,
   HWSCOSHA,
   CTICODHA,
   UWEIGHHA,
   ULENGTHA,
   UWIDTHHA,
   UHEIGHHA,
   HAZCODHA,
   UNITMSHA,
   UNITISHA,
   LINNUMHA,
   CRITITHA,
   INDMATHA,
   MTLEADHA,
   MTLWGTHA,
   MATERLHA,
   SCHEDULE_B_EXPORT_CODE_TYPE,
   EXT_PART_ID
)
   BEQUEATH DEFINER
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "CAGECDXH",
          "REFNUMHA",
          "ITNAMEHA",
          "INAMECHA",
          "REFNCCHA",
          "REFNVCHA",
          "DLSCRCHA",
          "DOCIDCHA",
          "ITMMGCHA",
          "COGNSNHA",
          "SMMNSNHA",
          "MATNSNHA",
          "FSCNSNHA",
          "NIINSNHA",
          "ACTNSNHA",
          "UICONVHA",
          "SHLIFEHA",
          "SLACTNHA",
          "PPSLSTHA",
          "DOCAVCHA",
          "PRDLDTHA",
          "SPMACCHA",
          "SMAINCHA",
          "CRITCDHA",
          "PMICODHA",
          "SAIPCDHA",
          "AAPLCCHA",
          "BBPLCCHA",
          "CCPLCCHA",
          "DDPLCCHA",
          "EEPLCCHA",
          "FFPLCCHA",
          "GGPLCCHA",
          "HHPLCCHA",
          "JJPLCCHA",
          "KKPLCCHA",
          "LLPLCCHA",
          "MMPLCCHA",
          "PHYSECHA",
          "ADPEQPHA",
          "DEMILIHA",
          "ACQMETHA",
          "AMSUFCHA",
          "HMSCOSHA",
          "HWDCOSHA",
          "HWSCOSHA",
          "CTICODHA",
          "UWEIGHHA",
          "ULENGTHA",
          "UWIDTHHA",
          "UHEIGHHA",
          "HAZCODHA",
          "UNITMSHA",
          "UNITISHA",
          "LINNUMHA",
          "CRITITHA",
          "INDMATHA",
          "MTLEADHA",
          "MTLWGTHA",
          "MATERLHA",
          "SCHEDULE_B_EXPORT_CODE_TYPE",
          "EXT_PART_ID"
     FROM pslms_ha@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.AMD_PSLMS_HG;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PSLMS_HG
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   REFNUMHA,
   EIACODXA,
   LSACONXB,
   ALTLCNXB,
   LCNTYPXB,
   PLISNOHG,
   QTYASYHG,
   SUPINDHG,
   DATASCHG,
   PROSICHG,
   LLIPTDHG,
   PPLPTDHG,
   SFPPTDHG,
   CBLPTDHG,
   RILPTDHG,
   ISLPTDHG,
   PCLPTDHG,
   TTLPTDHG,
   SCPPTDHG,
   ARAPTDHG,
   ARBPTDHG,
   TOCCODHG,
   INDCODHG,
   QTYPEIHG,
   PIPLISHG,
   SAPLISHG,
   HARDCIHG,
   REMIPIHG,
   LRUNITHG,
   ITMCATHG,
   ESSCODHG,
   SMRCODHG,
   MRRONEHG,
   MRRTWOHG,
   MRRMODHG,
   ORTDOOHG,
   FRTDFFHG,
   HRTDHHHG,
   LRTDLLHG,
   DRTDDDHG,
   MINREUHG,
   MAOTIMHG,
   MAIACTHG,
   RISSBUHG,
   RMSSLIHG,
   RTLLQTHG,
   TOTQTYHG,
   OMTDOOHG,
   FMTDFFHG,
   HMTDHHHG,
   LMTDLLHG,
   DMTDDDHG,
   CBDMTDHG,
   CADMTDHG,
   ORCTOOHG,
   FRCTFFHG,
   HRCTHHHG,
   LRCTLLHG,
   DRCTDDHG,
   CONRCTHG,
   NORETSHG,
   REPSURHG,
   DRPONEHG,
   DRPTWOHG,
   WRKUCDHG,
   ALLOWCHG,
   ALIQTYHG,
   IDENTIFICATION_NUMBER_HG,
   PCCNUMXC,
   EXT_PARTAPPL_ID
)
   BEQUEATH DEFINER
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "CAGECDXH",
          "REFNUMHA",
          "EIACODXA",
          "LSACONXB",
          "ALTLCNXB",
          "LCNTYPXB",
          "PLISNOHG",
          "QTYASYHG",
          "SUPINDHG",
          "DATASCHG",
          "PROSICHG",
          "LLIPTDHG",
          "PPLPTDHG",
          "SFPPTDHG",
          "CBLPTDHG",
          "RILPTDHG",
          "ISLPTDHG",
          "PCLPTDHG",
          "TTLPTDHG",
          "SCPPTDHG",
          "ARAPTDHG",
          "ARBPTDHG",
          "TOCCODHG",
          "INDCODHG",
          "QTYPEIHG",
          "PIPLISHG",
          "SAPLISHG",
          "HARDCIHG",
          "REMIPIHG",
          "LRUNITHG",
          "ITMCATHG",
          "ESSCODHG",
          "SMRCODHG",
          "MRRONEHG",
          "MRRTWOHG",
          "MRRMODHG",
          "ORTDOOHG",
          "FRTDFFHG",
          "HRTDHHHG",
          "LRTDLLHG",
          "DRTDDDHG",
          "MINREUHG",
          "MAOTIMHG",
          "MAIACTHG",
          "RISSBUHG",
          "RMSSLIHG",
          "RTLLQTHG",
          "TOTQTYHG",
          "OMTDOOHG",
          "FMTDFFHG",
          "HMTDHHHG",
          "LMTDLLHG",
          "DMTDDDHG",
          "CBDMTDHG",
          "CADMTDHG",
          "ORCTOOHG",
          "FRCTFFHG",
          "HRCTHHHG",
          "LRCTLLHG",
          "DRCTDDHG",
          "CONRCTHG",
          "NORETSHG",
          "REPSURHG",
          "DRPONEHG",
          "DRPTWOHG",
          "WRKUCDHG",
          "ALLOWCHG",
          "ALIQTYHG",
          "IDENTIFICATION_NUMBER_HG",
          "PCCNUMXC",
          "EXT_PARTAPPL_ID"
     FROM pslms_hg@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.AMD_PSLMS_XA;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PSLMS_XA
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LCNSTRXA,
   ADDLTMXA,
   CTDLTMXA,
   CONTNOXA,
   CSREORXA,
   CSPRRQXA,
   DEMILCXA,
   DISCNTXA,
   ESSALVXA,
   HLCSPCXA,
   INTBINXA,
   INCATCXA,
   INTRATXA,
   INVSTGXA,
   LODFACXA,
   WSOPLVXA,
   OPRLIFXA,
   PRSTOVXA,
   PRSTOMXA,
   PROFACXA,
   RCBINCXA,
   RCCATCXA,
   RESTCRXA,
   SAFLVLXA,
   SECSFCXA,
   TRNCSTXA,
   WSTYAQXA,
   TSSCODXA,
   EXT_EIAC_ID
)
   BEQUEATH DEFINER
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "EIACODXA",
          "LCNSTRXA",
          "ADDLTMXA",
          "CTDLTMXA",
          "CONTNOXA",
          "CSREORXA",
          "CSPRRQXA",
          "DEMILCXA",
          "DISCNTXA",
          "ESSALVXA",
          "HLCSPCXA",
          "INTBINXA",
          "INCATCXA",
          "INTRATXA",
          "INVSTGXA",
          "LODFACXA",
          "WSOPLVXA",
          "OPRLIFXA",
          "PRSTOVXA",
          "PRSTOMXA",
          "PROFACXA",
          "RCBINCXA",
          "RCCATCXA",
          "RESTCRXA",
          "SAFLVLXA",
          "SECSFCXA",
          "TRNCSTXA",
          "WSTYAQXA",
          "TSSCODXA",
          "EXT_EIAC_ID"
     FROM pslms_xa@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.AMD_PSLMS_XB;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PSLMS_XB
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LSACONXB,
   ALTLCNXB,
   LCNTYPXB,
   LCNINDXB,
   LCNAMEXB,
   TMFGCDXB,
   SYSIDNXB,
   SECITMXB,
   RAMINDXB,
   DOCUMENT_CODE_XB,
   WORK_AREA_CODE_ZONE_XB,
   EXT_LCN_ID
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          EIACODXA,
          LSACONXB,
          ALTLCNXB,
          LCNTYPXB,
          LCNINDXB,
          LCNAMEXB,
          TMFGCDXB,
          SYSIDNXB,
          SECITMXB,
          RAMINDXB,
          DOCUMENT_CODE_XB,
          WORK_AREA_CODE_ZONE_XB,
          EXT_LCN_ID
     FROM pslms_xb@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.AMD_PSLMS_XC;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PSLMS_XC
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LSACONXB,
   ALTLCNXB,
   LCNTYPXB,
   UOCSEIXC,
   PCCNUMXC,
   ITMDESXC,
   PLISNOXC,
   TOCCODXC,
   QTYASYXC,
   QTYPEIXC,
   TRASEIXC,
   QTY_PER_EI_CALC_OPT_CODE
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          EIACODXA,
          LSACONXB,
          ALTLCNXB,
          LCNTYPXB,
          UOCSEIXC,
          PCCNUMXC,
          ITMDESXC,
          PLISNOXC,
          TOCCODXC,
          QTYASYXC,
          QTYPEIXC,
          TRASEIXC,
          QTY_PER_EI_CALC_OPT_CODE
     FROM pslms_xc@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.AMD_PSLMS_XI;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_PSLMS_XI
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   TMCODEXI,
   TMNUMBXI
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          TMCODEXI,
          TMNUMBXI
     FROM pslms_xi@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.AMD_RBL_PAIRS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_RBL_PAIRS_V
(
   OLD_NSN,
   NEW_NSN,
   GROUP_NO,
   SUBGROUP_CODE,
   PART_PREF_CODE,
   LAST_UPDATE_DT,
   ACTION_CODE
)
   BEQUEATH DEFINER
AS
   SELECT old_nsn,
          new_nsn,
          group_no,
          subgroup_code,
          part_pref_code,
          rbl.last_update_dt,
          rbl.action_code
     FROM amd_rbl_pairs            rbl,
          amd_national_stock_items items,
          pgold_isgp_v             grps
    WHERE     rbl.action_code <> 'D'
          AND items.action_code <> 'D'
          AND rbl.old_nsn = items.nsn
          AND ITEMS.PRIME_PART_NO = GRPS.PART;


DROP VIEW AMD_OWNER.AMD_REPAIRABLE_PARTS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_REPAIRABLE_PARTS_V
(
   PART_NO,
   ACTION_CODE,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT parts.part_no, parts.action_code, parts.last_update_dt
     FROM amd_spare_parts parts, amd_nsi_parts nsi
    WHERE parts.is_repairable = 'Y';


DROP VIEW AMD_OWNER.AMD_RSP_ON_HAND_N_OBJECTIVE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_RSP_ON_HAND_N_OBJECTIVE_V
(
   NSN,
   SRAN,
   RSP_ON_HAND,
   RSP_OBJECTIVE
)
   BEQUEATH DEFINER
AS
     SELECT nsn,
            NVL (NEW_VALUE, asn.loc_id) sran,
            SUM (rsp_inv)             rsp_on_hand,
            SUM (rsp_level)           rsp_objective
       FROM amd_rsp                r,
            amd_spare_networks     asn,
            amd_national_stock_items ansi,
            amd_substitutions      subs
      WHERE     r.action_code != 'D'
            AND R.PART_NO = ANSI.PRIME_PART_NO
            AND ANSI.ACTION_CODE != 'D'
            AND r.loc_sid = asn.loc_sid
            AND subs.substitution_name(+) = 'RSP_On_Hand_and_Objective'
            AND subs.substitution_type(+) = 'SRAN'
            AND subs.original_value(+) = loc_id
            AND subs.action_code(+) <> 'D'
   GROUP BY ansi.nsn, NVL (NEW_VALUE, asn.loc_id)
     HAVING SUM (rsp_inv) > 0;


DROP VIEW AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V
(
   PART_NO,
   RSP_LOCATION,
   QTY_ON_HAND,
   RSP_LEVEL,
   ROP_OR_ROQ,
   ACTION_CODE,
   LAST_UPDATE_DT,
   OVERRIDE_TYPE
)
   BEQUEATH DEFINER
AS
   SELECT part_no,
          rsp_location,
          qty_on_hand,
          rsp_level,
          rsp_level - 1 rop_or_roq,
          action_code,
          last_update_dt,
          override_type
     FROM amd_rsp_sum
   UNION
   SELECT part_no,
          rsp_location,
          qty_on_hand,
          rsp_level,
          amd_defaults.getroq rop_or_roq,
          action_code,
          last_update_dt,
          override_type
     FROM amd_rsp_sum
   ORDER BY 1, 2;


DROP VIEW AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V
(
   PART_NO,
   RSP_LOCATION,
   QTY_ON_HAND,
   RSP_LEVEL,
   ACTION_CODE,
   LAST_UPDATE_DT,
   OVERRIDE_TYPE
)
   BEQUEATH DEFINER
AS
     SELECT part_no,
            rsp_location,
            qty_on_hand,
            rsp_level,
            action_code,
            last_update_dt,
            override_type
       FROM amd_rsp_sum
      WHERE override_type = (SELECT tsl_fixed_override FROM amd_spo_types_v)
   ORDER BY 1, 2;


DROP VIEW AMD_OWNER.AMD_SPO_PARTS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_SPO_PARTS_V
(
   PART_NO,
   PRIME_PART_NO,
   PART_TYPE,
   ASSIGNMENT_DATE,
   SPO_PRIME_PART_NO
)
   BEQUEATH DEFINER
AS
   SELECT parts.part_no,
          items.prime_part_no,
          CASE
             WHEN parts.is_consumable = 'Y' THEN 'Consumable'
             WHEN parts.is_repairable = 'Y' THEN 'Repairable'
          END
             part_type,
          nsi.assignment_date,
          parts.spo_prime_part_no
     FROM amd_spare_parts          parts,
          amd_national_stock_items items,
          amd_nsi_parts            nsi
    WHERE     parts.is_spo_part = 'Y'
          AND parts.part_no = parts.spo_prime_part_no
          AND items.action_code <> 'D'
          AND parts.nsn = items.nsn
          AND parts.part_no = nsi.part_no
          AND nsi.unassignment_date IS NULL;


DROP VIEW AMD_OWNER.AMD_SPO_TYPES_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_SPO_TYPES_V
(
   GENERAL_BACKORDER,
   EXTERNAL_DEMAND_FORECAST,
   GENERAL_DEMAND,
   GENERAL_IN_TRANSIT,
   DEFECTIVE_IN_TRANSIT,
   GENERAL_ON_HAND,
   DEFECTIVE_ON_HAND,
   TSL_FIXED_OVERRIDE,
   ROP_FIXED_OVERRIDE,
   ROQ_FIXED_OVERRIDE,
   FIXED_TSL_LOAD_OVERRIDE_REASON,
   FLIGHT_HOURS_CAUSAL,
   ENGINEERING_FLIGHT_HOURS_MTBF,
   NEW_BUY_REQUEST,
   REPAIR_REQUEST,
   NEW_BUY_LEAD_TIME,
   REPAIR_LEAD_TIME,
   TWO_WAY_SUPERSESSION
)
   BEQUEATH DEFINER
AS
   SELECT (SELECT name
             FROM spo_backorder_type_v
            WHERE id = 1001)
             general_backorder,
          (SELECT name
             FROM spo_demand_forecast_type_v
            WHERE id = 1003)
             external_demand_forecast,
          (SELECT name
             FROM spo_demand_type_v
            WHERE id = 1001)
             general_demand,
          (SELECT name
             FROM spo_in_transit_type_v
            WHERE id = 1001)
             general_in_transit,
          (SELECT name
             FROM spo_in_transit_type_v
            WHERE id = 1004)
             defective_in_transit,
          (SELECT name
             FROM spo_on_hand_type_v
            WHERE id = 1001)
             general_on_hand,
          (SELECT name
             FROM spo_on_hand_type_v
            WHERE id = 1004)
             defective_on_hand,
          (SELECT name
             FROM spo_override_type_v
            WHERE id = 1004)
             tsl_fixed_override,
          (SELECT name
             FROM spo_override_type_v
            WHERE id = 1008)
             rop_fixed_override,
          (SELECT name
             FROM spo_override_type_v
            WHERE id = 1010)
             roq_fixed_override,
          (SELECT name
             FROM spo_override_reason_type_v
            WHERE id = 10001)
             fixed_load_override_reason,
          (SELECT name
             FROM spo_causal_type_v
            WHERE id = 1002)
             flight_hours_causal,
          (SELECT name
             FROM spo_mtbf_type_v
            WHERE id = 1004)
             engineering_flight_hours_mtbf,
          (SELECT name
             FROM spo_request_type_v
            WHERE id = 1001)
             new_buy_request,
          (SELECT name
             FROM spo_request_type_v
            WHERE id = 1002)
             repair_request,
          (SELECT name
             FROM spo_request_type_v
            WHERE id = 1001)
             new_buy_lead_time,
          (SELECT name
             FROM spo_request_type_v
            WHERE id = 1002)
             repair_lead_time,
          (SELECT name
             FROM spo_supersession_type_v
            WHERE id = 1002)
             two_way_supersession
     FROM DUAL;


DROP VIEW AMD_OWNER.AMD_TWOWAY_RBL_PAIRS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_TWOWAY_RBL_PAIRS_V
(
   OLD_NSN,
   OLD_PRIME_PART_NO,
   OLD_ACTION_CODE,
   OLD_LAST_UPDATE_DT,
   NEW_NSN,
   NEW_PRIME_PART_NO,
   NEW_ACTION_CODE,
   NEW_LAST_UPDATE_DT,
   SUPERSESSION_TYPE,
   SUBGROUP_CODE,
   PART_PREF_CODE
)
   BEQUEATH DEFINER
AS
     SELECT old_nsn,
            olditems.prime_part_no old_prime_part_no,
            olditems.action_code  old_action_code,
            olditems.last_update_dt old_last_update_dt,
            new_nsn,
            newitems.prime_part_no new_prime_part_no,
            newitems.action_code  new_action_code,
            newitems.last_update_dt old_last_update_dt,
            'TWO-WAY'             supersession_type,
            subgroup_code,
            part_pref_code
       FROM amd_rbl_pairs          a,
            amd_national_stock_items olditems,
            amd_national_stock_items newitems
      WHERE     a.action_code <> 'D'
            AND a.old_nsn <> a.new_nsn
            AND subgroup_code = (SELECT subgroup_code
                                   FROM amd_rbl_pairs
                                  WHERE old_nsn = a.new_nsn)
            AND old_nsn = olditems.nsn
            AND olditems.action_code <> 'D'
            AND new_nsn = newitems.nsn
            AND newitems.action_code <> 'D'
   ORDER BY new_nsn, subgroup_code, part_pref_code;


DROP VIEW AMD_OWNER.AMD_USERS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_USERS_V
(
   BEMS_ID,
   LAST_UPDATE_DT,
   STABLE_EMAIL,
   FIRST_NAME,
   LAST_NAME
)
   BEQUEATH DEFINER
AS
   SELECT bems_id,
          last_update_dt,
          REPLACE (stable_email, ' ', '') stable_email,
          TRIM (first_name)               first_name,
          TRIM (last_name)                last_name
     FROM amd_users
    WHERE action_code <> 'D'
   UNION
   SELECT mgr.bems_id,
          last_update_dt,
          REPLACE (people.stable_email, ' ', '') stable_email,
          TRIM (people.first_name)               first_name,
          TRIM (people.last_name)                last_name
     FROM amd_site_asset_mgr mgr, amd_people_all_v people
    WHERE     mgr.action_code <> 'D'
          AND mgr.bems_id = people.bems_id
          AND NOT EXISTS
                 (SELECT NULL
                    FROM amd_users users
                   WHERE     mgr.bems_id = users.bems_id
                         AND users.action_code <> 'D');


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V
(
   EXCEL_ROW,
   SOURCE_CODE,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   LAST_UPDATE_DT,
   FILENAME,
   BAD_NSN,
   ACTION_CODE
)
   BEQUEATH DEFINER
AS
   SELECT excel_row,
          source_code,
          transaction_date,
          TO_CHAR (TRANSACTION_dATE, 'RRDDD') tran_date_yyddd,
          NSN,
          DOC_NO,
          DEMAND_QUANTITY,
          last_update_dt,
          filename,
          bad_nsn,
          action_code
     FROM amd_warner_robins_files
    WHERE nsn NOT IN (SELECT n.nsn
                        FROM amd_nsns n, amd_national_stock_items i
                       WHERE n.nsi_sid = i.nsi_sid AND i.action_code <> 'D');


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DELNSN_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DELNSN_V
(
   EXCEL_ROW,
   SOURCE_CODE,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   LAST_UPDATE_DT,
   FILENAME,
   BAD_NSN,
   ACTION_CODE
)
   BEQUEATH DEFINER
AS
   SELECT excel_row,
          source_code,
          transaction_date,
          TO_CHAR (TRANSACTION_dATE, 'RRDDD') tran_date_yyddd,
          NSN,
          DOC_NO,
          DEMAND_QUANTITY,
          last_update_dt,
          filename,
          bad_nsn,
          action_code
     FROM amd_warner_robins_files
    WHERE action_code = 'D';


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V
(
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   TRANSACTION_DATE,
   FILENAME,
   EXCEL_ROW,
   NUMBER_OF_DUPLICATES
)
   BEQUEATH DEFINER
AS
     SELECT f.nsn,
            f.doc_no,
            f.demand_quantity,
            f.transaction_date,
            f.filename,
            f.excel_row,
            duplicates.number_of_duplicates
       FROM amd_warner_robins_files f,
            (  SELECT NSN,
                      DOC_NO,
                      SUM (DEMAND_QUANTITY_SUMMED) demand_quantity_summed,
                      SUM (NUMBER_OF_DUPLICATES) number_of_duplicates
                 FROM amd_warner_robins_dups_v
             GROUP BY nsn, doc_no
               HAVING COUNT (*) > 1) duplicates
      WHERE f.nsn = duplicates.nsn AND f.doc_no = duplicates.doc_no
   ORDER BY f.nsn,
            f.doc_no,
            f.filename,
            f.excel_row;


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V
(
   FILENAME,
   EXCEL_ROW,
   NUMBER_OF_DUPLICATES,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   SOURCE_CODE,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
     SELECT w.filename,
            excel_row,
            d.number_of_duplicates,
            w.NSN,
            w.DOC_NO,
            DEMAND_QUANTITY,
            source_code,
            transaction_date,
            TO_CHAR (transaction_date, 'RRDDD') tran_date_yyddd,
            last_update_dt
       FROM amd_warner_robins_files w, amd_warner_robins_dups_v d
      WHERE w.nsn = d.nsn AND w.doc_no = d.doc_no AND w.filename = d.filename
   ORDER BY w.nsn,
            w.doc_no,
            w.filename,
            excel_row;


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V
(
   NSN,
   DOC_NO,
   DEMAND_QUANTITY_SUMMED,
   NUMBER_OF_DUPLICATES,
   FILENAME
)
   BEQUEATH DEFINER
AS
     SELECT NSN,
            DOC_NO,
            SUM (demand_quantity),
            COUNT (*) number_of_duplicates,
            FILENAME
       FROM amd_warner_robins_files
      WHERE nsn IN (SELECT n.nsn
                      FROM amd_nsns n, amd_national_stock_items i
                     WHERE n.nsi_sid = i.nsi_sid AND i.action_code <> 'D')
   GROUP BY nsn, doc_no, filename
     HAVING COUNT (*) > 1
   ORDER BY nsn, doc_no;


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_FILES_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_FILES_V
(
   EXCEL_ROW,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   FILENAME,
   LAST_UPDATE_DT,
   DATE_LOADED_TO_DEMANDS
)
   BEQUEATH DEFINER
AS
     SELECT excel_row,
            transaction_date,
            TO_CHAR (transaction_date, 'RRDDD') tran_date_yyddd,
            nsn,
            doc_no,
            demand_quantity,
            filename,
            last_update_dt,
            date_loaded_to_demands
       FROM amd_warner_robins_files
   ORDER BY filename, excel_row;


DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V
(
   DOC_NO,
   LOC_ID,
   LOC_SID,
   NSN,
   NSI_SID,
   QUANTITY,
   CREATED_DATETIME,
   PRIME_PART_NO
)
   BEQUEATH DEFINER
AS
   SELECT doc_no,
          'EY1746'                       loc_id,
          amd_utils.getLocSid ('EY1746') loc_sid,
          stkItems.nsn,
          nsi_sid,
          quantity,
          created_datetime,
          prime_part_no
     FROM amd_national_stock_items stkItems,
          (  SELECT items.nsn            nsn,
                    doc_no,
                    SUM (demand_quantity) quantity,
                    MIN (transaction_date) created_datetime
               FROM amd_warner_robins_files wr,
                    amd_nsns               nsns,
                    amd_national_stock_items items
              WHERE     bad_nsn IS NULL
                    AND wr.action_code IS NULL
                    AND wr.nsn = nsns.nsn
                    AND nsns.nsi_sid = items.nsi_sid
           GROUP BY items.nsn, doc_no) wr
    WHERE wr.nsn = stkItems.nsn AND stkItems.action_code <> 'D';


DROP VIEW AMD_OWNER.BSSM_2F_RAMP_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.BSSM_2F_RAMP_V
(
   NSN,
   SRAN,
   PERCENT_BASE_REPAIR,
   PERCENT_BASE_CONDEMN,
   DAILY_DEMAND_RATE,
   AVG_REPAIR_CYCLE_TIME
)
   BEQUEATH DEFINER
AS
   SELECT REPLACE (current_stock_number, '-', '') nsn,
          SUBSTR (sc, 8, 6)                       sran,
          percent_base_repair,
          percent_base_condem,
          daily_demand_rate,
          avg_repair_cycle_time
     FROM ramp
    WHERE Delete_Indicator IS NULL;


DROP VIEW AMD_OWNER.COMPONENT_LRU_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.COMPONENT_LRU_V
(
   PART_NO,
   MASTER_LCN,
   LCN,
   PCCN,
   PLISN,
   QPA,
   INDENTURE,
   SLIC_SMR,
   SLIC_WUC,
   TOCC,
   SLIC_CAGE,
   SLIC_NOUN,
   GOLD_NOUN,
   USABLE_FROM,
   USABLE_TO,
   IMS,
   AAC,
   SOS,
   NSN,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
     SELECT part_no,
            master_lcn,
            lcn,
            pccn,
            plisn,
            qpa,
            indenture,
            slic_smr,
            slic_wuc,
            tocc,
            slic_cage,
            slic_noun,
            gold_noun,
            usable_from,
            usable_to,
            ims,
            aac,
            sos,
            nsn,
            last_update_dt
       FROM (SELECT brkdwn.*, cat1.smrc cat1_smr
               FROM amd_owner.lru_breakdown brkdwn, amd_owner.pgold_cat1_v cat1
              WHERE master_lcn <> lcn AND part_no = cat1.part(+))
      WHERE    (    slic_smr IS NOT NULL
                AND SUBSTR (slic_smr, 1, 3) = 'PAO'
                AND SUBSTR (slic_smr, 6, 1) = 'T')
            OR (    slic_smr IS NULL
                AND SUBSTR (cat1_smr, 1, 3) = 'PAO'
                AND SUBSTR (cat1_smr, 6, 1) = 'T')
   ORDER BY master_lcn, lcn, part_no;


DROP VIEW AMD_OWNER.COMPONENT_PART_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.COMPONENT_PART_V
(
   PART_NO,
   MASTER_LCN,
   LCN,
   PCCN,
   PLISN,
   QPA,
   INDENTURE,
   SLIC_SMR,
   SLIC_WUC,
   TOCC,
   SLIC_CAGE,
   SLIC_NOUN,
   GOLD_NOUN,
   USABLE_FROM,
   USABLE_TO,
   IMS,
   AAC,
   SOS,
   NSN,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
   SELECT "PART_NO",
          "MASTER_LCN",
          "LCN",
          "PCCN",
          "PLISN",
          "QPA",
          "INDENTURE",
          "SLIC_SMR",
          "SLIC_WUC",
          "TOCC",
          "SLIC_CAGE",
          "SLIC_NOUN",
          gold_noun,
          "USABLE_FROM",
          "USABLE_TO",
          ims,
          aac,
          sos,
          nsn,
          "LAST_UPDATE_DT"
     FROM lru_breakdown
    WHERE master_lcn <> lcn
   MINUS
   (SELECT "PART_NO",
           "MASTER_LCN",
           "LCN",
           "PCCN",
           "PLISN",
           "QPA",
           "INDENTURE",
           "SLIC_SMR",
           "SLIC_WUC",
           "TOCC",
           "SLIC_CAGE",
           "SLIC_NOUN",
           gold_noun,
           "USABLE_FROM",
           "USABLE_TO",
           ims,
           aac,
           sos,
           nsn,
           "LAST_UPDATE_DT"
      FROM sru_pn_v
    UNION
    SELECT "PART_NO",
           "MASTER_LCN",
           "LCN",
           "PCCN",
           "PLISN",
           "QPA",
           "INDENTURE",
           "SLIC_SMR",
           "SLIC_WUC",
           "TOCC",
           "SLIC_CAGE",
           "SLIC_NOUN",
           gold_noun,
           "USABLE_FROM",
           "USABLE_TO",
           ims,
           aac,
           sos,
           nsn,
           "LAST_UPDATE_DT"
      FROM component_lru_v)
   ORDER BY master_lcn, lcn, part_no;


DROP VIEW AMD_OWNER.DATASYS_LP_OVERRIDE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.DATASYS_LP_OVERRIDE_V
(
   PART,
   CAGE,
   SITE_LOCATION,
   TYPE,
   QUANTITY,
   BEGIN_DATE,
   END_DATE,
   OVERRIDE_USER,
   OVERRIDE_REASON
)
   BEQUEATH DEFINER
AS
   SELECT /*+ driving_site (p) */
         p.part,
          p.cage,
          l.site_location,
          t.VALUE,
          lpo.quantity,
          lpo.begin_date,
          lpo.end_date,
          su.spo_user,
          r.VALUE
     FROM escmc17v2.lp_override@stl_escm_link lpo,
          escmc17v2.part@stl_escm_link        p,
          escmc17v2.LOCATION@stl_escm_link    l,
          escmc17v2.TYPE@stl_escm_link        t,
          escmc17v2.spo_user@stl_escm_link    su,
          escmc17v2.TYPE@stl_escm_link        r
    WHERE     lpo.part_id = p.part_id
          AND lpo.override_type_id = t.type_id
          AND lpo.location_id = l.location_id
          AND lpo.override_user_id = su.spo_user_id
          AND lpo.override_reason_id = r.type_id;


DROP VIEW AMD_OWNER.DATASYS_PART_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.DATASYS_PART_V
(
   PART_ID,
   EQUIPMENT_TYPE_ID,
   INDENTURE_ID,
   PART,
   CAGE,
   UNIT_ISSUE,
   END_DATE,
   BEGIN_DATE,
   PLANNED,
   NOUN,
   HAZMAT,
   SHELF_LIFE,
   SHELF_LIFE_ACTION_CODE,
   NSN_COG,
   NSN_FSC,
   NSN_NIIN,
   NSN_SMIC_MMAC,
   NSN_ACTY,
   NSN_MCC,
   ESSENTIALITY,
   UNIT_PACK_CUBE,
   UNIT_PACK_QTY,
   UNIT_PACK_WEIGHT,
   UNIT_PACK_MEASURE,
   ESD,
   PBL,
   MTBF,
   THIRD_PARTY,
   ROQ_BASED,
   SMRCODE,
   DECAY_RATE,
   SOURCE_SYSTEM,
   MATERIAL_CLASS,
   EXEMPT,
   IGNORE_WEIGHT_VOLUME,
   PRICE,
   REPAIR_COST,
   HOLDING_COST_RATE,
   MTBF_TYPE_ID,
   RCM_TYPE_ID,
   FIXED_ORDER_COST,
   PLANNER_CODE_ID,
   GENERATE_NEW_BUY,
   GENERATE_REPAIR,
   GENERATE_ALLOCATION,
   GENERATE_TRANSSHIPMENT,
   TIMESTAMP,
   ATTRIBUTE_28,
   ATTRIBUTE_29,
   ATTRIBUTE_30,
   ATTRIBUTE_31,
   ATTRIBUTE_32,
   IS_SEASONAL,
   MAX_TOTAL_TSL,
   ATTRIBUTE_18,
   ATTRIBUTE_19
)
   BEQUEATH DEFINER
AS
   SELECT "PART_ID",
          "EQUIPMENT_TYPE_ID",
          "INDENTURE_ID",
          "PART",
          "CAGE",
          "UNIT_ISSUE",
          "END_DATE",
          "BEGIN_DATE",
          "PLANNED",
          "NOUN",
          "HAZMAT",
          "SHELF_LIFE",
          "SHELF_LIFE_ACTION_CODE",
          "NSN_COG",
          "NSN_FSC",
          "NSN_NIIN",
          "NSN_SMIC_MMAC",
          "NSN_ACTY",
          "NSN_MCC",
          "ESSENTIALITY",
          "UNIT_PACK_CUBE",
          "UNIT_PACK_QTY",
          "UNIT_PACK_WEIGHT",
          "UNIT_PACK_MEASURE",
          "ESD",
          "PBL",
          "MTBF",
          "THIRD_PARTY",
          "ROQ_BASED",
          "SMRCODE",
          "DECAY_RATE",
          "SOURCE_SYSTEM",
          "MATERIAL_CLASS",
          "EXEMPT",
          "IGNORE_WEIGHT_VOLUME",
          "PRICE",
          "REPAIR_COST",
          "HOLDING_COST_RATE",
          "MTBF_TYPE_ID",
          "RCM_TYPE_ID",
          "FIXED_ORDER_COST",
          "PLANNER_CODE_ID",
          "GENERATE_NEW_BUY",
          "GENERATE_REPAIR",
          "GENERATE_ALLOCATION",
          "GENERATE_TRANSSHIPMENT",
          "TIMESTAMP",
          "ATTRIBUTE_28",
          "ATTRIBUTE_29",
          "ATTRIBUTE_30",
          "ATTRIBUTE_31",
          "ATTRIBUTE_32",
          "IS_SEASONAL",
          "MAX_TOTAL_TSL",
          "ATTRIBUTE_18",
          "ATTRIBUTE_19"
     FROM escmc17v2.part@stl_escm_link;


DROP VIEW AMD_OWNER.DATASYS_PLANNER_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.DATASYS_PLANNER_V
(
   PLANNER_ID,
   PLANNER_CODE_ID,
   PLANNER_TIMESTAMP,
   PLANNER_CODE,
   SPO_USER,
   NAME,
   USER_TIMESTAMP
)
   BEQUEATH DEFINER
AS
   SELECT p.planner_id      "planner_id",
          p.planner_code_id "planner_code_id",
          p.timestamp       "planner_timestamp",
          c.planner_code    "planner_code",
          u.spo_user        "spo_user",
          u.name            "name",
          u.timestamp       "user_timestamp"
     FROM escmc17v2.planner@stl_escm_link      p,
          escmc17v2.planner_code@stl_escm_link c,
          escmc17v2.spo_user@stl_escm_link     u
    WHERE     p.planner_code_id = c.planner_code_id
          AND p.spo_user_id = u.spo_user_id;


DROP VIEW AMD_OWNER.DATASYS_TRANS_PROCESSED_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.DATASYS_TRANS_PROCESSED_V
(
   DAY,
   BACKORDER_INFO,
   BOM_DETAIL,
   ORG_DEPLOYMENT,
   DEMAND_INFO,
   EXT_FORECAST,
   INV_INFO,
   IN_TRANSIT,
   LOCATION_CAUSAL,
   PART_FACTORS,
   LOCATION_PART_LEAD_TIME,
   LOCATION_PART_OVERRIDE,
   LOCATION_PART_REPLACEMENT_RATE,
   NETWORK_PART,
   ORDER_INFO_LINE,
   ORG_FLIGHT_ACTY,
   ORG_FLIGHT_ACTY_FORECAST,
   PART_INFO,
   PART_ALT_REL_DEL,
   PART_CAUSAL_TYPE,
   PART_LEAD_TIME,
   PART_SUPERSEDURE,
   PART_UPGRADED_PART,
   REPAIR_INFO,
   SITE_RESP_ASSET_MGR,
   SPO_USER,
   TAILNO_INFO,
   UNKNOWN,
   TRANSIT_TIME,
   TRANSIT_COST,
   TIMESTAMP,
   PART_ALT
)
   BEQUEATH DEFINER
AS
   SELECT "DAY",
          "BACKORDER_INFO",
          "BOM_DETAIL",
          "ORG_DEPLOYMENT",
          "DEMAND_INFO",
          "EXT_FORECAST",
          "INV_INFO",
          "IN_TRANSIT",
          "LOCATION_CAUSAL",
          "PART_FACTORS",
          "LOCATION_PART_LEAD_TIME",
          "LOCATION_PART_OVERRIDE",
          "LOCATION_PART_REPLACEMENT_RATE",
          "NETWORK_PART",
          "ORDER_INFO_LINE",
          "ORG_FLIGHT_ACTY",
          "ORG_FLIGHT_ACTY_FORECAST",
          "PART_INFO",
          "PART_ALT_REL_DEL",
          "PART_CAUSAL_TYPE",
          "PART_LEAD_TIME",
          "PART_SUPERSEDURE",
          "PART_UPGRADED_PART",
          "REPAIR_INFO",
          "SITE_RESP_ASSET_MGR",
          "SPO_USER",
          "TAILNO_INFO",
          "UNKNOWN",
          "TRANSIT_TIME",
          "TRANSIT_COST",
          "TIMESTAMP",
          "PART_ALT"
     FROM escmc17v2.transactions_processed@stl_escm_link;


DROP VIEW AMD_OWNER.FEDLOG_ACTIVE_NIINS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.FEDLOG_ACTIVE_NIINS_V
(
   NIN
)
   BEQUEATH DEFINER
AS
   SELECT SUBSTR (an.nsn, 5, 9) nin
     FROM amd_nsi_parts anp, amd_spare_parts asp, amd_nsns an
    WHERE     anp.prime_ind = 'Y'
          AND anp.unassignment_date IS NULL
          AND asp.action_code IN ('A', 'C')
          AND an.nsn_type = 'C'
          AND anp.part_no = asp.part_no
          AND anp.nsi_sid = an.nsi_sid
          AND an.nsn = asp.nsn
          AND an.nsn NOT LIKE 'NSL%'
          AND SUBSTR (an.nsn, 5, 1) IN ('0',
                                        '1',
                                        '2',
                                        '3',
                                        '4',
                                        '5',
                                        '6',
                                        '7',
                                        '8',
                                        '9');


DROP VIEW AMD_OWNER.GOLDSA_ITEM_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.GOLDSA_ITEM_V
(
   ITEM_ID,
   RECEIVED_ITEM_ID,
   U_ID,
   SC,
   PART,
   PRIME,
   CONDITION,
   SERIAL,
   LOCATION,
   LOT,
   VENDOR_CODE,
   KEY_REF,
   OUT_DATETIME,
   OUT_VOUCHER,
   OUT_USERID,
   OUT_DOCDATE,
   BOM_ID,
   ASSET_ID,
   ASSET_ID_ALT,
   CATEGORY,
   CUSTODIAN,
   CUSTODIAN_ALT1,
   CUSTODIAN_ALT2,
   QTY,
   STATUS_DEL_WHEN_GONE,
   STATUS_SERVICABLE,
   STATUS_NEW_ORDER,
   STATUS_ACCOUNTABLE,
   STATUS_AVAIL,
   STATUS_FROZEN,
   STATUS_ACTIVE,
   STATUS_MAI,
   STATUS_WAITING_DISPO,
   STATUS_IN_TRANSIT,
   STATUS_RECEIVING_SUSP,
   STATUS_INSTALLED_IWRN,
   TEMP_OUT_ID,
   LAST_TEMPOUT_DATETIME,
   REMARKS,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   USER_REF7,
   USER_REF8,
   CURRENT_PRICE,
   TOTAL_EXPENSES,
   TOTAL_VALUE,
   TOTAL_LABOR,
   RECEIPT_DATETIME,
   RECEIPT_DOC_DATE,
   RECEIPT_PRICE,
   RECEIPT_UM,
   RECEIPT_VOUCHER,
   RECEIPT_ORDER_TYPE,
   RECEIPT_ORDER_NO,
   PI_ACTIVE_YN,
   PI_ACTIVE_DATETIME,
   PI_ACTIVE_GROUP,
   PI_ACTIVE_PILINE,
   PI_COMP_START_DATETIME,
   PI_COMP_END_DATETIME,
   PI_COMP_GROUP,
   PI_COMP_PILINE,
   PI_COMP_VOUCHER,
   NEXT_ACTIVITY_CODE,
   NEXT_ACTIVITY_DATE,
   ORDER_NO,
   LAST_1662_TYPE,
   ARCHIVE_DATETIME,
   DISPO_GOLD_SCHED,
   DISPO_GOLD_SCHED_LINE,
   DUE_TO_SC,
   SUB_LOCATION,
   RESERVE_ACTION,
   CREATED_DATETIME,
   CREATED_USERID,
   LAST_CHANGED_USERID,
   LAST_CHANGED_DATETIME,
   CREATED_ASSET_USERID,
   CREATED_ASSET_DATETIME,
   AWO,
   AWO_ALT,
   PO,
   PO_LINE,
   WCHD_ID,
   STATUS_1,
   STATUS_2,
   STATUS_3,
   MISSION_CAPABILITY,
   TEMP_OUT_TCN,
   FURNISHED_BY,
   OWNER_CODE,
   OWNER_MARKING,
   SHOP_BENCH_CODE,
   RECALL_CODE,
   ASSET_USED_IN_PROD_B,
   USAGE_PROFILE_CODE,
   ITEM_WAITING_DISPO,
   STANDARD_LEVEL,
   VENDOR_PART,
   LAST_ACTIVITY_CODE,
   LAST_ACTIVITY_DATE,
   USER_REF9,
   USER_REF10,
   INTERVAL_CHG_METHOD,
   INTERVAL_CHG_USERID,
   INTERVAL_CHG_DATETIME,
   NEXT_DATE_CHG_USERID,
   NEXT_DATE_CHG_DATETIME,
   NEXT_DATE_CHG_METHOD,
   ORIGINAL_INTERVAL,
   WARRANTY_CODE,
   WARRANTY_DATE,
   OWNING_ORDER_NO,
   UNIT_ASSN,
   DATE_OF_MANUF,
   STATUS_STRUCTURE,
   INTO_TOP_BOM_ID,
   INTO_STRUCTURE_CODE,
   INTO_SUB_STRUCTURE_CODE,
   INTO_POS,
   INTO_ALT_POS,
   FROM_TOP_BOM_ID,
   FROM_STRUCTURE_CODE,
   FROM_SUB_STRUCTURE_CODE,
   FROM_POS,
   FROM_ALT_POS,
   TAGGED_PROPERTY_B,
   REVISION_LEVEL,
   EQUIP_ID,
   STATUS_IN_USE_B,
   MAND_METER_EXPIRED_B,
   PO_SEQ,
   SECURITY_CODE,
   ACQUISITION_AUTHORITY,
   ACQUISITION_DOCUMENT,
   ACQUISITION_DOC_DT,
   TRANSACTION_DOCUMENT,
   TRANSACTION_DOC_DT,
   CONTRACT_AUTHORITY,
   DEPARTMENT,
   LOAN_NUMBER,
   NET_BOOK_VALUE,
   DISPO_GOLD_SCHED_1149,
   SCHED_START_DATE,
   MCC,
   STATUS_SUSPENDED,
   CHECK_TYPE,
   SCHD_DLV_DATE,
   IWA,
   DELIVERY_ORDER,
   STAND_ALONE_B,
   COST_SOURCE_CODE,
   COST_ORDER_NO,
   AC_REMOVED_FROM,
   AUTH_TYPE,
   PAPO,
   CFO_ACQUISITION_COST,
   CFO_ACQUISITION_DATE,
   CFO_REPORT_SYSTEM,
   TRANSFER_TRAN_ID,
   ACCOUNT_CODE,
   CAL_REQUIRED_B,
   PM_REQUIRED_B,
   BUGL,
   SOURCE_ROUTING_ID,
   RCDN,
   CONTRACTOR_REFERENCE_NUMBER
)
   BEQUEATH DEFINER
AS
   SELECT ITEM_ID,
          RECEIVED_ITEM_ID,
          U_ID,
          SC,
          PART,
          PRIME,
          CONDITION,
          SERIAL,
          LOCATION,
          LOT,
          VENDOR_CODE,
          KEY_REF,
          OUT_DATETIME,
          OUT_VOUCHER,
          OUT_USERID,
          OUT_DOCDATE,
          BOM_ID,
          ASSET_ID,
          ASSET_ID_ALT,
          CATEGORY,
          CUSTODIAN,
          CUSTODIAN_ALT1,
          CUSTODIAN_ALT2,
          QTY,
          STATUS_DEL_WHEN_GONE,
          STATUS_SERVICABLE,
          STATUS_NEW_ORDER,
          STATUS_ACCOUNTABLE,
          STATUS_AVAIL,
          STATUS_FROZEN,
          STATUS_ACTIVE,
          STATUS_MAI,
          STATUS_WAITING_DISPO,
          STATUS_IN_TRANSIT,
          STATUS_RECEIVING_SUSP,
          STATUS_INSTALLED_IWRN,
          TEMP_OUT_ID,
          LAST_TEMPOUT_DATETIME,
          REMARKS,
          USER_REF1,
          USER_REF2,
          USER_REF3,
          USER_REF4,
          USER_REF5,
          USER_REF6,
          USER_REF7,
          USER_REF8,
          CURRENT_PRICE,
          TOTAL_EXPENSES,
          TOTAL_VALUE,
          TOTAL_LABOR,
          RECEIPT_DATETIME,
          RECEIPT_DOC_DATE,
          RECEIPT_PRICE,
          RECEIPT_UM,
          RECEIPT_VOUCHER,
          RECEIPT_ORDER_TYPE,
          RECEIPT_ORDER_NO,
          PI_ACTIVE_YN,
          PI_ACTIVE_DATETIME,
          PI_ACTIVE_GROUP,
          PI_ACTIVE_PILINE,
          PI_COMP_START_DATETIME,
          PI_COMP_END_DATETIME,
          PI_COMP_GROUP,
          PI_COMP_PILINE,
          PI_COMP_VOUCHER,
          NEXT_ACTIVITY_CODE,
          NEXT_ACTIVITY_DATE,
          ORDER_NO,
          LAST_1662_TYPE,
          ARCHIVE_DATETIME,
          DISPO_GOLD_SCHED,
          DISPO_GOLD_SCHED_LINE,
          DUE_TO_SC,
          SUB_LOCATION,
          RESERVE_ACTION,
          CREATED_DATETIME,
          CREATED_USERID,
          LAST_CHANGED_USERID,
          LAST_CHANGED_DATETIME,
          CREATED_ASSET_USERID,
          CREATED_ASSET_DATETIME,
          AWO,
          AWO_ALT,
          PO,
          PO_LINE,
          WCHD_ID,
          STATUS_1,
          STATUS_2,
          STATUS_3,
          MISSION_CAPABILITY,
          TEMP_OUT_TCN,
          FURNISHED_BY,
          OWNER_CODE,
          OWNER_MARKING,
          SHOP_BENCH_CODE,
          RECALL_CODE,
          ASSET_USED_IN_PROD_B,
          USAGE_PROFILE_CODE,
          ITEM_WAITING_DISPO,
          STANDARD_LEVEL,
          VENDOR_PART,
          LAST_ACTIVITY_CODE,
          LAST_ACTIVITY_DATE,
          USER_REF9,
          USER_REF10,
          INTERVAL_CHG_METHOD,
          INTERVAL_CHG_USERID,
          INTERVAL_CHG_DATETIME,
          NEXT_DATE_CHG_USERID,
          NEXT_DATE_CHG_DATETIME,
          NEXT_DATE_CHG_METHOD,
          ORIGINAL_INTERVAL,
          WARRANTY_CODE,
          WARRANTY_DATE,
          OWNING_ORDER_NO,
          UNIT_ASSN,
          DATE_OF_MANUF,
          STATUS_STRUCTURE,
          INTO_TOP_BOM_ID,
          INTO_STRUCTURE_CODE,
          INTO_SUB_STRUCTURE_CODE,
          INTO_POS,
          INTO_ALT_POS,
          FROM_TOP_BOM_ID,
          FROM_STRUCTURE_CODE,
          FROM_SUB_STRUCTURE_CODE,
          FROM_POS,
          FROM_ALT_POS,
          TAGGED_PROPERTY_B,
          REVISION_LEVEL,
          EQUIP_ID,
          STATUS_IN_USE_B,
          MAND_METER_EXPIRED_B,
          PO_SEQ,
          SECURITY_CODE,
          ACQUISITION_AUTHORITY,
          ACQUISITION_DOCUMENT,
          ACQUISITION_DOC_DT,
          TRANSACTION_DOCUMENT,
          TRANSACTION_DOC_DT,
          CONTRACT_AUTHORITY,
          DEPARTMENT,
          LOAN_NUMBER,
          NET_BOOK_VALUE,
          DISPO_GOLD_SCHED_1149,
          SCHED_START_DATE,
          MCC,
          STATUS_SUSPENDED,
          CHECK_TYPE,
          SCHD_DLV_DATE,
          IWA,
          DELIVERY_ORDER,
          STAND_ALONE_B,
          COST_SOURCE_CODE,
          COST_ORDER_NO,
          AC_REMOVED_FROM,
          AUTH_TYPE,
          PAPO,
          CFO_ACQUISITION_COST,
          CFO_ACQUISITION_DATE,
          CFO_REPORT_SYSTEM,
          TRANSFER_TRAN_ID,
          ACCOUNT_CODE,
          CAL_REQUIRED_B,
          PM_REQUIRED_B,
          BUGL,
          SOURCE_ROUTING_ID,
          RCDN,
          CONTRACTOR_REFERENCE_NUMBER
     FROM item@amd_goldsa_link;


DROP VIEW AMD_OWNER.GOLDSA_REQ1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.GOLDSA_REQ1_V
(
   REQUEST_ID,
   CREATED_DATETIME,
   QTY_REQUESTED,
   PRIME,
   NSN,
   STATUS,
   ALLOW_ALTS_YN,
   QTY_RESERVED,
   SELECT_FROM_PART,
   SELECT_FROM_SC,
   SELECT_FROM_LOC_ID,
   QTY_CANC,
   MILS_SOURCE_DIC,
   QTY_DUE,
   QTY_ISSUED,
   NEED_DATE,
   REQUEST_PRIORITY,
   PURPOSE_CODE,
   PROC_CODE
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (request_id),
          r.created_datetime,
          qty_requested,
          TRIM (r.prime),
          TRIM (r.nsn),
          status,
          allow_alts_yn,
          qty_reserved,
          TRIM (select_from_part),
          TRIM (select_from_sc),
          CASE
             WHEN     LENGTH (TRIM (select_from_sc)) >=
                         amd_defaults.getStartLocId + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (select_from_sc),
                                            amd_defaults.getStartLocId,
                                            6))
             THEN
                SUBSTR (TRIM (select_from_sc), 8, 6)
             ELSE
                NULL
          END
             select_from_loc_id,
          qty_canc,
          TRIM (mils_source_dic),
          qty_due,
          qty_issued,
          need_date,
          request_priority,
          purpose_code,
          proc_code
     FROM cat1@amd_goldsa_link c, req1@amd_goldsa_link r
    WHERE     c.part = r.select_from_part
          AND c.source_code = 'F77'
          AND r.select_from_sc = 'SATCAA0001C17G';


DROP VIEW AMD_OWNER.GOLDSA_WHSE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.GOLDSA_WHSE_V
(
   SC,
   PART,
   PRIME,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   USER_REF7,
   USER_REF8,
   USER_REF9,
   USER_REF10,
   USER_REF11,
   USER_REF12,
   USER_REF13,
   USER_REF14,
   USER_REF15,
   STOCK_LEVEL,
   REORDER_POINT,
   PRICE_CAP,
   PRICE_GFP,
   PRICE_ACTUAL,
   PRICE_AVE,
   PRICE_LAST_RECEIPT,
   LAST_PHYSICAL_QTY,
   LAST_PHYSICAL_DATE,
   CREATED_DATETIME,
   CREATED_USERID,
   LAST_CHANGED_DATETIME,
   LAST_CHANGED_USERID,
   PRICE_CHANGED_DATETIME,
   PRICE_CHANGED_USERID,
   DATE_LAST_ISSUE,
   DATE_LAST_ACTIVITY,
   MUR,
   MUR_START_DATE,
   MUR_END_DATE,
   MDR,
   MDR_START_DATE,
   MDR_END_DATE,
   REMARKS,
   DEFAULT_BIN,
   ARCHIVE_YN,
   LAST_ARCHIVE_DATETIME,
   GOVG_1662_TYPE,
   GOVG_PRICE,
   GOVG_QTY,
   GOVC_1662_TYPE,
   GOVC_PRICE,
   GOVC_QTY,
   USAGE_MRL_PERCENT,
   FREEZE_CODES,
   RECORD_CHANGED1_YN,
   RECORD_CHANGED2_YN,
   RECORD_CHANGED3_YN,
   RECORD_CHANGED4_YN,
   RECORD_CHANGED5_YN,
   RECORD_CHANGED6_YN,
   RECORD_CHANGED7_YN,
   RECORD_CHANGED8_YN,
   AUTH_ALLOW,
   BEST_ESTIMATE_QTY,
   QTY_PER_ASSEMBLY,
   LAST_ACQUISITION_PRICE,
   STOCK_LEVEL_FLOOR,
   STOCK_LEVEL_CEILING,
   STOCK_LEVEL_ADDITIVE,
   LAST_LEVEL_USERID,
   LAST_LEVEL_METHOD,
   LAST_LEVEL_DATETIME,
   COMPUTED_ORD_QTY,
   COMPUTED_EXC_OH_QTY,
   COMPUTED_EXC_DI_QTY,
   MIN_ORD_QTY,
   C_ELIN,
   MCC,
   SEE_AND_USE,
   CEC_BUY,
   CEC_REWORK,
   CC,
   G009_REPORTING_FLAG_B,
   DEFAULT_SUB_LOCATION,
   MILS_AUTO_PROCESS_B,
   ORDERING_MODULE,
   PLANNER_CODE,
   U_ID_EXEMPT_B,
   IMS_DESIGNATOR_CODE,
   ES_DESIGNATOR_CODE,
   ALLOW_ALTS_TFN,
   USE_DWO_BASED_SUBS_TFN,
   USE_PROG_BASED_SUBS_TFN,
   SUBS_PROGRAM,
   REQ_RESERVE_MANUAL_B,
   LOCK_AUTO_SLRO_UPD_B,
   BUYER,
   CFO_REPORT_SYSTEM
)
   BEQUEATH DEFINER
AS
   SELECT SC,
          PART,
          PRIME,
          USER_REF1,
          USER_REF2,
          USER_REF3,
          USER_REF4,
          USER_REF5,
          USER_REF6,
          USER_REF7,
          USER_REF8,
          USER_REF9,
          USER_REF10,
          USER_REF11,
          USER_REF12,
          USER_REF13,
          USER_REF14,
          USER_REF15,
          STOCK_LEVEL,
          REORDER_POINT,
          PRICE_CAP,
          PRICE_GFP,
          PRICE_ACTUAL,
          PRICE_AVE,
          PRICE_LAST_RECEIPT,
          LAST_PHYSICAL_QTY,
          LAST_PHYSICAL_DATE,
          CREATED_DATETIME,
          CREATED_USERID,
          LAST_CHANGED_DATETIME,
          LAST_CHANGED_USERID,
          PRICE_CHANGED_DATETIME,
          PRICE_CHANGED_USERID,
          DATE_LAST_ISSUE,
          DATE_LAST_ACTIVITY,
          MUR,
          MUR_START_DATE,
          MUR_END_DATE,
          MDR,
          MDR_START_DATE,
          MDR_END_DATE,
          REMARKS,
          DEFAULT_BIN,
          ARCHIVE_YN,
          LAST_ARCHIVE_DATETIME,
          GOVG_1662_TYPE,
          GOVG_PRICE,
          GOVG_QTY,
          GOVC_1662_TYPE,
          GOVC_PRICE,
          GOVC_QTY,
          USAGE_MRL_PERCENT,
          FREEZE_CODES,
          RECORD_CHANGED1_YN,
          RECORD_CHANGED2_YN,
          RECORD_CHANGED3_YN,
          RECORD_CHANGED4_YN,
          RECORD_CHANGED5_YN,
          RECORD_CHANGED6_YN,
          RECORD_CHANGED7_YN,
          RECORD_CHANGED8_YN,
          AUTH_ALLOW,
          BEST_ESTIMATE_QTY,
          QTY_PER_ASSEMBLY,
          LAST_ACQUISITION_PRICE,
          STOCK_LEVEL_FLOOR,
          STOCK_LEVEL_CEILING,
          STOCK_LEVEL_ADDITIVE,
          LAST_LEVEL_USERID,
          LAST_LEVEL_METHOD,
          LAST_LEVEL_DATETIME,
          COMPUTED_ORD_QTY,
          COMPUTED_EXC_OH_QTY,
          COMPUTED_EXC_DI_QTY,
          MIN_ORD_QTY,
          C_ELIN,
          MCC,
          SEE_AND_USE,
          CEC_BUY,
          CEC_REWORK,
          CC,
          G009_REPORTING_FLAG_B,
          DEFAULT_SUB_LOCATION,
          MILS_AUTO_PROCESS_B,
          ORDERING_MODULE,
          PLANNER_CODE,
          U_ID_EXEMPT_B,
          IMS_DESIGNATOR_CODE,
          ES_DESIGNATOR_CODE,
          ALLOW_ALTS_TFN,
          USE_DWO_BASED_SUBS_TFN,
          USE_PROG_BASED_SUBS_TFN,
          SUBS_PROGRAM,
          REQ_RESERVE_MANUAL_B,
          LOCK_AUTO_SLRO_UPD_B,
          BUYER,
          CFO_REPORT_SYSTEM
     FROM whse@amd_goldsa_link;


DROP VIEW AMD_OWNER.LRU_MASTER_LCN_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.LRU_MASTER_LCN_V
(
   LCN
)
   BEQUEATH DEFINER
AS
     SELECT DISTINCT amd_owner.slic_hg_v.LSACONXB LCN
       FROM amd_owner.slic_hg_v, cat1
      WHERE     SUBSTR (cat1.smrc, 1, 3) = 'PAO'
            AND SUBSTR (cat1.smrc, 6, 1) = 'T'
            AND CAT1.USER_REF7 <> 'Y'
            AND cat1.part = amd_owner.slic_hg_v.REFNUMHA
   ORDER BY amd_owner.slic_hg_v.LSACONXB;


DROP VIEW AMD_OWNER.LRU_PN_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.LRU_PN_V
(
   PART_NO,
   MASTER_LCN,
   LCN,
   PCCN,
   PLISN,
   QPA,
   INDENTURE,
   SLIC_SMR,
   SLIC_WUC,
   TOCC,
   SLIC_CAGE,
   SLIC_NOUN,
   GOLD_NOUN,
   USABLE_FROM,
   USABLE_TO,
   IMS,
   AAC,
   SOS,
   NSN,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
     SELECT lru_breakdown."PART_NO",
            lru_breakdown."MASTER_LCN",
            lru_breakdown."LCN",
            lru_breakdown."PCCN",
            lru_breakdown."PLISN",
            lru_breakdown."QPA",
            lru_breakdown."INDENTURE",
            lru_breakdown."SLIC_SMR",
            lru_breakdown."SLIC_WUC",
            lru_breakdown."TOCC",
            lru_breakdown."SLIC_CAGE",
            lru_breakdown."SLIC_NOUN",
            lru_breakdown.gold_noun,
            lru_breakdown."USABLE_FROM",
            lru_breakdown."USABLE_TO",
            lru_breakdown.ims,
            lru_breakdown.aac,
            lru_breakdown.sos,
            lru_breakdown.nsn,
            lru_breakdown."LAST_UPDATE_DT"
       FROM amd_owner.lru_breakdown
      WHERE master_lcn = lcn
   ORDER BY master_lcn, part_no;


DROP VIEW AMD_OWNER.PARTINFO_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PARTINFO_V
(
   MFGR,
   PART_NO,
   NOMENCLATURE,
   NSN,
   ORDER_LEAD_TIME,
   ORDER_LEAD_TIME_DEFAULTED,
   UNIT_COST,
   UNIT_COST_DEFAULTED,
   UNIT_OF_ISSUE,
   UNIT_COST_CLEANED,
   ORDER_LEAD_TIME_CLEANED,
   PLANNER_CODE,
   PLANNER_CODE_CLEANED,
   MTBDR,
   MTBDR_CLEANED,
   SMR_CODE,
   SMR_CODE_CLEANED,
   SMR_CODE_DEFAULTED,
   NSI_SID,
   TIME_TO_REPAIR_OFF_BASE_CLEAND
)
   BEQUEATH DEFINER
AS
   SELECT sp.mfgr,
          sp.part_no,
          sp.NOMENCLATURE,
          sp.nsn,
          sp.order_lead_time,
          sp.order_lead_time_defaulted,
          sp.unit_cost,
          sp.unit_cost_defaulted,
          sp.unit_of_issue,
          nsi.unit_cost_cleaned,
          nsi.order_lead_time_cleaned,
          nsi.planner_code,
          nsi.planner_code_cleaned,
          nsi.mtbdr,
          nsi.mtbdr_cleaned,
          nsi.smr_code,
          nsi.smr_code_cleaned,
          nsi.smr_code_defaulted,
          nsi.nsi_sid,
          nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND
     FROM AMD_SPARE_PARTS sp, AMD_NATIONAL_STOCK_ITEMS nsi
    WHERE sp.nsn = nsi.nsn AND sp.action_code != 'D';


DROP VIEW AMD_OWNER.PGOLD_AUXB_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_AUXB_V
(
   ENTNAME,
   KEY_VALUE1,
   KEY_VALUE2,
   RECORD_TYPE,
   FIELD_ID,
   FIELD_VALUE
)
   BEQUEATH DEFINER
AS
   SELECT ENTNAME,
          KEY_VALUE1,
          KEY_VALUE2,
          RECORD_TYPE,
          FIELD_ID,
          FIELD_VALUE
     FROM auxb@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_CAT1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_CAT1_V
(
   PART,
   NSN,
   NOUN,
   PRIME,
   NOUN_MOD_1,
   NOUN_MOD_2,
   CREATED_DATETIME,
   SMRC,
   ERRC,
   UM_SHOW_CODE,
   UM_ISSUE_SHOW_COUNT,
   UM_ISSUE_CODE,
   UM_ISSUE_CODE_COUNT,
   UM_ISSUE_FACTOR,
   UM_TURN_CODE,
   UM_TURN_SHOW_COUNT,
   UM_TURN_CODE_COUNT,
   UM_TURN_FACTOR,
   UM_DISP_CODE,
   UM_DISP_SHOW_COUNT,
   UM_DISP_CODE_COUNT,
   UM_DISP_FACTOR,
   UM_CAP_CODE,
   UM_CAP_SHOW_COUNT,
   UM_CAP_CODE_COUNT,
   UM_CAP_FACTOR,
   UM_MIL_CODE,
   UM_MIL_SHOW_COUNT,
   UM_MIL_CODE_COUNT,
   UM_MIL_FACTOR,
   CREATED_USERID,
   AVE_CAP_LEAD_TIME,
   AVE_MIL_LEAD_TIME,
   CATEGORY_INSTRUMENT,
   LAST_CHANGED_USERID,
   LAST_CHANGED_DATETIME,
   SECURITY_CODE,
   SOURCE_CODE,
   ORDER_CAP_B,
   ORDER_GFP_B,
   EXP_WARRANTY_CODE,
   BUYER,
   STATUS_TYPE,
   COGNIZANCE_CODE,
   ABBR_PART,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   SHIP_REPS_CODE,
   SHIP_REPS_PRIORITY,
   DELETE_WHEN_GONE,
   ASSET_REQ_ON_RECEIPT,
   RECORD_CHANGED1_YN,
   RECORD_CHANGED2_YN,
   RECORD_CHANGED3_YN,
   RECORD_CHANGED4_YN,
   RECORD_CHANGED5_YN,
   RECORD_CHANGED6_YN,
   RECORD_CHANGED7_YN,
   RECORD_CHANGED8_YN,
   NIN,
   TRACKED_B,
   DODIC,
   CFA,
   PART_MAKE_B,
   PART_BUY_B,
   REMARKS,
   IMS_DESIGNATOR_CODE,
   DEMILITARIZATION_CODE,
   HAZARDOUS_MATERIAL_CODE,
   PMI_CODE,
   CRITICAL_ITEM_CODE,
   INV_CLASS_CODE,
   ATA_CHAPTER_NO,
   HAZARDOUS_MATERIAL_B,
   LOT_BATCH_MANDATORY_B,
   SERIAL_MANDATORY_B,
   KEY_REF_MANDATORY_B,
   CORE_EXC_REQ_B,
   TEC,
   WIP_TYPE,
   ORDER_COM_B,
   AVE_COM_LEAD_TIME,
   MANUF_CAGE,
   DEPR_PCT_OVERRIDE,
   MIN_EQUIPMENT_LIST_B,
   COMPRESSED_PART,
   AVE_BLD_LEAD_TIME,
   AVE_REP_LEAD_TIME,
   AVE_VREP_LEAD_TIME,
   BUDGET_CODE,
   ISGP_GROUP_NO,
   USER_REF7,
   USER_REF8,
   USER_REF9,
   USER_REF10,
   USER_REF11,
   USER_REF12,
   USER_REF13,
   USER_REF14,
   USER_REF15,
   AGENCY_PECULIAR_B,
   ES_DESIGNATOR_CODE,
   CAT1_PROFILE,
   MILS_AUTO_PROCESS_B,
   FSC,
   ISGP_GROUP_NO1,
   ISGP_GROUP_NO2,
   ISGP_GROUP_NO3,
   ISGP_GROUP_NO4,
   TRANSITION_SOS,
   ADPE_CD,
   FUND_CD,
   FSP_B,
   IMS_DES_SEC_B,
   CEC_BUY,
   CEC_REWORK,
   CC,
   NEW_PRODUCT_WARR_B,
   REPAIR_WARRANTY_B,
   PRODUCT_WARR_PERIOD,
   REPAIR_WARR_PERIOD,
   WARRANTY_MGR_1,
   WARRANTY_MGR_2,
   PLANNER_CODE,
   U_ID_REQUIRED_B,
   MRP_PLANNED_B,
   REQ_RESERVE_MANUAL,
   JIT_PART_B,
   PREFERRED_NSN_B,
   RMA_NO_MAND_B,
   PREFERRED_ORDER_NSN_B,
   SPECIFICATION_NO,
   SPECIFICATION_CAGE,
   TYPE_CFO_RPT_AF,
   TYPE_CFO_RPT_ARMY,
   TYPE_CFO_RPT_MC,
   TYPE_CFO_RPT_NAVY,
   TYPE_CFO_RPT_DLA
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (PART),
          TRIM (NSN),
          TRIM (NOUN),
          TRIM (PRIME),
          NOUN_MOD_1,
          NOUN_MOD_2,
          CREATED_DATETIME,
          TRIM (SMRC),
          TRIM (ERRC),
          CASE
             WHEN LENGTH (TRIM (UM_SHOW_CODE)) > 2
             THEN
                SUBSTR (TRIM (um_show_code), 1, 2)
             ELSE
                TRIM (um_show_code)
          END
             um_show_code,
          UM_ISSUE_SHOW_COUNT,
          TRIM (UM_ISSUE_CODE),
          UM_ISSUE_CODE_COUNT,
          UM_ISSUE_FACTOR,
          TRIM (UM_TURN_CODE),
          UM_TURN_SHOW_COUNT,
          UM_TURN_CODE_COUNT,
          UM_TURN_FACTOR,
          TRIM (UM_DISP_CODE),
          UM_DISP_SHOW_COUNT,
          UM_DISP_CODE_COUNT,
          UM_DISP_FACTOR,
          CASE
             WHEN LENGTH (TRIM (UM_CAP_CODE)) > 2
             THEN
                SUBSTR (TRIM (um_cap_code), 1, 2)
             ELSE
                TRIM (um_cap_code)
          END
             UM_CAP_CODE,
          UM_CAP_SHOW_COUNT,
          UM_CAP_CODE_COUNT,
          UM_CAP_FACTOR,
          TRIM (UM_MIL_CODE),
          UM_MIL_SHOW_COUNT,
          UM_MIL_CODE_COUNT,
          UM_MIL_FACTOR,
          CREATED_USERID,
          TRIM (AVE_CAP_LEAD_TIME),
          AVE_MIL_LEAD_TIME,
          CATEGORY_INSTRUMENT,
          LAST_CHANGED_USERID,
          LAST_CHANGED_DATETIME,
          SECURITY_CODE,
          TRIM (SOURCE_CODE),
          ORDER_CAP_B,
          ORDER_GFP_B,
          EXP_WARRANTY_CODE,
          BUYER,
          STATUS_TYPE,
          COGNIZANCE_CODE,
          TRIM (ABBR_PART),
          USER_REF1,
          TRIM (USER_REF2),
          USER_REF3,
          TRIM (USER_REF4),
          USER_REF5,
          USER_REF6,
          SHIP_REPS_CODE,
          SHIP_REPS_PRIORITY,
          DELETE_WHEN_GONE,
          ASSET_REQ_ON_RECEIPT,
          RECORD_CHANGED1_YN,
          RECORD_CHANGED2_YN,
          RECORD_CHANGED3_YN,
          RECORD_CHANGED4_YN,
          RECORD_CHANGED5_YN,
          RECORD_CHANGED6_YN,
          RECORD_CHANGED7_YN,
          RECORD_CHANGED8_YN,
          NIN,
          TRACKED_B,
          DODIC,
          CFA,
          PART_MAKE_B,
          PART_BUY_B,
          TRIM (REMARKS),
          TRIM (IMS_DESIGNATOR_CODE),
          DEMILITARIZATION_CODE,
          TRIM (HAZARDOUS_MATERIAL_CODE),
          PMI_CODE,
          CRITICAL_ITEM_CODE,
          INV_CLASS_CODE,
          ATA_CHAPTER_NO,
          HAZARDOUS_MATERIAL_B,
          LOT_BATCH_MANDATORY_B,
          TRIM (SERIAL_MANDATORY_B),
          KEY_REF_MANDATORY_B,
          CORE_EXC_REQ_B,
          TEC,
          WIP_TYPE,
          ORDER_COM_B,
          AVE_COM_LEAD_TIME,
          TRIM (MANUF_CAGE),
          DEPR_PCT_OVERRIDE,
          MIN_EQUIPMENT_LIST_B,
          COMPRESSED_PART,
          AVE_BLD_LEAD_TIME,
          AVE_REP_LEAD_TIME,
          AVE_VREP_LEAD_TIME,
          BUDGET_CODE,
          TRIM (ISGP_GROUP_NO),
          TRIM (USER_REF7),
          USER_REF8,
          USER_REF9,
          USER_REF10,
          USER_REF11,
          USER_REF12,
          USER_REF13,
          USER_REF14,
          USER_REF15,
          AGENCY_PECULIAR_B,
          ES_DESIGNATOR_CODE,
          CAT1_PROFILE,
          MILS_AUTO_PROCESS_B,
          FSC,
          ISGP_GROUP_NO1,
          ISGP_GROUP_NO2,
          ISGP_GROUP_NO3,
          ISGP_GROUP_NO4,
          TRANSITION_SOS,
          ADPE_CD,
          FUND_CD,
          FSP_B,
          IMS_DES_SEC_B,
          CEC_BUY,
          CEC_REWORK,
          CC,
          NEW_PRODUCT_WARR_B,
          REPAIR_WARRANTY_B,
          PRODUCT_WARR_PERIOD,
          REPAIR_WARR_PERIOD,
          WARRANTY_MGR_1,
          WARRANTY_MGR_2,
          PLANNER_CODE,
          U_ID_REQUIRED_B,
          MRP_PLANNED_B,
          REQ_RESERVE_MANUAL,
          JIT_PART_B,
          PREFERRED_NSN_B,
          RMA_NO_MAND_B,
          PREFERRED_ORDER_NSN_B,
          SPECIFICATION_NO,
          SPECIFICATION_CAGE,
          TYPE_CFO_RPT_AF,
          TYPE_CFO_RPT_ARMY,
          TYPE_CFO_RPT_MC,
          TYPE_CFO_RPT_NAVY,
          TYPE_CFO_RPT_DLA
     FROM cat1@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_CATS$MERGED_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_CATS$MERGED_V
(
   SC,
   PART,
   CATEGORY_INSTRUMENT,
   SECURITY_CODE,
   CAGE,
   PART_CAGE,
   VERSION_NUMBER
)
   BEQUEATH DEFINER
AS
   SELECT SC,
          PART,
          CATEGORY_INSTRUMENT,
          SECURITY_CODE,
          CAGE,
          PART_CAGE,
          VERSION_NUMBER
     FROM cats$merged@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_CGVT_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_CGVT_V
(
   SERVICE_CODE,
   STOCK_NUMBER,
   ISG_MASTER_STOCK_NUMBER,
   ISG_OOU_CODE
)
   BEQUEATH DEFINER
AS
   SELECT service_code,
          stock_number,
          isg_master_stock_number,
          isg_oou_code
     FROM cgvt@amd_pgoldlb_link
    WHERE stock_number IS NOT NULL AND isg_master_stock_number IS NOT NULL;


DROP VIEW AMD_OWNER.PGOLD_CHGH_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_CHGH_V
(
   CHGH_ID,
   KEY_VALUE1,
   "TO",
   FIELD,
   "FROM"
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (chgh_id),
          key_value1,
          "TO",
          field,
          "FROM"
     FROM chgh@amd_pgoldlb_link
    WHERE field = 'NSN';


DROP VIEW AMD_OWNER.PGOLD_FEDC_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_FEDC_V
(
   PART_NUMBER,
   VENDOR_CODE,
   SEQ_NUMBER,
   VENDOR_PART,
   VENDOR_NAME,
   NIIN,
   NOUN,
   UNIT_OF_ISSUE,
   SOURCE_CODE,
   COGNIZANCE_CODE,
   PMI_CODE,
   DEMILITARIZATION_CODE,
   NSN,
   NSN_SMIC,
   SMRC,
   ERRC_CODE,
   ERRC_DESIGNATOR,
   IMS_DESIGNATOR_CODE,
   HAZARDOUS_MATERIAL_CODE,
   CRITICAL_ITEM_CODE,
   ISGP_GROUP_NO,
   BUDGET_CODE,
   SECURITY_CODE,
   GFP_PRICE,
   PRICE1,
   ACTIVITY_CODE,
   WRITE_FLAG
)
   BEQUEATH DEFINER
AS
   SELECT PART_NUMBER,
          VENDOR_CODE,
          SEQ_NUMBER,
          VENDOR_PART,
          VENDOR_NAME,
          NIIN,
          NOUN,
          UNIT_OF_ISSUE,
          SOURCE_CODE,
          COGNIZANCE_CODE,
          PMI_CODE,
          DEMILITARIZATION_CODE,
          NSN,
          NSN_SMIC,
          SMRC,
          ERRC_CODE,
          ERRC_DESIGNATOR,
          IMS_DESIGNATOR_CODE,
          HAZARDOUS_MATERIAL_CODE,
          CRITICAL_ITEM_CODE,
          ISGP_GROUP_NO,
          BUDGET_CODE,
          SECURITY_CODE,
          GFP_PRICE,
          PRICE1,
          ACTIVITY_CODE,
          WRITE_FLAG
     FROM fedc@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_ISGP_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_ISGP_V
(
   SC,
   PART,
   GROUP_NO,
   RELATIONSHIP_TYPE,
   GROUP_PRIORITY,
   JUMP_TO,
   INCOMPATIBILITY_CODE,
   DISABLED_B,
   SEQUENCE_NO
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (SC),
          TRIM (PART),
          TRIM (GROUP_NO),
          RELATIONSHIP_TYPE,
          TRIM (GROUP_PRIORITY),
          JUMP_TO,
          INCOMPATIBILITY_CODE,
          DISABLED_B,
          SEQUENCE_NO
     FROM isgp@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_ITEM_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_ITEM_V
(
   ITEM_ID,
   RECEIVED_ITEM_ID,
   SC,
   PART,
   PRIME,
   CONDITION,
   STATUS_DEL_WHEN_GONE,
   STATUS_SERVICABLE,
   STATUS_NEW_ORDER,
   STATUS_ACCOUNTABLE,
   STATUS_AVAIL,
   STATUS_FROZEN,
   STATUS_ACTIVE,
   STATUS_MAI,
   STATUS_RECEIVING_SUSP,
   STATUS_2,
   STATUS_3,
   LAST_CHANGED_DATETIME,
   STATUS_1,
   CREATED_DATETIME,
   VENDOR_CODE,
   QTY,
   ORDER_NO,
   RECEIPT_ORDER_NO
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (item_id),
          TRIM (received_item_id),
          TRIM (sc),
          TRIM (part),
          TRIM (prime),
          TRIM (condition),
          status_del_when_gone,
          status_servicable,
          status_new_order,
          status_accountable,
          status_avail,
          status_frozen,
          status_active,
          status_mai,
          status_receiving_susp,
          status_2,
          status_3,
          last_changed_datetime,
          status_1,
          created_datetime,
          TRIM (vendor_code),
          qty,
          TRIM (order_no),
          TRIM (receipt_order_no)
     FROM item@amd_pgoldlb_link
    WHERE     status_1 != 'D'
          AND condition NOT IN ('LDD')
          AND (   last_changed_datetime IS NOT NULL
               OR created_datetime IS NOT NULL);


DROP VIEW AMD_OWNER.PGOLD_LVLS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_LVLS_V
(
   NIIN,
   SRAN,
   NSN,
   LVL_DOCUMENT_NUMBER,
   DOCUMENT_DATETIME,
   CURRENT_STOCK_NUMBER,
   COMPATIBILITY_CODE,
   DATE_LVL_LOADED,
   REORDER_POINT,
   ECONOMIC_ORDER_QTY,
   APPROVED_LVL_QTY
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (niin),
          TRIM (sran),
          REPLACE (SUBSTR (TRIM (current_stock_number), 1, 16), '-', ''),
          TRIM (lvl_document_number),
          document_datetime,
          SUBSTR (TRIM (current_stock_number), 1, 16),
          TRIM (compatibility_code),
          TO_DATE (date_lvl_loaded, 'yyddd') date_lvl_loaded,
          reorder_point,
          economic_order_qty,
          approved_lvl_qty
     FROM lvls@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_MILS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_MILS_V
(
   MILS_ID,
   REC_TYPES,
   ORDER_NO,
   REQUEST_ID,
   CREATED_DATETIME,
   TRANSMIT_FLAG,
   DATE_PRINTED,
   MILS_ACTIVITY,
   MILS_OWNERSHIP_CODE,
   MILS_PROFILE,
   CARD_DATETIME,
   STATUS_LINE,
   PART,
   SC,
   USERID,
   GSTAT_DATE,
   STAMP_DATE,
   BATCH_NUMBER,
   DEFAULT_NAME,
   EFFECTIVE_DATE,
   PROCESS_STATUS,
   ERROR_MSG_CODE,
   ERROR_MSG,
   TRAN_ID,
   MAIN_TABLE,
   MAIN_TABLE_KEY_VALUE,
   KEY_REF,
   LOT,
   R13M_FILE_ID,
   INTERNAL_REPLEN_B,
   BILLING_RI,
   BILLING_NUMBER,
   DESIGNATOR_CODE,
   STOCK_NUMBER,
   MMAC_SMIC,
   CFO_REPORT_SYSTEM,
   CFO_MAC,
   CFO_MAC_DATE,
   CFO_MAC_STATUS,
   CFO_REPORT_DATE,
   TRAN_INT_DESIGNATOR
)
   BEQUEATH DEFINER
AS
   SELECT MILS_ID,
          REC_TYPES,
          ORDER_NO,
          REQUEST_ID,
          CREATED_DATETIME,
          TRANSMIT_FLAG,
          DATE_PRINTED,
          MILS_ACTIVITY,
          MILS_OWNERSHIP_CODE,
          MILS_PROFILE,
          CARD_DATETIME,
          STATUS_LINE,
          PART,
          SC,
          USERID,
          GSTAT_DATE,
          STAMP_DATE,
          BATCH_NUMBER,
          DEFAULT_NAME,
          EFFECTIVE_DATE,
          PROCESS_STATUS,
          ERROR_MSG_CODE,
          ERROR_MSG,
          TRAN_ID,
          MAIN_TABLE,
          MAIN_TABLE_KEY_VALUE,
          KEY_REF,
          LOT,
          R13M_FILE_ID,
          INTERNAL_REPLEN_B,
          BILLING_RI,
          BILLING_NUMBER,
          DESIGNATOR_CODE,
          STOCK_NUMBER,
          MMAC_SMIC,
          CFO_REPORT_SYSTEM,
          CFO_MAC,
          CFO_MAC_DATE,
          CFO_MAC_STATUS,
          CFO_REPORT_DATE,
          TRAN_INT_DESIGNATOR
     FROM mils@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_MLIT_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_MLIT_V
(
   DOCUMENT_ID,
   CUSTOMER,
   MILS_ACTIVITY,
   MILS_OWNERSHIP_CODE,
   MILS_PROFILE,
   IN_TRAN_FROM,
   IN_TRAN_TO,
   IN_TRAN_TYPE,
   PART,
   ABBR_PART,
   CREATE_DATE,
   SHIP_DATE,
   RECEIPT_DATE,
   START_DATE_TIME,
   CREATE_QTY,
   SHIP_QTY,
   RECEIPT_QTY,
   MILS_CONDITION,
   STATUS_IND
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (document_id),
          TRIM (customer),
          TRIM (mils_activity),
          TRIM (mils_ownership_code),
          TRIM (mils_profile),
          TRIM (in_tran_from),
          TRIM (in_tran_to),
          TRIM (in_tran_type),
          TRIM (part),
          TRIM (abbr_part),
          create_date,
          ship_date,
          receipt_date,
          start_date_time,
          create_qty,
          ship_qty,
          receipt_qty,
          mils_condition,
          status_ind
     FROM mlit@amd_pgoldlb_link
    WHERE    TRIM (part) != TRIM (abbr_part) AND status_ind = 'I'
          OR TRIM (abbr_part) IS NULL AND status_ind = 'I';


DROP VIEW AMD_OWNER.PGOLD_MLVT_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_MLVT_V
(
   CUSTOMER,
   MILS_ACTIVITY,
   MILS_OWNERSHIP_CODE,
   MILS_PROFILE,
   DODAAC,
   ROUTING_IDENTIFIER,
   TYPE_VALIDATION_IND,
   DODAAC_NAME,
   MIL_LOCATION_CODE,
   MILS_AUTO_PROCESS_B,
   SRVC_IN_TRAN_IND,
   RPR_IN_TRAN_IND,
   ITV_REQUIRED_B,
   ALLOW_REQUISITION_B,
   ALLOW_SHIPMENT_B,
   ACTIVITY_DODAAC,
   ACTIVITY_ROUTING_ID,
   FMS_B,
   DEFAULT_DODAAC_SEG_CD,
   TYPE_RDD_IND,
   R13M_FILE_ID,
   DRMO_DODAAC,
   DRMO_ROUTING_ID,
   DRMO_SCRAP_FROM,
   DRMO_SCRAP_TO,
   LEVELS_APPROVAL_IND,
   DRA_CLOSEOUT_BYPASS,
   PSERIAL_BYPASS_B,
   USE_SPECIAL_1348,
   AMQ_DESIGNATOR_B,
   MIL_DESIGNATOR_CODE,
   CAT_DESIGNATOR_CODE,
   BIL_DESIGNATOR_CODE,
   TRANS_ACCT_CODE,
   SHIP_TO_POE,
   POD,
   FMS_CASE,
   BLK60_FF_DODAAC,
   BLK60_TYPE_DODAAC,
   BLK60_FF_REQUIRED,
   BLK60_COLOCATED_DODAAC,
   DEPOT_PARTNER_IND,
   CFO_RELATIONSHIP_CD,
   CFO_SERVICE_CD,
   CFO_USER_FUND_CD,
   CFO_BUYER_FUND_CD,
   CFO_SALES_CD,
   CFO_USER_APPROPRIATION,
   CFO_BUYER_APPROPRIATION,
   IFI_0107_SELECTION_SEQ,
   IFI_0107_DEF_PRIORITY,
   IFI_0107_STATUS_OVERIDE,
   REQUISITION_SC,
   EXT_REQUISITIONER_YN
)
   BEQUEATH DEFINER
AS
   SELECT CUSTOMER,
          MILS_ACTIVITY,
          MILS_OWNERSHIP_CODE,
          MILS_PROFILE,
          DODAAC,
          ROUTING_IDENTIFIER,
          TYPE_VALIDATION_IND,
          DODAAC_NAME,
          MIL_LOCATION_CODE,
          MILS_AUTO_PROCESS_B,
          SRVC_IN_TRAN_IND,
          RPR_IN_TRAN_IND,
          ITV_REQUIRED_B,
          ALLOW_REQUISITION_B,
          ALLOW_SHIPMENT_B,
          ACTIVITY_DODAAC,
          ACTIVITY_ROUTING_ID,
          FMS_B,
          DEFAULT_DODAAC_SEG_CD,
          TYPE_RDD_IND,
          R13M_FILE_ID,
          DRMO_DODAAC,
          DRMO_ROUTING_ID,
          DRMO_SCRAP_FROM,
          DRMO_SCRAP_TO,
          LEVELS_APPROVAL_IND,
          DRA_CLOSEOUT_BYPASS,
          PSERIAL_BYPASS_B,
          USE_SPECIAL_1348,
          AMQ_DESIGNATOR_B,
          MIL_DESIGNATOR_CODE,
          CAT_DESIGNATOR_CODE,
          BIL_DESIGNATOR_CODE,
          TRANS_ACCT_CODE,
          SHIP_TO_POE,
          POD,
          FMS_CASE,
          BLK60_FF_DODAAC,
          BLK60_TYPE_DODAAC,
          BLK60_FF_REQUIRED,
          BLK60_COLOCATED_DODAAC,
          DEPOT_PARTNER_IND,
          CFO_RELATIONSHIP_CD,
          CFO_SERVICE_CD,
          CFO_USER_FUND_CD,
          CFO_BUYER_FUND_CD,
          CFO_SALES_CD,
          CFO_USER_APPROPRIATION,
          CFO_BUYER_APPROPRIATION,
          IFI_0107_SELECTION_SEQ,
          IFI_0107_DEF_PRIORITY,
          IFI_0107_STATUS_OVERIDE,
          REQUISITION_SC,
          EXT_REQUISITIONER_YN
     FROM mlvt@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_NSN1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_NSN1_V
(
   NSN,
   NSN_SMIC
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (nsn), TRIM (nsn_smic) FROM nsn1@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_ORD1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_ORD1_V
(
   ORDER_NO,
   ORDER_TYPE,
   STEP,
   MILSTRIP_PROCEDURE,
   SC,
   PART,
   STATUS,
   AWO,
   AWO_ALT,
   PO,
   PO_LINE,
   QTY_COMPLETED,
   QTY_ORDERED,
   QTY_DUE,
   QTY_CANC,
   QTY_ADDED,
   QTY_ORIGINAL_ORDERED,
   QTY_SPLIT,
   UNIT_PRICE,
   REPLACED_BY_ORDER_NO,
   VENDOR_CODE,
   PRIORITY,
   MAKE_BUY_CODE,
   NEED_DATE,
   ECD,
   DODAC,
   FORM_PRINTED_DATETIME,
   WORKSTOPAGE_CODE,
   UM_ORDER_CODE,
   UM_ORDER_ISSUE_COUNT,
   UM_ORDER_CODE_COUNT,
   UM_ORDER_FACTOR,
   REMARKS,
   QTY_PER_PACK,
   DELIVER_TO_LOCATION,
   INTERFACE_ACK_DATETIME,
   ORIGINAL_PRICE,
   REPAIR_TYPE,
   PCT_COMPLETE,
   LABOR_HRS,
   CREATED_DOCDATE,
   CREATED_DATETIME,
   PRIORITY_CHG_DATETIME,
   CREATED_USERID,
   REQUESTED_USERID,
   COMPLETED_DOCDATE,
   COMPLETED_DATETIME,
   COMPLETED_USERID,
   LAST_CHANGED_DATETIME,
   LAST_CHANGED_USERID,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   TOT_MAT_COST,
   PART_REQUESTED,
   BUYER,
   TOP_ORDER_NO,
   NH_ORDER_NO,
   LVL,
   WCHD_ID,
   ACCOUNTABLE_YN,
   SERIAL,
   CONDITION,
   ORIGINAL_CONDITION,
   LOT,
   KEY_REF,
   LOCATION,
   ITEM_ID,
   RECEIPT_VOUCHER,
   REVIEWED_USERID,
   REVIEWED_DATETIME,
   PO_PRICE,
   ACTIVITY_CODE,
   FURNISHED_BY,
   WPHD_ID,
   ASSET_ID,
   DEFAULT_B,
   FROM_OUTSIDE,
   FUND_TYPE,
   ACTION_TAKEN,
   JOB_CONTROL_NUMBER,
   REMOVED_FROM,
   TYPE_MAINTENANCE,
   SRD,
   WHEN_DISCOVERED,
   HOW_MAL,
   REF_DES,
   SUPPLY_DOCUMENT,
   DISCREPANCY,
   TCN,
   ORIGINAL_LOCATION,
   TRAN_ID_IN,
   TRAN_ID_OUT,
   TO_PART_NUMBER,
   DEFAULT_ID,
   PO_SEQ,
   WIP_DATETIME,
   WIP_STATUS,
   CORRECTIVE_ACTION,
   CONTAINER_Y,
   CONTAINER_N,
   CONTAINER_W,
   CONTAINER_WAIVER,
   CURR_JDD1_ID,
   DJHD_NAME,
   DEFAULT_ORDER,
   MASTER_FORM_TYPE,
   RECURRENCE,
   JOB_PROFILE_TYPE,
   JCN_DAY,
   JCN_ORG,
   JCN_SER,
   JCN_SUF,
   EQUIP_ID,
   MISSION_CAPABILITY,
   STATUS_FROZEN,
   ORDER_PRICE_B,
   NHA_PART,
   MILS_SOURCE_DIC,
   MILS_RECEIPT_SUFFIX,
   DIRECT_SHIP_B,
   ECD_CALC_HLDR,
   EST_START_DATE,
   MCC,
   CEC,
   CC,
   C_ELIN,
   SEQ_NO,
   NEW_ORD_YN,
   RETURN_DIC,
   INSP_REQUIRED_B,
   SHIP_TO_VENN,
   DATE_TO_VEND,
   EST_RETURN_DATE,
   NOTICE_OF_SHIPMENT,
   DEPT,
   NCM_ACC,
   NCM_POS,
   NCM_EST_HRS,
   NCM_TYPE,
   BTU,
   SPLIT_FM_ORDER_NO,
   QTY_OVER_RCVD,
   MFG_LOT_SIZE,
   PLANNER_CODE,
   START_DATETIME,
   EARNED_HOURS,
   PICK_TICK_DT,
   MATL_OVERHEAD_PCT,
   LABOR_OVERHEAD_PCT,
   REPAIR_ORDER_B,
   MILSBILLS_STATUS,
   INTERNAL_REPLEN_B,
   SUB_LOCATION,
   JIT_AWO,
   FORECAST_REF_NO,
   INIT_RECEIPT_DATETIME,
   NM_DIRECT_SHIP_B,
   VENDOR_PART,
   AUTO_SET_DIRECT_SHIP_B,
   BLK60_RDO_B,
   WORK_NO,
   TAIL_NO,
   FAILURE_DATE,
   USER_REF7,
   USER_REF8,
   USER_REF9,
   USER_REF10,
   USER_REF11,
   USER_REF12,
   USER_REF13,
   USER_REF14,
   RMA_NO,
   DEPOT_PARTNER_IND,
   MAINTENANCE_DOCUMENT,
   TRANSPORTATION_DOCUMENT,
   DEPOT_PARTNER_DODAAC,
   COST_ACCUM_ORDER,
   NCM_EMERGENT_SCHEDULED,
   NCM_PLAN_NO,
   NCM_PLAN_TYPE,
   NCM_PLAN_DESCRIPTION,
   UM_OVR,
   UM_OVR_QTY_ORD,
   UM_OVR_QTY_CANC,
   UM_OVR_QTY_ADDED,
   UM_OVR_FACTOR,
   CFO_SERVICE_CD,
   CFO_USER_FUND_CD,
   CFO_BUYER_FUND_CD,
   CFO_SALES_CD,
   CFO_RELATIONSHIP_CD,
   IFI_USER_CONTROL_NO,
   EST_TOTAL_ORDER_COST,
   ACT_MAT_OR_SRV_COST,
   ACT_NET_ADJ_COST,
   SOURCE_OF_SUPPLY,
   MEDIA_STATUS_CODE,
   DEMAND_CODE,
   SUPP_ADDRESS,
   SIGNAL_CODE,
   FUND_CODE,
   DISTRIBUTION_CODE_1,
   DISTRIBUTION_CODE_2_3,
   SPECIAL_RDD,
   PROJECT_CODE,
   ADVICE_CODE,
   MILS_DOCUMENT_NO,
   CAV_ORDER_NO,
   REPAIR_DOCUMENT_NO
)
   BEQUEATH DEFINER
AS
   SELECT ORDER_NO,
          ORDER_TYPE,
          STEP,
          MILSTRIP_PROCEDURE,
          SC,
          PART,
          STATUS,
          AWO,
          AWO_ALT,
          PO,
          PO_LINE,
          QTY_COMPLETED,
          QTY_ORDERED,
          QTY_DUE,
          QTY_CANC,
          QTY_ADDED,
          QTY_ORIGINAL_ORDERED,
          QTY_SPLIT,
          UNIT_PRICE,
          REPLACED_BY_ORDER_NO,
          VENDOR_CODE,
          PRIORITY,
          MAKE_BUY_CODE,
          NEED_DATE,
          ECD,
          DODAC,
          FORM_PRINTED_DATETIME,
          WORKSTOPAGE_CODE,
          UM_ORDER_CODE,
          UM_ORDER_ISSUE_COUNT,
          UM_ORDER_CODE_COUNT,
          UM_ORDER_FACTOR,
          REMARKS,
          QTY_PER_PACK,
          DELIVER_TO_LOCATION,
          INTERFACE_ACK_DATETIME,
          ORIGINAL_PRICE,
          REPAIR_TYPE,
          PCT_COMPLETE,
          LABOR_HRS,
          CREATED_DOCDATE,
          CREATED_DATETIME,
          PRIORITY_CHG_DATETIME,
          CREATED_USERID,
          REQUESTED_USERID,
          COMPLETED_DOCDATE,
          COMPLETED_DATETIME,
          COMPLETED_USERID,
          LAST_CHANGED_DATETIME,
          LAST_CHANGED_USERID,
          USER_REF1,
          USER_REF2,
          USER_REF3,
          USER_REF4,
          USER_REF5,
          USER_REF6,
          TOT_MAT_COST,
          PART_REQUESTED,
          BUYER,
          TOP_ORDER_NO,
          NH_ORDER_NO,
          LVL,
          WCHD_ID,
          ACCOUNTABLE_YN,
          SERIAL,
          CONDITION,
          ORIGINAL_CONDITION,
          LOT,
          KEY_REF,
          LOCATION,
          ITEM_ID,
          RECEIPT_VOUCHER,
          REVIEWED_USERID,
          REVIEWED_DATETIME,
          PO_PRICE,
          ACTIVITY_CODE,
          FURNISHED_BY,
          WPHD_ID,
          ASSET_ID,
          DEFAULT_B,
          FROM_OUTSIDE,
          FUND_TYPE,
          ACTION_TAKEN,
          JOB_CONTROL_NUMBER,
          REMOVED_FROM,
          TYPE_MAINTENANCE,
          SRD,
          WHEN_DISCOVERED,
          HOW_MAL,
          REF_DES,
          SUPPLY_DOCUMENT,
          DISCREPANCY,
          TCN,
          ORIGINAL_LOCATION,
          TRAN_ID_IN,
          TRAN_ID_OUT,
          TO_PART_NUMBER,
          DEFAULT_ID,
          PO_SEQ,
          WIP_DATETIME,
          WIP_STATUS,
          CORRECTIVE_ACTION,
          CONTAINER_Y,
          CONTAINER_N,
          CONTAINER_W,
          CONTAINER_WAIVER,
          CURR_JDD1_ID,
          DJHD_NAME,
          DEFAULT_ORDER,
          MASTER_FORM_TYPE,
          RECURRENCE,
          JOB_PROFILE_TYPE,
          JCN_DAY,
          JCN_ORG,
          JCN_SER,
          JCN_SUF,
          EQUIP_ID,
          MISSION_CAPABILITY,
          STATUS_FROZEN,
          ORDER_PRICE_B,
          NHA_PART,
          MILS_SOURCE_DIC,
          MILS_RECEIPT_SUFFIX,
          DIRECT_SHIP_B,
          ECD_CALC_HLDR,
          EST_START_DATE,
          MCC,
          CEC,
          CC,
          C_ELIN,
          SEQ_NO,
          NEW_ORD_YN,
          RETURN_DIC,
          INSP_REQUIRED_B,
          SHIP_TO_VENN,
          DATE_TO_VEND,
          EST_RETURN_DATE,
          NOTICE_OF_SHIPMENT,
          DEPT,
          NCM_ACC,
          NCM_POS,
          NCM_EST_HRS,
          NCM_TYPE,
          BTU,
          SPLIT_FM_ORDER_NO,
          QTY_OVER_RCVD,
          MFG_LOT_SIZE,
          PLANNER_CODE,
          START_DATETIME,
          EARNED_HOURS,
          PICK_TICK_DT,
          MATL_OVERHEAD_PCT,
          LABOR_OVERHEAD_PCT,
          REPAIR_ORDER_B,
          MILSBILLS_STATUS,
          INTERNAL_REPLEN_B,
          SUB_LOCATION,
          JIT_AWO,
          FORECAST_REF_NO,
          INIT_RECEIPT_DATETIME,
          NM_DIRECT_SHIP_B,
          VENDOR_PART,
          AUTO_SET_DIRECT_SHIP_B,
          BLK60_RDO_B,
          WORK_NO,
          TAIL_NO,
          FAILURE_DATE,
          USER_REF7,
          USER_REF8,
          USER_REF9,
          USER_REF10,
          USER_REF11,
          USER_REF12,
          USER_REF13,
          USER_REF14,
          RMA_NO,
          DEPOT_PARTNER_IND,
          MAINTENANCE_DOCUMENT,
          TRANSPORTATION_DOCUMENT,
          DEPOT_PARTNER_DODAAC,
          COST_ACCUM_ORDER,
          NCM_EMERGENT_SCHEDULED,
          NCM_PLAN_NO,
          NCM_PLAN_TYPE,
          NCM_PLAN_DESCRIPTION,
          UM_OVR,
          UM_OVR_QTY_ORD,
          UM_OVR_QTY_CANC,
          UM_OVR_QTY_ADDED,
          UM_OVR_FACTOR,
          CFO_SERVICE_CD,
          CFO_USER_FUND_CD,
          CFO_BUYER_FUND_CD,
          CFO_SALES_CD,
          CFO_RELATIONSHIP_CD,
          IFI_USER_CONTROL_NO,
          EST_TOTAL_ORDER_COST,
          ACT_MAT_OR_SRV_COST,
          ACT_NET_ADJ_COST,
          SOURCE_OF_SUPPLY,
          MEDIA_STATUS_CODE,
          DEMAND_CODE,
          SUPP_ADDRESS,
          SIGNAL_CODE,
          FUND_CODE,
          DISTRIBUTION_CODE_1,
          DISTRIBUTION_CODE_2_3,
          SPECIAL_RDD,
          PROJECT_CODE,
          ADVICE_CODE,
          MILS_DOCUMENT_NO,
          CAV_ORDER_NO,
          REPAIR_DOCUMENT_NO
     FROM ord1@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_ORDV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_ORDV_V
(
   ORDER_NO,
   SITE_CODE,
   VENDOR_EST_COST,
   VENDOR_EST_RET_DATE
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (order_no),
          site_code,
          vendor_est_cost,
          vendor_est_ret_date
     FROM ordv@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_POI1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_POI1_V
(
   ORDER_NO,
   SEQ,
   ITEM,
   QTY,
   ITEM_LINE,
   EXT_PRICE,
   PART,
   CCN,
   DELIVERY_DATE
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (order_no),
          TRIM (seq),
          TRIM (item),
          TRIM (qty),
          TRIM (item_line),
          TRIM (ext_price),
          TRIM (part),
          TRIM (ccn),
          TRIM (delivery_date)
     FROM poi1@amd_pgoldlb_link
    WHERE ext_price IS NOT NULL;


DROP VIEW AMD_OWNER.PGOLD_PRC1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_PRC1_V
(
   SC,
   PART,
   CAP_PRICE,
   GFP_PRICE
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (sc),
          TRIM (part),
          cap_price,
          gfp_price
     FROM prc1@amd_pgoldlb_link
    WHERE sc = 'DEF' AND part NOT LIKE '% ' AND part NOT LIKE ' %';


DROP VIEW AMD_OWNER.PGOLD_RAMP_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_RAMP_V
(
   NSN,
   SC,
   SRAN,
   SERVICEABLE_BALANCE,
   DUE_IN_BALANCE,
   DUE_OUT_BALANCE,
   DIFM_BALANCE,
   DATE_PROCESSED,
   AVG_REPAIR_CYCLE_TIME,
   PERCENT_BASE_CONDEM,
   PERCENT_BASE_REPAIR,
   DAILY_DEMAND_RATE,
   CURRENT_STOCK_NUMBER,
   RETENTION_LEVEL,
   HPMSK_BALANCE,
   DEMAND_LEVEL,
   UNSERVICEABLE_BALANCE,
   SUSPENDED_IN_STOCK,
   WRM_BALANCE,
   WRM_LEVEL,
   REQUISITION_OBJECTIVE,
   HPMSK_LEVEL_QTY,
   SPRAM_LEVEL,
   SPRAM_BALANCE,
   DELETE_INDICATOR,
   TOTAL_INACCESSIBLE_QTY
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (niin),
          TRIM (sc),
          SUBSTR (sc, 8, 6),
          serviceable_balance,
          due_in_balance,
          due_out_balance,
          difm_balance,
          date_processed,
          avg_repair_cycle_time,
          percent_base_condem,
          percent_base_repair,
          daily_demand_rate,
          SUBSTR (TRIM (current_stock_number), 1, 16),
          retention_level,
          hpmsk_balance,
          demand_level,
          unserviceable_balance,
          suspended_in_stock,
          wrm_balance,
          wrm_level,
          requisition_objective,
          hpmsk_level_qty,
          spram_level,
          spram_balance,
          TRIM (delete_indicator),
          total_inaccessible_qty
     FROM ramp@amd_pgoldlb_link
    WHERE delete_indicator IS NULL;


DROP VIEW AMD_OWNER.PGOLD_REQ1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_REQ1_V
(
   REQUEST_ID,
   STATUS,
   SELECT_FROM_SC,
   SELECT_FROM_PART,
   SELECT_FROM_SERIAL,
   SELECT_FROM_LOCATION,
   REQUEST_ID_ALT,
   SELECT_FROM_CONDITION,
   CREATED_ORDER_NO,
   LOCKED_INTO_ORDER_NO,
   ORDER_PRIORITY,
   REQUEST_PRIORITY,
   PRIME,
   BOM_ID,
   ORDERED_DATETIME,
   ALLOW_ALTS_YN,
   FORM1_PRINTED_DATETIME,
   FORM2_PRINTED_DATETIME,
   ADVICE_CODE,
   OVERRIDE_PRIORITY,
   FAD_URGENCY,
   PROJ_CODE,
   WORK_AREA,
   MODEX,
   NO_ACTIVITY_CODE,
   DEMAND_CODE,
   PUB_REFA,
   PUB_REFB,
   COMPANY_CURR_STATUS,
   REMARKS,
   QTY_REQUESTED,
   QTY_RESERVED,
   QTY_ISSUED,
   QTY_CANC,
   QTY_DUE,
   QTY_INIT_ORDERED,
   QTY_TO_ORDER,
   NEED_DATE,
   HELD_UNTIL_DATE,
   CREATED_DATETIME,
   CREATED_DOC_DATE,
   CREATED_USERID,
   LAST_CHANGED_DATETIME,
   LAST_CHANGED_USERID,
   REVIEWED_DATETIME,
   REVIEWED_USERID,
   REVIEWED_REMARKS,
   SATISFIED_DATETIME,
   SATISFIED_DOC_DATE,
   SATISFIED_USERID,
   EXP_DATE,
   STATUS_DATE,
   STATUS_USERID,
   ISSUE_TO_ORDER_NO,
   REASON_CODE,
   CHARGE_TO_AWO,
   WORK_STOP_YN,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   SELECT_FROM_AWO,
   DELIV_ADDR,
   PA_PROC_B,
   SELECT_FROM_KEY_REF,
   SELECT_FROM_LOT,
   TRN_B,
   SUPPLY_UI,
   ORG_SHOP_CODE,
   NSN,
   MARK_FOR,
   UNIT_OF_ISSUE,
   PURPOSE_CODE,
   INTO_TOP_BOM_ID,
   INTO_STRUCTURE_CODE,
   INTO_SUB_STRUCTURE_CODE,
   INTO_POS,
   INTO_ALT_POS,
   TURN_ITEM_ID,
   CANI_ID,
   ON_BASE_ONLY_B,
   MICAP_B,
   RECURRING_B,
   INITIAL_B,
   FILL_OR_KILL_B,
   MASTER_FORM_TYPE,
   DELIV_TO_REMARKS,
   TEC,
   UJC,
   MILS_SOURCE_DIC,
   VENDOR_CODE,
   NHA_PART,
   SELECT_FROM_ASSET_ID,
   DELIVER_TO_DODAAC,
   SPECIAL_RDD,
   SPECIAL_RDD_DATETIME,
   MICAP_HOURS,
   DATE_RECEIPT_PROCESSED,
   ECD,
   ECD_LAST_UPDATE,
   SOURCE_OF_ECD,
   DIRECT_SHIP_B,
   PROC_CODE,
   DRA_COUNT_B,
   DRB_COUNT_B,
   DRA_QTY_MISMATCH_B,
   DRA_OTHER_MISMATCH_B,
   A2_RDO_B,
   A2_SUB_B,
   STOCK_REL_BYPASS_B,
   PRINT_IMMEDIATE_B,
   HOLD_SHIPMENT_B,
   DWO_BASED_SUBS_B,
   PROG_BASED_SUBS_B,
   SUBS_PROGRAM,
   DRA_STATUS,
   EI_JOB_ORDER,
   EI_WORK_ORDER,
   EI_DELIVERY_DEST,
   EI_SERIAL,
   D6_COUNT_B,
   D6_QTY_MISMATCH_B,
   REQ_RESERVE_MANUAL_B,
   ALLOW_CLOSED_ORD_ISS_B,
   BLK60_RDO_B,
   AF_MICAP_START_DATETIME,
   AF_MICAP_STOP_DATETIME,
   AF_MICAP_HOURS,
   DEPOT_REPAIR_B,
   UM_OVR,
   UM_OVR_QTY_REQ,
   UM_OVR_QTY_CANC,
   UM_OVR_FACTOR,
   UM_OVR_QTY_RES,
   UM_OVR_QTY_ISU,
   UM_OVR_QTY_DUE,
   NSN_SMIC,
   DORE_ID,
   REQUESTED_BY
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (REQUEST_ID),
          STATUS,
          TRIM (SELECT_FROM_SC),
          TRIM (SELECT_FROM_PART),
          SELECT_FROM_SERIAL,
          SELECT_FROM_LOCATION,
          REQUEST_ID_ALT,
          SELECT_FROM_CONDITION,
          CREATED_ORDER_NO,
          LOCKED_INTO_ORDER_NO,
          ORDER_PRIORITY,
          REQUEST_PRIORITY,
          TRIM (PRIME),
          BOM_ID,
          ORDERED_DATETIME,
          ALLOW_ALTS_YN,
          FORM1_PRINTED_DATETIME,
          FORM2_PRINTED_DATETIME,
          ADVICE_CODE,
          OVERRIDE_PRIORITY,
          FAD_URGENCY,
          PROJ_CODE,
          WORK_AREA,
          MODEX,
          NO_ACTIVITY_CODE,
          DEMAND_CODE,
          PUB_REFA,
          PUB_REFB,
          COMPANY_CURR_STATUS,
          REMARKS,
          QTY_REQUESTED,
          QTY_RESERVED,
          QTY_ISSUED,
          QTY_CANC,
          QTY_DUE,
          QTY_INIT_ORDERED,
          QTY_TO_ORDER,
          NEED_DATE,
          HELD_UNTIL_DATE,
          CREATED_DATETIME,
          CREATED_DOC_DATE,
          CREATED_USERID,
          LAST_CHANGED_DATETIME,
          LAST_CHANGED_USERID,
          REVIEWED_DATETIME,
          REVIEWED_USERID,
          REVIEWED_REMARKS,
          SATISFIED_DATETIME,
          SATISFIED_DOC_DATE,
          SATISFIED_USERID,
          EXP_DATE,
          STATUS_DATE,
          STATUS_USERID,
          ISSUE_TO_ORDER_NO,
          REASON_CODE,
          CHARGE_TO_AWO,
          WORK_STOP_YN,
          USER_REF1,
          USER_REF2,
          USER_REF3,
          USER_REF4,
          USER_REF5,
          USER_REF6,
          SELECT_FROM_AWO,
          DELIV_ADDR,
          PA_PROC_B,
          SELECT_FROM_KEY_REF,
          SELECT_FROM_LOT,
          TRN_B,
          SUPPLY_UI,
          ORG_SHOP_CODE,
          TRIM (NSN),
          MARK_FOR,
          UNIT_OF_ISSUE,
          PURPOSE_CODE,
          INTO_TOP_BOM_ID,
          INTO_STRUCTURE_CODE,
          INTO_SUB_STRUCTURE_CODE,
          INTO_POS,
          INTO_ALT_POS,
          TURN_ITEM_ID,
          CANI_ID,
          ON_BASE_ONLY_B,
          MICAP_B,
          RECURRING_B,
          INITIAL_B,
          FILL_OR_KILL_B,
          MASTER_FORM_TYPE,
          DELIV_TO_REMARKS,
          TEC,
          UJC,
          TRIM (MILS_SOURCE_DIC),
          VENDOR_CODE,
          NHA_PART,
          SELECT_FROM_ASSET_ID,
          DELIVER_TO_DODAAC,
          SPECIAL_RDD,
          SPECIAL_RDD_DATETIME,
          MICAP_HOURS,
          DATE_RECEIPT_PROCESSED,
          ECD,
          ECD_LAST_UPDATE,
          SOURCE_OF_ECD,
          DIRECT_SHIP_B,
          PROC_CODE,
          DRA_COUNT_B,
          DRB_COUNT_B,
          DRA_QTY_MISMATCH_B,
          DRA_OTHER_MISMATCH_B,
          A2_RDO_B,
          A2_SUB_B,
          STOCK_REL_BYPASS_B,
          PRINT_IMMEDIATE_B,
          HOLD_SHIPMENT_B,
          DWO_BASED_SUBS_B,
          PROG_BASED_SUBS_B,
          SUBS_PROGRAM,
          DRA_STATUS,
          EI_JOB_ORDER,
          EI_WORK_ORDER,
          EI_DELIVERY_DEST,
          EI_SERIAL,
          D6_COUNT_B,
          D6_QTY_MISMATCH_B,
          REQ_RESERVE_MANUAL_B,
          ALLOW_CLOSED_ORD_ISS_B,
          BLK60_RDO_B,
          AF_MICAP_START_DATETIME,
          AF_MICAP_STOP_DATETIME,
          AF_MICAP_HOURS,
          DEPOT_REPAIR_B,
          UM_OVR,
          UM_OVR_QTY_REQ,
          UM_OVR_QTY_CANC,
          UM_OVR_FACTOR,
          UM_OVR_QTY_RES,
          UM_OVR_QTY_ISU,
          UM_OVR_QTY_DUE,
          NSN_SMIC,
          DORE_ID,
          REQUESTED_BY
     FROM req1@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_RSV1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_RSV1_V
(
   RESERVE_ID,
   FORM_REQUIRED_YN,
   REMARK_MOVE_ONLY_YN,
   CREATED_DOCDATE,
   TO_SC,
   ITEM_ID,
   STATUS
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (reserve_id),
          form_required_yn,
          remark_move_only_yn,
          created_docdate,
          TRIM (to_sc),
          TRIM (item_id),
          status
     FROM rsv1@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_SC01_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_SC01_V
(
   SC,
   CONTRACT_NUMBER,
   REPAIR_PRIORITY,
   DESCRIPTION,
   STATUS,
   FUND_TYPE,
   COMM_GOVT_CODE,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   USER_REF7,
   USER_REF8,
   USER_REF9,
   USER_REF10,
   USER_REF11,
   USER_REF12,
   USER_REF13,
   USER_REF14,
   USER_REF15,
   USER_REF16,
   USER_REF17,
   USER_REF18,
   USER_REF19,
   USER_REF20,
   CREATED_USERID,
   LAST_CHANGED_USERID,
   LAST_CHANGED_DATETIME,
   CREATED_DATETIME,
   REMARKS,
   CUSTOMER_TYPE,
   FREEZE_ORDERING_B,
   FREEZE_RECEIVING_B,
   FREEZE_ISSUES_DISP_B,
   FREEZE_XFER_IN_CONT_B,
   FREEZE_XFER_OUT_CONT_B,
   FREEZE_OTHER_TRAN_B,
   GFP_ORDER_MANUAL_B,
   GFP_ORDER_AUTO_B,
   GFP_BEG_LINE_PER_DAY,
   GFP_END_LINE_PER_DAY,
   GFP_CREATE_ORDER_AUTH_B,
   CAP_ORDER_MANUAL_B,
   CAP_ORDER_AUTO_B,
   FAD_CODE,
   CAP_BEG_LINE_PER_DAY,
   CAP_END_LINE_PER_DAY,
   CAP_CREATE_ORDER_AUTH_B,
   COMM_ORDER_MANUAL_B,
   COMM_ORDER_AUTO_B,
   COMM_BEG_LINE_PER_DAY,
   COMM_END_LINE_PER_DAY,
   COMM_CREATE_ORD_AUTH_B,
   GFP_OVER_RECEIVE_B,
   GFP_PRICE_CHG_ON_RCPT_B,
   CAP_OVER_RECEIVE_B,
   CAP_PRICE_CHG_ON_RCPT_B,
   COMM_OVER_RECEIVE_B,
   COMM_PRC_CHG_ON_RCPT_B,
   VENDOR_MAND_CAP_RCPT_B,
   VENDOR_MAND_COMM_RCPT_B,
   LOCATION_MAND_RCPT_B,
   LABOR_COSTING_ACT_STD,
   LABOR_COSTING_AVG_RATE,
   BER_PERCENT_OF_PRICE,
   BER_WARNING_1,
   BER_WARNING_2,
   JOB_AWO,
   CAP_AWO,
   GFP_AWO,
   COMM_AWO,
   JIT_AWO,
   CUSTODIAN_AT_SC_LEVEL_B,
   SC_LEVEL_CUSTODIAN,
   CUST_ALT1_AT_SC_LEVEL_B,
   SC_LEVEL_CUST_ALT1,
   CUST_ALT2_AT_SC_LEVEL_B,
   SC_LEVEL_CUST_ALT2,
   OWNER_CODE,
   OWNER_MARKING,
   OWNER_CD_SC_LEV_B,
   OWNER_MK_SC_LEV_B,
   ACT_SCHED_MAND_B,
   SITE_CODE,
   FURNISHED_BY,
   DPAS_RATING,
   POSSESSES_EQUIP_B,
   POWER_BY_HOUR_B,
   CONSIGNMENT_B,
   EMBODIMENT_B,
   OWNS_EQUIPMENT_B,
   ORDERING_SC,
   PBH_SC,
   CONUS_B,
   ROUTING_IDENTIFIER,
   DEF_REQ_PREFIX,
   DODAAC,
   SC_AREA_CODE,
   CONTRACT_PO,
   WARN_ZERO_RCPT_PRICE_B,
   MILS_ACTIVITY,
   MILS_OWNERSHIP_CODE,
   MILS_PROFILE,
   G009_ABBR_PIIN,
   G009_REPORTING_FLAG_B,
   G009_SUPP_PIIN,
   G009_FUNDING_ALC_CODE,
   VENDOR_MAND_NSL_RCPT_B,
   RAMPS_REPORT_DATE,
   ISG_DESIGNATOR_CODE,
   SUPP_PIN_MAND_B,
   MATL_OVERHEAD_PCT,
   LABOR_OVERHEAD_PCT,
   MFG_ORDER_AUTO_B
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (SC),
          CONTRACT_NUMBER,
          REPAIR_PRIORITY,
          TRIM (DESCRIPTION),
          STATUS,
          FUND_TYPE,
          COMM_GOVT_CODE,
          TRIM (USER_REF1),
          USER_REF2,
          USER_REF3,
          USER_REF4,
          USER_REF5,
          USER_REF6,
          USER_REF7,
          TRIM (USER_REF8),
          USER_REF9,
          USER_REF10,
          USER_REF11,
          USER_REF12,
          USER_REF13,
          USER_REF14,
          USER_REF15,
          USER_REF16,
          USER_REF17,
          USER_REF18,
          USER_REF19,
          USER_REF20,
          CREATED_USERID,
          LAST_CHANGED_USERID,
          LAST_CHANGED_DATETIME,
          CREATED_DATETIME,
          REMARKS,
          CUSTOMER_TYPE,
          FREEZE_ORDERING_B,
          FREEZE_RECEIVING_B,
          FREEZE_ISSUES_DISP_B,
          FREEZE_XFER_IN_CONT_B,
          FREEZE_XFER_OUT_CONT_B,
          FREEZE_OTHER_TRAN_B,
          GFP_ORDER_MANUAL_B,
          GFP_ORDER_AUTO_B,
          GFP_BEG_LINE_PER_DAY,
          GFP_END_LINE_PER_DAY,
          GFP_CREATE_ORDER_AUTH_B,
          CAP_ORDER_MANUAL_B,
          CAP_ORDER_AUTO_B,
          FAD_CODE,
          CAP_BEG_LINE_PER_DAY,
          CAP_END_LINE_PER_DAY,
          CAP_CREATE_ORDER_AUTH_B,
          COMM_ORDER_MANUAL_B,
          COMM_ORDER_AUTO_B,
          COMM_BEG_LINE_PER_DAY,
          COMM_END_LINE_PER_DAY,
          COMM_CREATE_ORD_AUTH_B,
          GFP_OVER_RECEIVE_B,
          GFP_PRICE_CHG_ON_RCPT_B,
          CAP_OVER_RECEIVE_B,
          CAP_PRICE_CHG_ON_RCPT_B,
          COMM_OVER_RECEIVE_B,
          COMM_PRC_CHG_ON_RCPT_B,
          VENDOR_MAND_CAP_RCPT_B,
          VENDOR_MAND_COMM_RCPT_B,
          LOCATION_MAND_RCPT_B,
          LABOR_COSTING_ACT_STD,
          LABOR_COSTING_AVG_RATE,
          BER_PERCENT_OF_PRICE,
          BER_WARNING_1,
          BER_WARNING_2,
          JOB_AWO,
          CAP_AWO,
          GFP_AWO,
          COMM_AWO,
          JIT_AWO,
          CUSTODIAN_AT_SC_LEVEL_B,
          SC_LEVEL_CUSTODIAN,
          CUST_ALT1_AT_SC_LEVEL_B,
          SC_LEVEL_CUST_ALT1,
          CUST_ALT2_AT_SC_LEVEL_B,
          SC_LEVEL_CUST_ALT2,
          OWNER_CODE,
          OWNER_MARKING,
          OWNER_CD_SC_LEV_B,
          OWNER_MK_SC_LEV_B,
          ACT_SCHED_MAND_B,
          SITE_CODE,
          FURNISHED_BY,
          DPAS_RATING,
          POSSESSES_EQUIP_B,
          POWER_BY_HOUR_B,
          CONSIGNMENT_B,
          EMBODIMENT_B,
          OWNS_EQUIPMENT_B,
          ORDERING_SC,
          PBH_SC,
          CONUS_B,
          ROUTING_IDENTIFIER,
          DEF_REQ_PREFIX,
          DODAAC,
          SC_AREA_CODE,
          CONTRACT_PO,
          WARN_ZERO_RCPT_PRICE_B,
          MILS_ACTIVITY,
          MILS_OWNERSHIP_CODE,
          MILS_PROFILE,
          G009_ABBR_PIIN,
          G009_REPORTING_FLAG_B,
          G009_SUPP_PIIN,
          G009_FUNDING_ALC_CODE,
          VENDOR_MAND_NSL_RCPT_B,
          RAMPS_REPORT_DATE,
          ISG_DESIGNATOR_CODE,
          SUPP_PIN_MAND_B,
          MATL_OVERHEAD_PCT,
          LABOR_OVERHEAD_PCT,
          MFG_ORDER_AUTO_B
     FROM sc01@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_TMP1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_TMP1_V
(
   QTY_DUE,
   RETURNED_VOUCHER,
   STATUS,
   TCN,
   FROM_SC,
   TO_SC,
   FROM_DATETIME,
   TEMP_OUT_ID,
   FROM_PART,
   EST_RETURN_DATE
)
   BEQUEATH DEFINER
AS
   SELECT qty_due,
          TRIM (returned_voucher),
          status,
          TRIM (tcn),
          TRIM (from_sc),
          TRIM (to_sc),
          from_datetime,
          TRIM (temp_out_id),
          TRIM (from_part),
          est_return_date
     FROM tmp1@amd_pgoldlb_link
    WHERE returned_voucher IS NULL AND status = 'O' AND tcn IN ('LNI', 'LBR');


DROP VIEW AMD_OWNER.PGOLD_TRHI_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_TRHI_V
(
   TRAN_ID,
   CREATED_DATETIME,
   DOCUMENT_DATETIME,
   QTY,
   PART,
   CREATED_USERID,
   SC,
   MINUS_DATETIME,
   ITEM_ID,
   ORDER_NO,
   RECEIVED_ITEM_ID,
   FT_FROM_LOCATION,
   TCN,
   CHANGE_TYPE,
   VOUCHER
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (tran_id),
          TO_CHAR (trhi.created_datetime),
          document_datetime,
          trhi.qty,
          TRIM (trhi.part),
          TRIM (trhi.created_userid),
          TRIM (sc),
          TO_CHAR (minus_datetime),
          TRIM (item_id),
          TRIM (order_no),
          TRIM (received_item_id),
          TRIM (ft_from_location),
          TRIM (tcn),
          TRIM (change_type),
          TRIM (voucher)
     FROM trhi@amd_pgoldlb_link trhi, cat1@amd_pgoldlb_link cat1
    WHERE     trhi.tcn = 'DII'
          AND trhi.part = cat1.part
          AND trhi.minus_datetime IS NULL
          AND cat1.source_code = 'F77';


DROP VIEW AMD_OWNER.PGOLD_UIMS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_UIMS_V
(
   USERID,
   DESIGNATOR_CODE,
   ALT_IMS_DES_CODE_B,
   ALT_ES_DES_CODE_B,
   ALT_SUP_DES_CODE_B
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (userid),
          designator_code,
          alt_ims_des_code_b,
          alt_es_des_code_b,
          alt_sup_des_code_b
     FROM uims@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_USE1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_USE1_V
(
   USERID,
   USER_NAME,
   EMPLOYEE_NO,
   EMPLOYEE_STATUS,
   PHONE,
   IMS_DESIGNATOR_CODE
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (userid),
          TRIM (user_name),
          TRIM (employee_no),
          employee_status,
          TRIM (phone),
          TRIM (ims_designator_code)
     FROM use1@amd_pgoldlb_link
    WHERE employee_no IS NOT NULL AND employee_status != 'I';


DROP VIEW AMD_OWNER.PGOLD_VENC_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_VENC_V
(
   PART,
   SEQ,
   VENDOR_CODE,
   USER_REF1
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (part),
          seq,
          TRIM (vendor_code),
          TRIM (user_ref1)
     FROM venc@amd_pgoldlb_link
    WHERE seq = 1;


DROP VIEW AMD_OWNER.PGOLD_VENN_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_VENN_V
(
   VENDOR_CODE,
   VENDOR_NAME,
   CAGE_CODE,
   USER_REF1
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (vendor_code),
          TRIM (vendor_name),
          TRIM (cage_code),
          TRIM (user_ref1)
     FROM venn@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_WHSE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_WHSE_V
(
   SC,
   PART,
   PRIME,
   USER_REF1,
   USER_REF2,
   USER_REF3,
   USER_REF4,
   USER_REF5,
   USER_REF6,
   USER_REF7,
   USER_REF8,
   USER_REF9,
   USER_REF10,
   USER_REF11,
   USER_REF12,
   USER_REF13,
   USER_REF14,
   USER_REF15,
   STOCK_LEVEL,
   REORDER_POINT,
   PRICE_CAP,
   PRICE_GFP,
   PRICE_ACTUAL,
   PRICE_AVE,
   PRICE_LAST_RECEIPT,
   LAST_PHYSICAL_QTY,
   LAST_PHYSICAL_DATE,
   CREATED_DATETIME,
   CREATED_USERID,
   LAST_CHANGED_DATETIME,
   LAST_CHANGED_USERID,
   PRICE_CHANGED_DATETIME,
   PRICE_CHANGED_USERID,
   DATE_LAST_ISSUE,
   DATE_LAST_ACTIVITY,
   MUR,
   MUR_START_DATE,
   MUR_END_DATE,
   MDR,
   MDR_START_DATE,
   MDR_END_DATE,
   REMARKS,
   DEFAULT_BIN,
   ARCHIVE_YN,
   LAST_ARCHIVE_DATETIME,
   GOVG_1662_TYPE,
   GOVG_PRICE,
   GOVG_QTY,
   GOVC_1662_TYPE,
   GOVC_PRICE,
   GOVC_QTY,
   USAGE_MRL_PERCENT,
   FREEZE_CODES,
   RECORD_CHANGED1_YN,
   RECORD_CHANGED2_YN,
   RECORD_CHANGED3_YN,
   RECORD_CHANGED4_YN,
   RECORD_CHANGED5_YN,
   RECORD_CHANGED6_YN,
   RECORD_CHANGED7_YN,
   RECORD_CHANGED8_YN,
   AUTH_ALLOW,
   BEST_ESTIMATE_QTY,
   QTY_PER_ASSEMBLY,
   LAST_ACQUISITION_PRICE,
   STOCK_LEVEL_FLOOR,
   STOCK_LEVEL_CEILING,
   STOCK_LEVEL_ADDITIVE,
   LAST_LEVEL_USERID,
   LAST_LEVEL_METHOD,
   LAST_LEVEL_DATETIME,
   COMPUTED_ORD_QTY,
   COMPUTED_EXC_OH_QTY,
   COMPUTED_EXC_DI_QTY,
   MIN_ORD_QTY,
   C_ELIN,
   MCC,
   SEE_AND_USE,
   CEC_BUY,
   CEC_REWORK,
   CC,
   G009_REPORTING_FLAG_B,
   DEFAULT_SUB_LOCATION,
   MILS_AUTO_PROCESS_B,
   ORDERING_MODULE,
   PLANNER_CODE,
   U_ID_EXEMPT_B,
   IMS_DESIGNATOR_CODE,
   ES_DESIGNATOR_CODE,
   ALLOW_ALTS_TFN,
   USE_DWO_BASED_SUBS_TFN,
   USE_PROG_BASED_SUBS_TFN,
   SUBS_PROGRAM,
   REQ_RESERVE_MANUAL_B,
   LOCK_AUTO_SLRO_UPD_B,
   BUYER,
   CFO_REPORT_SYSTEM
)
   BEQUEATH DEFINER
AS
   SELECT TRIM (SC),
          TRIM (PART),
          TRIM (PRIME),
          USER_REF1,
          USER_REF2,
          USER_REF3,
          TRIM (USER_REF4),
          TRIM (USER_REF5),
          USER_REF6,
          USER_REF7,
          USER_REF8,
          USER_REF9,
          USER_REF10,
          USER_REF11,
          USER_REF12,
          USER_REF13,
          USER_REF14,
          USER_REF15,
          STOCK_LEVEL,
          REORDER_POINT,
          PRICE_CAP,
          PRICE_GFP,
          PRICE_ACTUAL,
          PRICE_AVE,
          PRICE_LAST_RECEIPT,
          LAST_PHYSICAL_QTY,
          LAST_PHYSICAL_DATE,
          CREATED_DATETIME,
          CREATED_USERID,
          LAST_CHANGED_DATETIME,
          LAST_CHANGED_USERID,
          PRICE_CHANGED_DATETIME,
          PRICE_CHANGED_USERID,
          DATE_LAST_ISSUE,
          DATE_LAST_ACTIVITY,
          MUR,
          MUR_START_DATE,
          MUR_END_DATE,
          MDR,
          MDR_START_DATE,
          MDR_END_DATE,
          REMARKS,
          DEFAULT_BIN,
          ARCHIVE_YN,
          LAST_ARCHIVE_DATETIME,
          GOVG_1662_TYPE,
          GOVG_PRICE,
          GOVG_QTY,
          GOVC_1662_TYPE,
          GOVC_PRICE,
          GOVC_QTY,
          USAGE_MRL_PERCENT,
          FREEZE_CODES,
          RECORD_CHANGED1_YN,
          RECORD_CHANGED2_YN,
          RECORD_CHANGED3_YN,
          RECORD_CHANGED4_YN,
          RECORD_CHANGED5_YN,
          RECORD_CHANGED6_YN,
          RECORD_CHANGED7_YN,
          RECORD_CHANGED8_YN,
          AUTH_ALLOW,
          BEST_ESTIMATE_QTY,
          QTY_PER_ASSEMBLY,
          LAST_ACQUISITION_PRICE,
          STOCK_LEVEL_FLOOR,
          STOCK_LEVEL_CEILING,
          STOCK_LEVEL_ADDITIVE,
          LAST_LEVEL_USERID,
          LAST_LEVEL_METHOD,
          LAST_LEVEL_DATETIME,
          COMPUTED_ORD_QTY,
          COMPUTED_EXC_OH_QTY,
          COMPUTED_EXC_DI_QTY,
          MIN_ORD_QTY,
          C_ELIN,
          MCC,
          SEE_AND_USE,
          CEC_BUY,
          CEC_REWORK,
          CC,
          G009_REPORTING_FLAG_B,
          DEFAULT_SUB_LOCATION,
          MILS_AUTO_PROCESS_B,
          ORDERING_MODULE,
          PLANNER_CODE,
          U_ID_EXEMPT_B,
          IMS_DESIGNATOR_CODE,
          ES_DESIGNATOR_CODE,
          ALLOW_ALTS_TFN,
          USE_DWO_BASED_SUBS_TFN,
          USE_PROG_BASED_SUBS_TFN,
          SUBS_PROGRAM,
          REQ_RESERVE_MANUAL_B,
          LOCK_AUTO_SLRO_UPD_B,
          BUYER,
          CFO_REPORT_SYSTEM
     FROM whse@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PGOLD_WIP1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_WIP1_V
(
   ITEM_ID,
   CREATED_DOC_DATETIME,
   ORDER_NO,
   CREATED_SYS_DATETIME,
   CREATED_USERID,
   CREATED_DOC_MDAY,
   WORK_CENTER,
   DELAY_CODE,
   EXCLUDE_DELAY_TIME,
   CDAY_SPAN,
   MDAY_SPAN,
   LAST_CHANGED_DATETIME,
   LAST_CHANGED_USERID,
   REMARKS,
   MOVED_BY_NAME,
   WIPS_ID,
   LABOR_HOURS,
   LABOR_WORK_CENTER,
   RESPONSIBLE,
   TRAN_ID
)
   BEQUEATH DEFINER
AS
   SELECT ITEM_ID,
          CREATED_DOC_DATETIME,
          ORDER_NO,
          CREATED_SYS_DATETIME,
          CREATED_USERID,
          CREATED_DOC_MDAY,
          WORK_CENTER,
          DELAY_CODE,
          EXCLUDE_DELAY_TIME,
          CDAY_SPAN,
          MDAY_SPAN,
          LAST_CHANGED_DATETIME,
          LAST_CHANGED_USERID,
          REMARKS,
          MOVED_BY_NAME,
          WIPS_ID,
          LABOR_HOURS,
          LABOR_WORK_CENTER,
          RESPONSIBLE,
          TRAN_ID
     FROM wip1@amd_pgoldlb_link;


DROP VIEW AMD_OWNER.PULL_ORD1_D_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PULL_ORD1_D_V
(
   PN,
   FINISH_DATE,
   START_DATE,
   ACTION_TAKEN
)
   BEQUEATH DEFINER
AS
   SELECT SUBSTR (c.prime, 1, 20)                   "PN",
          TO_CHAR (Completed_docdate, 'MM/DD/YYYY') "FINISH DATE",
          TO_CHAR (created_docdate, 'MM/DD/YYYY')   start_date,
          action_taken                              "ACTION TAKEN"
     FROM cat1 C, ord1 I
    WHERE     c.source_code = 'F77'
          AND C.PART = I.PART
          AND Action_taken = 'D'
          AND order_no NOT IN (SELECT list_value
                                 FROM amd_lists
                                WHERE list_name = 'PULL_ORD1_D');


DROP VIEW AMD_OWNER.PULL_ORD1_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PULL_ORD1_V
(
   PN,
   FINISH_DATE,
   START_DATE,
   ACTION_TAKEN
)
   BEQUEATH DEFINER
AS
   SELECT SUBSTR (i.part, 1, 20)                                "PN",
          TO_CHAR (Completed_docdate, 'MM/DD/YYYY HH:MI:SS AM') "FINISH DATE",
          TO_CHAR (created_docdate, 'MM/DD/YYYY HH:MI:SS AM')   "START DATE",
          action_taken
             "ACTION TAKEN"
     FROM cat1 C, ord1 I
    WHERE     c.source_code = 'F77'
          AND C.PART = I.PART
          AND Action_taken IN
                 (SELECT list_value
                    FROM amd_lists
                   WHERE     list_name = 'PULL_ORD1'
                         AND action_code <> amd_defaults.getDELETE_ACTION)
          AND ORDER_TYPE = 'J';


DROP VIEW AMD_OWNER.RSP_ALL_ITEM_INV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ALL_ITEM_INV_V
(
   PART_NO,
   LOC_SID,
   INV_QTY,
   RSP_LEVEL
)
   BEQUEATH DEFINER
AS
     SELECT asp.part_no                                              part_no,
            DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid) loc_sid,
            SUM (invQ.inv_qty)                                       inv_qty,
            SUM (invQ.standard_level)
               rsp_level
       FROM (SELECT part_no,
                    loc_id,
                    inv_date,
                    inv_type,
                    inv_qty,
                    standard_level
               FROM rsp_item_inv_v
             UNION ALL
             SELECT part_no,
                    loc_id,
                    inv_date,
                    inv_type,
                    inv_qty,
                    standard_level
               FROM RSP_ITEMSA_INV_V) invQ,
            AMD_SPARE_NETWORKS asn,
            AMD_SPARE_PARTS  asp,
            AMD_SPARE_NETWORKS asnLink
      WHERE     asp.part_no = invQ.part_no
            AND asn.loc_id = invQ.loc_id
            AND asn.loc_type = 'KIT'
            AND asp.action_code != 'D'
            AND asn.mob = asnLink.loc_id(+)
   GROUP BY asp.part_no,
            DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
            invQ.inv_date
     HAVING SUM (invQ.inv_qty) > 0 OR SUM (invQ.standard_level) > 0;


DROP VIEW AMD_OWNER.RSP_INV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_INV_V
(
   PART_NO,
   LOC_SID,
   RSP_INV,
   RSP_LEVEL
)
   BEQUEATH DEFINER
AS
   SELECT ri.part_no,
          ri.loc_sid,
          ri.rsp_inv,
          w.rsp_level rsp_level
     FROM rsp_ramp_item_v ri, rsp_whse_inv_v w
    WHERE     ri.part_no = w.part_no
          AND ri.loc_sid = w.loc_sid
          AND ri.rsp_inv > 0
   UNION
   SELECT ri.part_no,
          ri.loc_sid,
          ri.rsp_inv,
          ri.rsp_level rsp_level
     FROM rsp_ramp_item_v ri
    WHERE     NOT EXISTS
                 (SELECT NULL
                    FROM rsp_whse_inv_v
                   WHERE part_no = ri.part_no AND loc_sid = ri.loc_sid)
          AND ri.rsp_inv > 0
   UNION
   SELECT part_no,
          loc_sid,
          0 rsp_inv,
          rsp_level
     FROM rsp_whse_inv_v w
    WHERE NOT EXISTS
             (SELECT NULL
                FROM rsp_ramp_item_v
               WHERE part_no = w.part_no AND loc_sid = w.loc_sid);


DROP VIEW AMD_OWNER.RSP_ITEMSA_INV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ITEMSA_INV_V
(
   PART_NO,
   LOC_ID,
   INV_DATE,
   INV_TYPE,
   INV_QTY,
   STANDARD_LEVEL
)
   BEQUEATH DEFINER
AS
     SELECT part                          part_no,
            DECODE (i.sc,  'C17PCAG', 'EY1746',  'SATCAA0001C17G', 'EY1746')
               loc_id,
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime))
               inv_date,
            '1'                           inv_type,
            SUM (NVL (i.qty, 0))          inv_qty,
            SUM (NVL (i.standard_level, 0)) standard_level
       FROM ITEMSA i
      WHERE     i.status_3 != 'I'
            AND i.status_servicable = 'Y'
            AND i.status_new_order = 'N'
            AND i.status_accountable = 'Y'
            AND i.status_active = 'Y'
            AND i.status_mai = 'N'
            AND i.condition != 'B170-ATL'
            AND NOT EXISTS
                   (SELECT 1
                      FROM ITEMSA ii
                     WHERE     ii.status_avail = 'N'
                           AND NVL (ii.receipt_order_no, '-1') = '-1'
                           AND ii.item_id = i.item_id)
   GROUP BY part,
            DECODE (i.sc,  'C17PCAG', 'EY1746',  'SATCAA0001C17G', 'EY1746'),
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime));


DROP VIEW AMD_OWNER.RSP_ITEM_INV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ITEM_INV_V
(
   PART_NO,
   LOC_ID,
   INV_DATE,
   INV_TYPE,
   INV_QTY,
   STANDARD_LEVEL
)
   BEQUEATH DEFINER
AS
     SELECT part                          part_no,
            SUBSTR (i.sc, 8, 6)           loc_id,
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime))
               inv_date,
            '1'                           inv_type,
            SUM (NVL (i.qty, 0))          inv_qty,
            SUM (NVL (I.STANDARD_LEVEL, 0)) standard_level
       FROM ITEM i
      WHERE     i.status_3 != 'I'
            AND SUBSTR (i.sc, 1, 3) = 'C17'
            AND SUBSTR (i.sc, LENGTH (i.sc), 1) IN ('G')
            AND i.status_servicable = 'Y'
            AND i.status_new_order = 'N'
            AND i.status_accountable = 'Y'
            AND i.status_active = 'Y'
            AND i.status_mai = 'N'
            AND i.condition != 'B170-ATL'
            AND NOT EXISTS
                   (SELECT 1
                      FROM ITEM ii
                     WHERE     ii.status_avail = 'N'
                           AND NVL (ii.receipt_order_no, '-1') = '-1'
                           AND ii.item_id = i.item_id)
   GROUP BY part,
            SUBSTR (i.sc, 8, 6),
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime));


DROP VIEW AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V
(
   NSN,
   SRAN,
   RSP_ON_HAND,
   RSP_OBJECTIVE
)
   BEQUEATH DEFINER
AS
     SELECT nsn,
            NVL (NEW_VALUE, asn.loc_id) sran,
            SUM (rsp_inv)             rsp_on_hand,
            SUM (rsp_level)           rsp_objective
       FROM amd_rsp                r,
            amd_spare_networks     asn,
            amd_national_stock_items ansi,
            amd_substitutions      subs
      WHERE     r.action_code != 'D'
            AND R.PART_NO = ANSI.PRIME_PART_NO
            AND ANSI.ACTION_CODE != 'D'
            AND r.loc_sid = asn.loc_sid
            AND subs.substitution_name(+) = 'RSP_On_Hand_and_Objective'
            AND subs.substitution_type(+) = 'SRAN'
            AND subs.original_value(+) = loc_id
            AND subs.action_code(+) <> 'D'
   GROUP BY ansi.nsn, NVL (NEW_VALUE, asn.loc_id)
     HAVING SUM (rsp_inv) > 0;


DROP VIEW AMD_OWNER.RSP_RAMP_INV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_RAMP_INV_V
(
   PART_NO,
   LOC_SID,
   RSP_INV,
   RSP_LEVEL
)
   BEQUEATH DEFINER
AS
   SELECT asp.part_no                                         part_no,
          DECODE (n.loc_type, 'TMP', asn2.loc_sid, n.loc_sid) loc_sid,
            NVL (r.spram_balance, 0)
          + NVL (r.hpmsk_balance, 0)
          + NVL (r.wrm_balance, 0)
             rsp_inv,
            NVL (r.spram_level, 0)
          + NVL (r.wrm_level, 0)
          + NVL (r.hpmsk_level_qty, 0)
             rsp_level
     FROM RAMP               r,
          (SELECT asp.part_no,
                  amd_utils.formatNsn (asp.nsn, 'GOLD') dashed_nsn
             FROM AMD_SPARE_PARTS          asp,
                  AMD_NATIONAL_STOCK_ITEMS ansi,
                  AMD_NSI_PARTS            anp
            WHERE     icp_ind = amd_defaults.getIcpInd
                  AND asp.part_no = anp.part_no
                  AND anp.prime_ind = 'Y'
                  AND UNASSIGNMENT_DATE IS NULL
                  AND asp.nsn = ansi.nsn
                  AND asp.action_code != 'D') asp,
          AMD_SPARE_NETWORKS n,
          AMD_SPARE_NETWORKS asn2
    WHERE     R.CURRENT_STOCK_NUMBER = asp.dashed_nsn
          AND n.loc_id = SUBSTR (r.sc(+), 8, 6)
          AND n.loc_type IN ('MOB',
                             'FSL',
                             'UAB',
                             'KIT')
          AND SUBSTR (r.sc, 8, 2) LIKE 'FB%'
          AND n.mob = asn2.loc_id(+)
          AND (     NVL (r.spram_balance, 0)
                  + NVL (r.hpmsk_balance, 0)
                  + NVL (r.wrm_balance, 0) > 0
               OR   NVL (r.spram_level, 0)
                  + NVL (r.wrm_level, 0)
                  + NVL (r.hpmsk_level_qty, 0) > 0);


DROP VIEW AMD_OWNER.RSP_RAMP_ITEM_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_RAMP_ITEM_V
(
   PART_NO,
   LOC_SID,
   RSP_INV,
   RSP_LEVEL
)
   BEQUEATH DEFINER
AS
   SELECT part_no, loc_sid, rsp_inv, rsp_level FROM rsp_ramp_inv_v
   UNION ALL
   SELECT part_no,
          loc_sid,
          inv_qty,
          rsp_level
     FROM (  SELECT part_no,
                    loc_sid,
                    SUM (inv_qty) inv_qty,
                    SUM (rsp_level) rsp_level
               FROM rsp_all_item_inv_v
           GROUP BY part_no, loc_sid)
   ORDER BY part_no, loc_sid;


DROP VIEW AMD_OWNER.RSP_WHSE_INV_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_WHSE_INV_V
(
   PART_NO,
   LOC_SID,
   RSP_LEVEL
)
   BEQUEATH DEFINER
AS
     SELECT w.part                   part_no,
            ntwks.loc_sid            loc_sid,
            SUM (NVL (stock_level, 0)) rsp_level
       FROM whse w, active_parts_v a, amd_spare_networks ntwks
      WHERE     w.part = a.part_no
            AND SUBSTR (sc, 8, 6) = ntwks.loc_id
            AND SUBSTR (sc, 8, 3) = 'KIT'
   GROUP BY w.part, ntwks.loc_sid
   ORDER BY part, loc_sid;


DROP VIEW AMD_OWNER.SLIC_HA_SHELF_LIFE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HA_SHELF_LIFE_V
(
   PART_NO,
   MFGR,
   SMR_CODE,
   SHELF_LIFE,
   STORAGE_DAYS,
   UNIT_VOLUME
)
   BEQUEATH DEFINER
AS
   SELECT smr.part_no                             pa0rt_no,
          smr.mfgr,
          smr.smr_code,
          shlifeha                                shelf_life,
          storage_days,
          (ulengtha * uwidthha * uheighha) / 1728 unit_volume
     FROM pslms_ha@amd_pslms_link.boeingdb ha,
          amd_shelf_life_codes             sl,
          amd_owner.slic_hg_smr_codes_v    smr
    WHERE     ha.refnumha = smr.part_no
          AND ha.cagecdxh = smr.mfgr
          AND shlifeha = sl.sl_code(+);


DROP VIEW AMD_OWNER.SLIC_HA_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HA_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   REFNUMHA,
   ITNAMEHA,
   INAMECHA,
   REFNCCHA,
   REFNVCHA,
   DLSCRCHA,
   DOCIDCHA,
   ITMMGCHA,
   COGNSNHA,
   SMMNSNHA,
   MATNSNHA,
   FSCNSNHA,
   NIINSNHA,
   ACTNSNHA,
   UICONVHA,
   SHLIFEHA,
   SLACTNHA,
   PPSLSTHA,
   DOCAVCHA,
   PRDLDTHA,
   SPMACCHA,
   SMAINCHA,
   CRITCDHA,
   PMICODHA,
   SAIPCDHA,
   AAPLCCHA,
   BBPLCCHA,
   CCPLCCHA,
   DDPLCCHA,
   EEPLCCHA,
   FFPLCCHA,
   GGPLCCHA,
   HHPLCCHA,
   JJPLCCHA,
   KKPLCCHA,
   LLPLCCHA,
   MMPLCCHA,
   PHYSECHA,
   ADPEQPHA,
   DEMILIHA,
   ACQMETHA,
   AMSUFCHA,
   HMSCOSHA,
   HWDCOSHA,
   HWSCOSHA,
   CTICODHA,
   UWEIGHHA,
   ULENGTHA,
   UWIDTHHA,
   UHEIGHHA,
   HAZCODHA,
   UNITMSHA,
   UNITISHA,
   LINNUMHA,
   CRITITHA,
   INDMATHA,
   MTLEADHA,
   MTLWGTHA,
   MATERLHA,
   SCHEDULE_B_EXPORT_CODE_TYPE,
   EXT_PART_ID
)
   BEQUEATH DEFINER
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "CAGECDXH",
          "REFNUMHA",
          "ITNAMEHA",
          "INAMECHA",
          "REFNCCHA",
          "REFNVCHA",
          "DLSCRCHA",
          "DOCIDCHA",
          "ITMMGCHA",
          "COGNSNHA",
          "SMMNSNHA",
          "MATNSNHA",
          "FSCNSNHA",
          "NIINSNHA",
          "ACTNSNHA",
          "UICONVHA",
          "SHLIFEHA",
          "SLACTNHA",
          "PPSLSTHA",
          "DOCAVCHA",
          "PRDLDTHA",
          "SPMACCHA",
          "SMAINCHA",
          "CRITCDHA",
          "PMICODHA",
          "SAIPCDHA",
          "AAPLCCHA",
          "BBPLCCHA",
          "CCPLCCHA",
          "DDPLCCHA",
          "EEPLCCHA",
          "FFPLCCHA",
          "GGPLCCHA",
          "HHPLCCHA",
          "JJPLCCHA",
          "KKPLCCHA",
          "LLPLCCHA",
          "MMPLCCHA",
          "PHYSECHA",
          "ADPEQPHA",
          "DEMILIHA",
          "ACQMETHA",
          "AMSUFCHA",
          "HMSCOSHA",
          "HWDCOSHA",
          "HWSCOSHA",
          "CTICODHA",
          "UWEIGHHA",
          "ULENGTHA",
          "UWIDTHHA",
          "UHEIGHHA",
          "HAZCODHA",
          "UNITMSHA",
          "UNITISHA",
          "LINNUMHA",
          "CRITITHA",
          "INDMATHA",
          "MTLEADHA",
          "MTLWGTHA",
          "MATERLHA",
          "SCHEDULE_B_EXPORT_CODE_TYPE",
          "EXT_PART_ID"
     FROM PSLMS_HA@AMD_PSLMS_LINK.BOEINGDB;


DROP VIEW AMD_OWNER.SLIC_HB_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HB_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDHB,
   REFNUMHB,
   ADCAGEHB,
   ADDREFHB,
   ADRNCCHB,
   ADRNVCHB
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          CAGECDHB,
          REFNUMHB,
          ADCAGEHB,
          ADDREFHB,
          ADRNCCHB,
          ADRNVCHB
     FROM PSLMS_HB@AMD_PSLMS_LINK.BOEINGDB;


DROP VIEW AMD_OWNER.SLIC_HD_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HD_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   REFNUMHA,
   UIPRICHD,
   LOTQFMHD,
   LOTQTOHD,
   CURPRCHD,
   TUIPRCHD,
   PROUIPHD,
   FISCYRHD
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          CAGECDXH,
          REFNUMHA,
          UIPRICHD,
          LOTQFMHD,
          LOTQTOHD,
          CURPRCHD,
          TUIPRCHD,
          PROUIPHD,
          FISCYRHD
     FROM PSLMS_HD@AMD_PSLMS_LINK.BOEINGDB;


DROP VIEW AMD_OWNER.SLIC_HF_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HF_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   REFNUMHA,
   DEGPROHF,
   UNICONHF,
   UCLEVLHF,
   PKGCODHF,
   PACCATHF,
   MEPRESHF,
   CDPROCHF,
   PRSMATHF,
   WRAPMTHF,
   CUSHMAHF,
   CUSTHIHF,
   QTYUPKHF,
   INTCONHF,
   INCQTYHF,
   SPEMRKHF,
   UNPKWTHF,
   LENUPKHF,
   WIDUPKHF,
   DEPUPKHF,
   UNPKCUHF,
   OPTPRIHF,
   SPINUMHF,
   SPIREVHF,
   SPDATEHF,
   CONNSNHF,
   SUPPKDHF,
   PKCAGEHF
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          CAGECDXH,
          REFNUMHA,
          DEGPROHF,
          UNICONHF,
          UCLEVLHF,
          PKGCODHF,
          PACCATHF,
          MEPRESHF,
          CDPROCHF,
          PRSMATHF,
          WRAPMTHF,
          CUSHMAHF,
          CUSTHIHF,
          QTYUPKHF,
          INTCONHF,
          INCQTYHF,
          SPEMRKHF,
          UNPKWTHF,
          LENUPKHF,
          WIDUPKHF,
          DEPUPKHF,
          UNPKCUHF,
          OPTPRIHF,
          SPINUMHF,
          SPIREVHF,
          SPDATEHF,
          CONNSNHF,
          SUPPKDHF,
          PKCAGEHF
     FROM PSLMS_Hf@AMD_PSLMS_LINK.BOEINGDB;


DROP VIEW AMD_OWNER.SLIC_HG_SMR_CODES_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HG_SMR_CODES_V
(
   PART_NO,
   MFGR,
   SMR_CODE
)
   BEQUEATH DEFINER
AS
   SELECT refnumha part_no, cagecdxh mfgr, smrcodhg smr_code
     FROM (  SELECT cagecdxh,
                    refnumha,
                    smrcodhg,
                    ROW_NUMBER ()
                    OVER (
                       PARTITION BY cagecdxh, refnumha
                       ORDER BY
                          COUNT (smrcodhg) + LENGTH (TRIM (smrcodhg)) DESC,
                          smrcodhg DESC)
                       rnk
               FROM pslms_hg@amd_pslms_link.boeingdb
              WHERE smrcodhg <> '  '
           GROUP BY cagecdxh, refnumha, smrcodhg)
    WHERE rnk = 1;


DROP VIEW AMD_OWNER.SLIC_HG_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HG_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   REFNUMHA,
   EIACODXA,
   LSACONXB,
   ALTLCNXB,
   LCNTYPXB,
   PLISNOHG,
   QTYASYHG,
   SUPINDHG,
   DATASCHG,
   PROSICHG,
   LLIPTDHG,
   PPLPTDHG,
   SFPPTDHG,
   CBLPTDHG,
   RILPTDHG,
   ISLPTDHG,
   PCLPTDHG,
   TTLPTDHG,
   SCPPTDHG,
   ARAPTDHG,
   ARBPTDHG,
   TOCCODHG,
   INDCODHG,
   QTYPEIHG,
   PIPLISHG,
   SAPLISHG,
   HARDCIHG,
   REMIPIHG,
   LRUNITHG,
   ITMCATHG,
   ESSCODHG,
   SMRCODHG,
   MRRONEHG,
   MRRTWOHG,
   MRRMODHG,
   ORTDOOHG,
   FRTDFFHG,
   HRTDHHHG,
   LRTDLLHG,
   DRTDDDHG,
   MINREUHG,
   MAOTIMHG,
   MAIACTHG,
   RISSBUHG,
   RMSSLIHG,
   RTLLQTHG,
   TOTQTYHG,
   OMTDOOHG,
   FMTDFFHG,
   HMTDHHHG,
   LMTDLLHG,
   DMTDDDHG,
   CBDMTDHG,
   CADMTDHG,
   ORCTOOHG,
   FRCTFFHG,
   HRCTHHHG,
   LRCTLLHG,
   DRCTDDHG,
   CONRCTHG,
   NORETSHG,
   REPSURHG,
   DRPONEHG,
   DRPTWOHG,
   WRKUCDHG,
   ALLOWCHG,
   ALIQTYHG,
   IDENTIFICATION_NUMBER_HG,
   PCCNUMXC,
   EXT_PARTAPPL_ID
)
   BEQUEATH DEFINER
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "CAGECDXH",
          TRIM (REFNUMHA),
          "EIACODXA",
          TRIM (LSACONXB),
          "ALTLCNXB",
          "LCNTYPXB",
          TRIM (PLISNOHG),
          TO_NUMBER (TRIM (QTYASYHG)),
          "SUPINDHG",
          "DATASCHG",
          "PROSICHG",
          "LLIPTDHG",
          "PPLPTDHG",
          "SFPPTDHG",
          "CBLPTDHG",
          "RILPTDHG",
          "ISLPTDHG",
          "PCLPTDHG",
          "TTLPTDHG",
          "SCPPTDHG",
          "ARAPTDHG",
          "ARBPTDHG",
          TRIM (TOCCODHG),
          TRIM (INDCODHG),
          "QTYPEIHG",
          "PIPLISHG",
          "SAPLISHG",
          "HARDCIHG",
          "REMIPIHG",
          "LRUNITHG",
          "ITMCATHG",
          "ESSCODHG",
          TRIM (SMRCODHG),
          "MRRONEHG",
          "MRRTWOHG",
          "MRRMODHG",
          "ORTDOOHG",
          "FRTDFFHG",
          "HRTDHHHG",
          "LRTDLLHG",
          "DRTDDDHG",
          "MINREUHG",
          "MAOTIMHG",
          "MAIACTHG",
          "RISSBUHG",
          "RMSSLIHG",
          "RTLLQTHG",
          "TOTQTYHG",
          "OMTDOOHG",
          "FMTDFFHG",
          "HMTDHHHG",
          "LMTDLLHG",
          "DMTDDDHG",
          "CBDMTDHG",
          "CADMTDHG",
          "ORCTOOHG",
          "FRCTFFHG",
          "HRCTHHHG",
          "LRCTLLHG",
          "DRCTDDHG",
          "CONRCTHG",
          "NORETSHG",
          "REPSURHG",
          "DRPONEHG",
          "DRPTWOHG",
          TRIM (WRKUCDHG),
          "ALLOWCHG",
          "ALIQTYHG",
          "IDENTIFICATION_NUMBER_HG",
          TRIM (PCCNUMXC),
          "EXT_PARTAPPL_ID"
     FROM pslms_hg@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.SLIC_XA_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_XA_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LCNSTRXA,
   ADDLTMXA,
   CTDLTMXA,
   CONTNOXA,
   CSREORXA,
   CSPRRQXA,
   DEMILCXA,
   DISCNTXA,
   ESSALVXA,
   HLCSPCXA,
   INTBINXA,
   INCATCXA,
   INTRATXA,
   INVSTGXA,
   LODFACXA,
   WSOPLVXA,
   OPRLIFXA,
   PRSTOVXA,
   PRSTOMXA,
   PROFACXA,
   RCBINCXA,
   RCCATCXA,
   RESTCRXA,
   SAFLVLXA,
   SECSFCXA,
   TRNCSTXA,
   WSTYAQXA,
   TSSCODXA,
   EXT_EIAC_ID
)
   BEQUEATH DEFINER
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "EIACODXA",
          "LCNSTRXA",
          "ADDLTMXA",
          "CTDLTMXA",
          "CONTNOXA",
          "CSREORXA",
          "CSPRRQXA",
          "DEMILCXA",
          "DISCNTXA",
          "ESSALVXA",
          "HLCSPCXA",
          "INTBINXA",
          "INCATCXA",
          "INTRATXA",
          "INVSTGXA",
          "LODFACXA",
          "WSOPLVXA",
          "OPRLIFXA",
          "PRSTOVXA",
          "PRSTOMXA",
          "PROFACXA",
          "RCBINCXA",
          "RCCATCXA",
          "RESTCRXA",
          "SAFLVLXA",
          "SECSFCXA",
          "TRNCSTXA",
          "WSTYAQXA",
          "TSSCODXA",
          "EXT_EIAC_ID"
     FROM pslms_xa@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.SLIC_XB_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_XB_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LSACONXB,
   ALTLCNXB,
   LCNTYPXB,
   LCNINDXB,
   LCNAMEXB,
   TMFGCDXB,
   SYSIDNXB,
   SECITMXB,
   RAMINDXB,
   DOCUMENT_CODE_XB,
   WORK_AREA_CODE_ZONE_XB,
   EXT_LCN_ID
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          TRIM (UPDTCD),
          TRIM (EIACODXA),
          TRIM (LSACONXB),
          ALTLCNXB,
          LCNTYPXB,
          TRIM (LCNINDXB),
          TRIM (LCNAMEXB),
          TRIM (TMFGCDXB),
          TRIM (SYSIDNXB),
          TRIM (SECITMXB),
          TRIM (RAMINDXB),
          TRIM (DOCUMENT_CODE_XB),
          TRIM (WORK_AREA_CODE_ZONE_XB),
          EXT_LCN_ID
     FROM pslms_xb@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.SLIC_XC_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_XC_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LSACONXB,
   ALTLCNXB,
   LCNTYPXB,
   UOCSEIXC,
   PCCNUMXC,
   ITMDESXC,
   PLISNOXC,
   TOCCODXC,
   QTYASYXC,
   QTYPEIXC,
   TRASEIXC,
   QTY_PER_EI_CALC_OPT_CODE
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          EIACODXA,
          LSACONXB,
          ALTLCNXB,
          LCNTYPXB,
          UOCSEIXC,
          PCCNUMXC,
          ITMDESXC,
          PLISNOXC,
          TOCCODXC,
          QTYASYXC,
          QTYPEIXC,
          TRASEIXC,
          QTY_PER_EI_CALC_OPT_CODE
     FROM pslms_xc@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.SLIC_XH_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_XH_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   CAGECDXH,
   CANAMEXH,
   CASTREXH,
   CACITYXH,
   CASTATXH,
   CANATNXH,
   CAPOZOXH
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          CAGECDXH,
          CANAMEXH,
          CASTREXH,
          CACITYXH,
          CASTATXH,
          CANATNXH,
          CAPOZOXH
     FROM PSLMS_XH@AMD_PSLMS_LINK.BOEINGDB;


DROP VIEW AMD_OWNER.SLIC_XI_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_XI_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   TMCODEXI,
   TMNUMBXI
)
   BEQUEATH DEFINER
AS
   SELECT DBKEY,
          UPDTCNT,
          BCKP,
          CAN_INT,
          UPDTCD,
          TMCODEXI,
          TMNUMBXI
     FROM pslms_xi@amd_pslms_link.boeingdb;


DROP VIEW AMD_OWNER.SPO_BACKORDER_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_BACKORDER_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          "LAST_MODIFIED"
     FROM spoc17v2.v_backorder_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_BOM_DETAIL_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_BOM_DETAIL_V
(
   PART,
   INCLUDED_PART,
   BOM,
   QUANTITY,
   BEGIN_DATE,
   END_DATE,
   PARENT_INCLUDED_PART,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT part,
          included_part,
          bom,
          quantity,
          begin_date,
          end_date,
          parent_included_part,
          last_modified
     FROM spoc17v2.v_bom_detail@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V
(
   LOCATION,
   BOM,
   CONTRACT_TYPE,
   CUSTOMER_LOCATION,
   BEGIN_DATE,
   END_DATE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT location,
          bom,
          contract_type,
          customer_location,
          begin_date,
          end_date,
          quantity,
          last_modified
     FROM spoc17v2.v_bom_location_contract@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_CAUSAL_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_CAUSAL_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_causal_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V
(
   CONFIRMED_REQUEST,
   LINE,
   LOCATION,
   PART,
   PROPOSED_REQUEST,
   REQUEST_DATE,
   DUE_DATE,
   QUANTITY_ORDERED,
   QUANTITY_RECEIVED,
   REQUEST_STATUS,
   SUPPLIER_LOCATION,
   LAST_MODIFIED,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8
)
   BEQUEATH DEFINER
AS
   SELECT confirmed_request,
          line,
          location,
          part,
          proposed_request,
          request_date,
          due_date,
          quantity_ordered,
          quantity_received,
          request_status,
          supplier_location,
          last_modified,
          attribute_1,
          attribute_2,
          attribute_3,
          attribute_4,
          attribute_5,
          attribute_6,
          attribute_7,
          attribute_8
     FROM spoc17v2.v_confirmed_request_line@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_V
(
   ID,
   NAME,
   REQUEST_TYPE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT id,
          name,
          request_type,
          last_modified
     FROM spoc17v2.v_confirmed_request@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_CONTRACT_CAUSAL_FORECAST_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_CONTRACT_CAUSAL_FORECAST_V
(
   LOCATION,
   CONTRACT,
   CONTRACT_TYPE,
   CAUSAL_TYPE,
   PERIOD,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "CONTRACT",
          "CONTRACT_TYPE",
          "CAUSAL_TYPE",
          "PERIOD",
          "QUANTITY",
          last_modified
     FROM spoc17v2.v_contract_causal_forecast@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_CONTRACT_CAUSAL_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_CONTRACT_CAUSAL_V
(
   LOCATION,
   CONTRACT,
   CONTRACT_TYPE,
   CAUSAL_TYPE,
   PERIOD,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "CONTRACT",
          "CONTRACT_TYPE",
          "CAUSAL_TYPE",
          "PERIOD",
          "QUANTITY",
          last_modified
     FROM spoc17v2.v_contract_causal@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_CURRENT_PERIOD_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_CURRENT_PERIOD_V
(
   ID,
   BEGIN_DATE,
   END_DATE,
   YEAR_NUMBER,
   MONTH_NUMBER,
   WEEK_NUMBER,
   CALENDAR_YEAR_NUMBER,
   CALENDAR_MONTH_NUMBER
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "BEGIN_DATE",
          "END_DATE",
          "YEAR_NUMBER",
          "MONTH_NUMBER",
          "WEEK_NUMBER",
          "CALENDAR_YEAR_NUMBER",
          "CALENDAR_MONTH_NUMBER"
     FROM spoc17v2.v_current_period@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_DEMAND_FORECAST_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_DEMAND_FORECAST_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          "LAST_MODIFIED"
     FROM spoc17v2.v_demand_forecast_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_DEMAND_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_DEMAND_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_demand_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_EXCEPTION_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_EXCEPTION_V
(
   ID,
   EXCEPTION_TYPE,
   CLASS,
   MESSAGE
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "EXCEPTION_TYPE",
          "CLASS",
          "MESSAGE"
     FROM spoc17v2.v_exception@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_FLAG_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_FLAG_V
(
   NAME,
   DESCRIPTION,
   FLAG_TYPE,
   VALUE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "NAME",
          "DESCRIPTION",
          "FLAG_TYPE",
          "VALUE",
          last_modified
     FROM spoc17v2.v_flag@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V
(
   LOCATION,
   PART,
   DEMAND_FORECAST_TYPE,
   PERIOD,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "PART",
          "DEMAND_FORECAST_TYPE",
          "PERIOD",
          "QUANTITY",
          last_modified
     FROM spoc17v2.v_fx_lp_demand_forecast@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_INTERFACE_BATCH_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_INTERFACE_BATCH_V
(
   INTERFACE,
   BATCH,
   BATCH_MODE,
   BEGIN_DATE,
   LAST_DATE,
   END_DATE,
   PROCESSED_RECORDS,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "INTERFACE",
          "BATCH",
          "BATCH_MODE",
          "BEGIN_DATE",
          "LAST_DATE",
          "END_DATE",
          "PROCESSED_RECORDS",
          last_modified
     FROM spoc17v2.v_interface_batch@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_IN_TRANSIT_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_IN_TRANSIT_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_in_transit_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LOCATION_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LOCATION_V
(
   ID,
   NAME,
   LOCATION_TYPE,
   DESCRIPTION,
   IS_DGI_LOCATION,
   MAX_PART_UNIT_WEIGHT,
   MAX_PART_UNIT_VOLUME,
   LAST_MODIFIED,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "LOCATION_TYPE",
          "DESCRIPTION",
          "IS_DGI_LOCATION",
          "MAX_PART_UNIT_WEIGHT",
          "MAX_PART_UNIT_VOLUME",
          last_modified,
          "ATTRIBUTE_1",
          "ATTRIBUTE_2",
          "ATTRIBUTE_3",
          "ATTRIBUTE_4",
          "ATTRIBUTE_5",
          "ATTRIBUTE_6",
          "ATTRIBUTE_7",
          "ATTRIBUTE_8"
     FROM spoc17v2.v_location@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_ATTRIBUTE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_ATTRIBUTE_V
(
   LOCATION,
   PART,
   CONDEMNATION_RATE,
   PASSUP_RATE,
   CRITICALITY,
   VARIANCE_TO_MEAN_RATIO,
   DEMAND_FORECAST_TYPE,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   ATTRIBUTE_9,
   ATTRIBUTE_10,
   ATTRIBUTE_11,
   ATTRIBUTE_12,
   ATTRIBUTE_13,
   ATTRIBUTE_14,
   ATTRIBUTE_15,
   ATTRIBUTE_16,
   ATTRIBUTE_17,
   ATTRIBUTE_18,
   ATTRIBUTE_19,
   ATTRIBUTE_20,
   ATTRIBUTE_21,
   ATTRIBUTE_22,
   ATTRIBUTE_23,
   ATTRIBUTE_24,
   ATTRIBUTE_25,
   ATTRIBUTE_26,
   ATTRIBUTE_27,
   ATTRIBUTE_28,
   ATTRIBUTE_29,
   ATTRIBUTE_30,
   ATTRIBUTE_31,
   ATTRIBUTE_32,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "PART",
          "CONDEMNATION_RATE",
          "PASSUP_RATE",
          "CRITICALITY",
          "VARIANCE_TO_MEAN_RATIO",
          "DEMAND_FORECAST_TYPE",
          "ATTRIBUTE_1",
          "ATTRIBUTE_2",
          "ATTRIBUTE_3",
          "ATTRIBUTE_4",
          "ATTRIBUTE_5",
          "ATTRIBUTE_6",
          "ATTRIBUTE_7",
          "ATTRIBUTE_8",
          "ATTRIBUTE_9",
          "ATTRIBUTE_10",
          "ATTRIBUTE_11",
          "ATTRIBUTE_12",
          "ATTRIBUTE_13",
          "ATTRIBUTE_14",
          "ATTRIBUTE_15",
          "ATTRIBUTE_16",
          "ATTRIBUTE_17",
          "ATTRIBUTE_18",
          "ATTRIBUTE_19",
          "ATTRIBUTE_20",
          "ATTRIBUTE_21",
          "ATTRIBUTE_22",
          "ATTRIBUTE_23",
          "ATTRIBUTE_24",
          "ATTRIBUTE_25",
          "ATTRIBUTE_26",
          "ATTRIBUTE_27",
          "ATTRIBUTE_28",
          "ATTRIBUTE_29",
          "ATTRIBUTE_30",
          "ATTRIBUTE_31",
          "ATTRIBUTE_32",
          last_modified
     FROM spoc17v2.v_lp_attribute@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_BACKORDER_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_BACKORDER_V
(
   LOCATION,
   PART,
   BACKORDER_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT location,
          part,
          backorder_type,
          quantity,
          last_modified
     FROM spoc17v2.v_lp_backorder@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_DEMAND_FORECAST_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_DEMAND_FORECAST_V
(
   LOCATION,
   PART,
   DEMAND_FORECAST_TYPE,
   PERIOD,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "PART",
          "DEMAND_FORECAST_TYPE",
          "PERIOD",
          "QUANTITY",
          last_modified
     FROM spoc17v2.v_lp_demand_forecast@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_DEMAND_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_DEMAND_V
(
   TRANSACTION_ID,
   LOCATION,
   PART,
   CONTRACT,
   DEMAND_TYPE,
   DEMAND_DATE,
   CUSTOMER_LOCATION,
   PRODUCT_SERIAL_NUMBER,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "TRANSACTION_ID",
          "LOCATION",
          "PART",
          "CONTRACT",
          "DEMAND_TYPE",
          "DEMAND_DATE",
          "CUSTOMER_LOCATION",
          "PRODUCT_SERIAL_NUMBER",
          "QUANTITY",
          last_modified
     FROM spoc17v2.v_lp_demand@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_IN_TRANSIT_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_IN_TRANSIT_V
(
   LOCATION,
   PART,
   IN_TRANSIT_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "PART",
          "IN_TRANSIT_TYPE",
          "QUANTITY",
          last_modified
     FROM spoc17v2.v_lp_in_transit@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_ON_HAND_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_ON_HAND_V
(
   LOCATION,
   PART,
   ON_HAND_TYPE,
   LAST_MODIFIED,
   QUANTITY
)
   BEQUEATH DEFINER
AS
   SELECT "LOCATION",
          "PART",
          "ON_HAND_TYPE",
          last_modified,
          "QUANTITY"
     FROM spoc17v2.v_lp_on_hand@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_LP_OVERRIDE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_LP_OVERRIDE_V
(
   PART,
   LOCATION,
   OVERRIDE_TYPE,
   QUANTITY,
   OVERRIDE_REASON,
   OVERRIDE_USER,
   BEGIN_DATE,
   END_DATE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
     SELECT "PART",
            "LOCATION",
            "OVERRIDE_TYPE",
            "QUANTITY",
            "OVERRIDE_REASON",
            "OVERRIDE_USER",
            "BEGIN_DATE",
            "END_DATE",
            last_modified
       FROM spoc17v2.v_lp_override@stl_escm_link
   ORDER BY location, part, override_type;


DROP VIEW AMD_OWNER.SPO_MTBF_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_MTBF_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_mtbf_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_ON_HAND_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_ON_HAND_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_on_hand_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION
)
   BEQUEATH DEFINER
AS
   SELECT "ID", "NAME", "DESCRIPTION"
     FROM spoc17v2.v_override_reason_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_OVERRIDE_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_OVERRIDE_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_override_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PARAMETER_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PARAMETER_V
(
   NAME,
   DESCRIPTION,
   PARAMETER_TYPE,
   VALUE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "NAME",
          "DESCRIPTION",
          "PARAMETER_TYPE",
          "VALUE",
          last_modified
     FROM spoc17v2.v_parameter@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PART_CAUSAL_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PART_CAUSAL_TYPE_V
(
   PART,
   CAUSAL_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT part,
          causal_type,
          quantity,
          last_modified
     FROM spoc17v2.v_part_causal_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PART_MTBF_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PART_MTBF_V
(
   PART,
   MTBF_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT part,
          mtbf_type,
          quantity,
          last_modified
     FROM spoc17v2.v_part_mtbf@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PART_PLANNED_PART_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PART_PLANNED_PART_V
(
   PART,
   PLANNED_PART,
   SUPERSESSION_TYPE,
   BEGIN_DATE,
   END_DATE,
   LAST_MODIFIED,
   SPO_USER
)
   BEQUEATH DEFINER
AS
   SELECT part,
          planned_part,
          supersession_type,
          begin_date,
          end_date,
          last_modified,
          spo_user
     FROM spoc17v2.v_part_planned_part@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PART_UPGRADED_PART_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PART_UPGRADED_PART_V
(
   PART,
   UPGRADED_PART,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT part, upgraded_part, last_modified
     FROM spoc17v2.v_part_upgraded_part@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PART_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PART_V
(
   ID,
   NAME,
   PART_TYPE,
   DESCRIPTION,
   COST,
   BEGIN_DATE,
   END_DATE,
   HOLDING_COST_RATE,
   FIXED_ORDER_COST,
   IS_ORDER_POLICY_ROQ_BASED,
   IS_REPARABLE,
   REPAIR_COST,
   DECAY_RATE,
   GENERATE_NEW_BUY,
   GENERATE_REPAIR,
   GENERATE_ALLOCATION,
   GENERATE_TRANSSHIPMENT,
   MAX_QTY_ALLOWANCE,
   MAX_TOTAL_TSL,
   LAST_MODIFIED,
   IS_PLANNED,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   ATTRIBUTE_9,
   ATTRIBUTE_10,
   ATTRIBUTE_11,
   ATTRIBUTE_12,
   ATTRIBUTE_13,
   ATTRIBUTE_14,
   ATTRIBUTE_15,
   ATTRIBUTE_16,
   ATTRIBUTE_17,
   ATTRIBUTE_18,
   ATTRIBUTE_19,
   ATTRIBUTE_20,
   ATTRIBUTE_21,
   ATTRIBUTE_22,
   ATTRIBUTE_23,
   ATTRIBUTE_24,
   ATTRIBUTE_25,
   ATTRIBUTE_26,
   ATTRIBUTE_27,
   ATTRIBUTE_28,
   ATTRIBUTE_29,
   ATTRIBUTE_30,
   ATTRIBUTE_31,
   ATTRIBUTE_32,
   MATERIAL_CLASS,
   WEIGHT,
   VOLUME,
   IS_EXEMPT,
   IGNORE_WEIGHT_AND_VOLUME,
   IS_SEASONAL,
   IS_CANNIBALIZABLE,
   PARTIAL_ONE_WAY_SUPERSESSION
)
   BEQUEATH DEFINER
AS
   SELECT v_part.id,
          v_part.name,
          v_part.part_type,
          v_part.description,
          v_part.cost,
          v_part.begin_date,
          v_part.end_date,
          v_part.holding_cost_rate,
          v_part.fixed_order_cost,
          v_part.is_order_policy_roq_based,
          v_part.is_reparable,
          v_part.repair_cost,
          v_part.decay_rate,
          v_part.generate_new_buy,
          v_part.generate_repair,
          v_part.generate_allocation,
          v_part.generate_transshipment,
          v_part.max_qty_allowance,
          v_part.max_total_tsl,
          v_part.last_modified,
          v_part.is_planned,
          v_part.attribute_1,
          v_part.attribute_2,
          v_part.attribute_3,
          v_part.attribute_4,
          v_part.attribute_5,
          v_part.attribute_6,
          v_part.attribute_7,
          v_part.attribute_8,
          v_part.attribute_9,
          v_part.attribute_10,
          v_part.attribute_11,
          v_part.attribute_12,
          v_part.attribute_13,
          v_part.attribute_14,
          v_part.attribute_15,
          v_part.attribute_16,
          v_part.attribute_17,
          v_part.attribute_18,
          v_part.attribute_19,
          v_part.attribute_20,
          v_part.attribute_21,
          v_part.attribute_22,
          v_part.attribute_23,
          v_part.attribute_24,
          v_part.attribute_25,
          v_part.attribute_26,
          v_part.attribute_27,
          v_part.attribute_28,
          v_part.attribute_29,
          v_part.attribute_30,
          v_part.attribute_31,
          v_part.attribute_32,
          v_part.material_class,
          v_part.weight,
          v_part.volume,
          v_part.is_exempt,
          v_part.ignore_weight_and_volume,
          v_part.is_seasonal,
          v_part.is_cannibalizable,
          v_part.partial_one_way_supersession
     FROM spoc17v2.v_part@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_PERIOD_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_PERIOD_V
(
   ID,
   BEGIN_DATE,
   END_DATE,
   YEAR_NUMBER,
   MONTH_NUMBER,
   WEEK_NUMBER,
   CALENDAR_YEAR_NUMBER,
   CALENDAR_MONTH_NUMBER,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "BEGIN_DATE",
          "END_DATE",
          "YEAR_NUMBER",
          "MONTH_NUMBER",
          "WEEK_NUMBER",
          "CALENDAR_YEAR_NUMBER",
          "CALENDAR_MONTH_NUMBER",
          last_modified
     FROM spoc17v2.v_period@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_REQUEST_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_REQUEST_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_request_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_SUPERSESSION_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_SUPERSESSION_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_supersession_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_USER_PART_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_USER_PART_V
(
   SPO_USER,
   PART,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "SPO_USER", "PART", uparts.last_modified last_modified
     FROM spoc17v2.v_user_part@stl_escm_link uparts,
          spoc17v2.v_part@stl_escm_link      parts
    WHERE uparts.part = parts.name AND parts.end_date IS NULL;


DROP VIEW AMD_OWNER.SPO_USER_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_USER_TYPE_V
(
   ID,
   NAME,
   DESCRIPTION,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "ID",
          "NAME",
          "DESCRIPTION",
          last_modified
     FROM spoc17v2.v_user_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_USER_USER_TYPE_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_USER_USER_TYPE_V
(
   SPO_USER,
   USER_TYPE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT "SPO_USER", "USER_TYPE", last_modified
     FROM spoc17v2.v_user_user_type@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_USER_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_USER_V
(
   ID,
   NAME,
   EMAIL_ADDRESS,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT id,
          name,
          email_address,
          attribute_1,
          attribute_2,
          attribute_3,
          attribute_4,
          attribute_5,
          attribute_6,
          attribute_7,
          attribute_8,
          last_modified
     FROM spoc17v2.v_spo_user@stl_escm_link;


DROP VIEW AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V
(
   INTERFACE,
   BATCH,
   BATCH_MODE,
   ACTION,
   EXCEPTION,
   LAST_MODIFIED,
   INTERFACE_SEQUENCE
)
   BEQUEATH DEFINER
AS
   SELECT "INTERFACE",
          "BATCH",
          "BATCH_MODE",
          "ACTION",
          "EXCEPTION",
          last_modified,
          "INTERFACE_SEQUENCE"
     FROM spoc17v2.x_imp_interface_batch@stl_escm_link;


DROP VIEW AMD_OWNER.SRU_PN_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SRU_PN_V
(
   PART_NO,
   MASTER_LCN,
   LCN,
   PCCN,
   PLISN,
   QPA,
   INDENTURE,
   SLIC_SMR,
   SLIC_WUC,
   TOCC,
   SLIC_CAGE,
   SLIC_NOUN,
   GOLD_NOUN,
   USABLE_FROM,
   USABLE_TO,
   IMS,
   AAC,
   SOS,
   NSN,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
     SELECT part_no,
            master_lcn,
            lcn,
            pccn,
            plisn,
            qpa,
            indenture,
            slic_smr,
            slic_wuc,
            tocc,
            slic_cage,
            slic_noun,
            gold_noun,
            usable_from,
            usable_to,
            ims,
            aac,
            sos,
            nsn,
            last_update_dt
       FROM (SELECT brkdwn.*, cat1.smrc cat1_smr
               FROM amd_owner.lru_breakdown brkdwn, amd_owner.pgold_cat1_v cat1
              WHERE master_lcn <> lcn AND part_no = cat1.part(+))
      WHERE    (    slic_smr IS NOT NULL
                AND SUBSTR (slic_smr, 1, 3) = 'PAF'
                AND SUBSTR (slic_smr, 4, 1) <> 'Z'
                AND SUBSTR (slic_smr, 5, 1) <> 'Z')
            OR (    slic_smr IS NULL
                AND SUBSTR (cat1_smr, 1, 3) = 'PAF'
                AND SUBSTR (cat1_smr, 4, 1) <> 'Z'
                AND SUBSTR (slic_smr, 5, 1) <> 'Z')
   ORDER BY master_lcn, lcn, part_no;


DROP VIEW AMD_OWNER.V8_CAPABILITYREQUIREMENTLVL4_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.V8_CAPABILITYREQUIREMENTLVL4_V
(
   NSN,
   CAPABILITY_REQUIREMENT
)
   BEQUEATH DEFINER
AS
   SELECT DISTINCT n.nsn, 4 capability_requirement
     FROM amd_demands d, amd_national_stock_items n, amd_spare_networks asn
    WHERE     d.action_code != 'D'
          AND asn.action_code != 'D'
          AND n.action_code != 'D'
          AND d.nsi_sid = n.nsi_sid
          AND d.loc_sid = asn.loc_sid
          AND d.quantity > 0
          AND asn.loc_id IN ('FB4488');


DROP VIEW AMD_OWNER.WECM_ACTIVE_NIINS_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.WECM_ACTIVE_NIINS_V
(
   NIIN
)
   BEQUEATH DEFINER
AS
   SELECT "NIIN" FROM wecm_active_niins@amd_pwecm_link;


DROP VIEW AMD_OWNER.WECM_L11_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.WECM_L11_V
(
   L11_ID,
   DIC,
   SOURCE_OF_SUPPLY,
   SRAN,
   FSC,
   NIIN,
   DASHED_NIIN,
   PART,
   NOUN,
   AUTOPROCESSFLAG,
   SUPPLIER,
   MMC,
   SYSTEM_DESIGNATOR,
   IMS_DESIGNATOR_CODE,
   ACTIVE_STATUS,
   ERRCD,
   UNIT_OF_ISSUE,
   DEMAND_LEVEL,
   BOEING_MAX_LEVEL_LOADED,
   RBL_LEVEL,
   ASL_LEVEL,
   ON_HAND_BALANCE,
   BOEING_BASE_MIN_LEVEL,
   BOEING_BASE_MAX_LEVEL,
   BOEING_AUTOPROCESS_LEVEL,
   MSK_AUTHORIZED,
   MSK_ON_HAND,
   MSK_DEPLOYED,
   ISSUED_DIFM,
   AWP_DIFM,
   DIFM_BACK_ORDERED,
   CREDIT_DIFM,
   GFPPRICE,
   DIFM,
   IRSP_AUTHORIZED,
   IRSP_ON_HAND,
   MRSP_AUTHORIZED,
   MRSP_ON_HAND,
   MRSP_DEPLOYED,
   HPMSK_AUTHORIZED,
   HPMSK_ON_HAND,
   HPMSK_DEPLOYED,
   DUE_OUT,
   DUE_IN,
   BOEING_PUSH_DUE_IN,
   DATE_OF_FIRST_DEMAND,
   DATE_OF_LAST_DEMAND,
   CUMULATIVE_DEMANDS,
   DEMANDS_CURRENT_6_MONTHS,
   DEMANDS_1ST_PAST_6_MONTHS,
   DEMANDS_2ND_PAST_6_MONTHS,
   PERCENT_BASE_REPAIR,
   REPAIRED_CURRENT_QUARTER,
   REPAIRED_1ST_PAST_QUARTER,
   REPAIRED_2ND_PAST_QUARTER,
   REPAIRED_3RD_PAST_QUARTER,
   REPAIRED_4TH_PAST_QUARTER,
   NOT_REPAIRED_CURRENT_QUARTER,
   NOT_REPAIRED_1ST_PAST_QUARTER,
   NOT_REPAIRED_2ND_PAST_QUARTER,
   NOT_REPAIRED_3RD_PAST_QUARTER,
   NOT_REPAIRED_4TH_PAST_QUARTER,
   CONDEMNED_CURRENT_QUARTER,
   CONDEMNED_1ST_PAST_QUARTER,
   CONDEMNED_2ND_PAST_QUARTER,
   CONDEMNED_3RD_PAST_QUARTER,
   CONDEMNED_4TH_PAST_QUARTER,
   BENCH_STOCK_AUTH_QTY,
   BENCH_STOCK_CUM_RECURR_DEMANDS,
   BENCH_STOCK_DUE_OUTS,
   REPORT_DATE,
   LOCAL_BASE_ISG_NUMBER,
   LOCAL_BASE_ISG_CODE,
   UPDATED_DATE_TIME,
   LAST_PUSH_DATE_TIME,
   LAST_PUSH_QTY,
   LAST_UPDATED_USERID,
   TEMP_PUSHEDQTY,
   TEMP_UPDATEDUSERID,
   TEMP_PUSHDATETIME,
   TRANSMIT_FLAG,
   IMS_DESIGNATOR_NAME,
   FSS,
   PROD_TEST_FLAG,
   LAST_PUSH_REQUEST_ID,
   NEW_WESM_ITEM_B,
   AUTOPROCESSINGFLAG2
)
   BEQUEATH DEFINER
AS
   SELECT "L11_ID",
          "DIC",
          "SOURCE_OF_SUPPLY",
          "SRAN",
          "FSC",
          "NIIN",
          "DASHED_NIIN",
          "PART",
          "NOUN",
          "AUTOPROCESSFLAG",
          "SUPPLIER",
          "MMC",
          "SYSTEM_DESIGNATOR",
          "IMS_DESIGNATOR_CODE",
          "ACTIVE_STATUS",
          "ERRCD",
          "UNIT_OF_ISSUE",
          "DEMAND_LEVEL",
          "BOEING_MAX_LEVEL_LOADED",
          "RBL_LEVEL",
          "ASL_LEVEL",
          "ON_HAND_BALANCE",
          "BOEING_BASE_MIN_LEVEL",
          "BOEING_BASE_MAX_LEVEL",
          "BOEING_AUTOPROCESS_LEVEL",
          "MSK_AUTHORIZED",
          "MSK_ON_HAND",
          "MSK_DEPLOYED",
          "ISSUED_DIFM",
          "AWP_DIFM",
          "DIFM_BACK_ORDERED",
          "CREDIT_DIFM",
          "GFPPRICE",
          "DIFM",
          "IRSP_AUTHORIZED",
          "IRSP_ON_HAND",
          "MRSP_AUTHORIZED",
          "MRSP_ON_HAND",
          "MRSP_DEPLOYED",
          "HPMSK_AUTHORIZED",
          "HPMSK_ON_HAND",
          "HPMSK_DEPLOYED",
          "DUE_OUT",
          "DUE_IN",
          "BOEING_PUSH_DUE_IN",
          "DATE_OF_FIRST_DEMAND",
          "DATE_OF_LAST_DEMAND",
          "CUMULATIVE_DEMANDS",
          "DEMANDS_CURRENT_6_MONTHS",
          "DEMANDS_1ST_PAST_6_MONTHS",
          "DEMANDS_2ND_PAST_6_MONTHS",
          "PERCENT_BASE_REPAIR",
          "REPAIRED_CURRENT_QUARTER",
          "REPAIRED_1ST_PAST_QUARTER",
          "REPAIRED_2ND_PAST_QUARTER",
          "REPAIRED_3RD_PAST_QUARTER",
          "REPAIRED_4TH_PAST_QUARTER",
          "NOT_REPAIRED_CURRENT_QUARTER",
          "NOT_REPAIRED_1ST_PAST_QUARTER",
          "NOT_REPAIRED_2ND_PAST_QUARTER",
          "NOT_REPAIRED_3RD_PAST_QUARTER",
          "NOT_REPAIRED_4TH_PAST_QUARTER",
          "CONDEMNED_CURRENT_QUARTER",
          "CONDEMNED_1ST_PAST_QUARTER",
          "CONDEMNED_2ND_PAST_QUARTER",
          "CONDEMNED_3RD_PAST_QUARTER",
          "CONDEMNED_4TH_PAST_QUARTER",
          "BENCH_STOCK_AUTH_QTY",
          "BENCH_STOCK_CUM_RECURR_DEMANDS",
          "BENCH_STOCK_DUE_OUTS",
          "REPORT_DATE",
          "LOCAL_BASE_ISG_NUMBER",
          "LOCAL_BASE_ISG_CODE",
          "UPDATED_DATE_TIME",
          "LAST_PUSH_DATE_TIME",
          "LAST_PUSH_QTY",
          "LAST_UPDATED_USERID",
          "TEMP_PUSHEDQTY",
          "TEMP_UPDATEDUSERID",
          "TEMP_PUSHDATETIME",
          "TRANSMIT_FLAG",
          "IMS_DESIGNATOR_NAME",
          "FSS",
          "PROD_TEST_FLAG",
          "LAST_PUSH_REQUEST_ID",
          "NEW_WESM_ITEM_B",
          "AUTOPROCESSINGFLAG2"
     FROM wecm_l11@AMD_PWECM_LINK;


DROP VIEW AMD_OWNER.X_BOM_DETAIL_V;

/* Formatted on 1/4/2019 2:49:38 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_BOM_DETAIL_V
(
   PART,
   INCLUDED_PART,
   BOM,
   QUANTITY,
   BEGIN_DATE,
   END_DATE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT name                                 part,
          attribute_28                         included_part,
          'C17',
          1,
          TO_DATE ('06/14/1993', 'MM/DD/YYYY') begin_date,
          TO_DATE ('12/31/2013', 'MM/DD/YYYY') end_date,
          last_modified
     FROM x_part_v
    WHERE attribute_28 = name;


DROP VIEW AMD_OWNER.X_BOM_LOCATION_CONTRACT_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_BOM_LOCATION_CONTRACT_V
(
   LOCATION,
   BOM,
   CONTRACT,
   CONTRACT_TYPE,
   CUSTOMER_LOCATION,
   BEGIN_DATE,
   END_DATE,
   QUANTITY
)
   BEQUEATH DEFINER
AS
     SELECT loc_id,
            'C17',
            'C17',
            'A',
            'AF',
            TO_DATE ('06/14/1993', 'MM/DD/YYYY'),
            TO_DATE ('12/31/4100', 'MM/DD/YYYY'),
            COUNT (aaa.tail_no)
       FROM amd_spare_networks asn, amd_ac_assigns aaa
      WHERE     asn.loc_sid = aaa.loc_sid
            AND (    assignment_start < CURRENT_DATE
                 AND (assignment_end > CURRENT_DATE OR assignment_end IS NULL))
            AND asn.spo_location IS NOT NULL
            AND asn.loc_type = 'MOB'
   GROUP BY asn.loc_id;


DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V
(
   CONFIRMED_REQUEST,
   LINE,
   LOCATION,
   PART,
   PROPOSED_REQUEST,
   REQUEST_DATE,
   DUE_DATE,
   QUANTITY_ORDERED,
   QUANTITY_RECEIVED,
   REQUEST_STATUS,
   SUPPLIER_LOCATION,
   LAST_MODIFIED,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   DATA_SOURCE
)
   BEQUEATH DEFINER
AS
   SELECT gold_order_number                  confirmed_request,
          line,
          amd_utils.getspolocation (loc_sid) location,
          on_order.part_no                   part,
          NULL                               proposed_request,
          order_date                         request_date,
          CASE
             WHEN sched_receipt_date IS NOT NULL THEN sched_receipt_date
             ELSE amd_owner.getduedate (on_order.part_no, order_date)
          END
             due_date,
          order_qty                          quantity,
          0                                  quantity_received,
          'O'                                request_status,
          NULL                               supplier_location,
          on_order.last_update_dt            last_modified,
          NULL                               attribute_1,
          NULL                               attribute_2,
          NULL                               attribute_3,
          NULL                               attribute_4,
          NULL                               attribute_5,
          NULL                               attribute_6,
          NULL                               attribute_7,
          NULL                               attribute_8,
          'AMD_ON_ORDER'                     data_source
     FROM amd_on_order on_order, amd_spare_parts parts, x_confirmed_request_v
    WHERE     gold_order_number = name
          AND amd_utils.getspolocation (loc_sid) IS NOT NULL
          AND on_order.action_code <> 'D'
          AND on_order.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
   UNION
   SELECT order_no                           confirmed_request,
          ROWNUM                             line,
          amd_utils.getspolocation (loc_sid) location,
          in_repair.part_no                  part,
          NULL                               proposed_request,
          repair_date                        request_date,
          CASE
             WHEN repair_need_date IS NOT NULL THEN repair_need_date
             ELSE amd_owner.getduedate (in_repair.part_no, repair_date)
          END
             due_date,
          repair_qty                         quantity,
          0                                  quantity_received,
          'O'                                request_status,
          NULL                               supplier_location,
          in_repair.last_update_dt           last_modified,
          NULL                               attribute_1,
          NULL                               attribute_2,
          NULL                               attribute_3,
          NULL                               attribute_4,
          NULL                               attribute_5,
          NULL                               attribute_6,
          NULL                               attribute_7,
          NULL                               attribute_8,
          'AMD_IN_REPAIR'                    data_source
     FROM amd_in_repair   in_repair,
          amd_spare_parts parts,
          x_confirmed_request_v
    WHERE     order_no = name
          AND amd_utils.getspolocation (loc_sid) IS NOT NULL
          AND in_repair.action_code <> 'D'
          AND in_repair.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
          AND parts.is_repairable = 'Y';


DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_CONFIRMED_REQUEST_V
(
   NAME,
   REQUEST_TYPE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT order_no                 name,
          repair_request           request_type,
          in_repair.last_update_dt last_modified
     FROM amd_in_repair in_repair, amd_spare_parts parts, amd_spo_types_v
    WHERE     in_repair.action_code <> 'D'
          AND in_repair.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
          AND parts.is_repairable = 'Y'
          AND amd_utils.getspolocation (loc_sid) IS NOT NULL
          AND in_repair.last_update_dt =
                 (SELECT MAX (last_update_dt)
                    FROM amd_in_repair r
                   WHERE     r.order_no = in_repair.order_no
                         AND r.action_code <> 'D')
   UNION
   SELECT gold_order_number       name,
          new_buy_request         request_type,
          on_order.last_update_dt last_modified
     FROM amd_on_order on_order, amd_spare_parts parts, amd_spo_types_v
    WHERE     on_order.action_code <> 'D'
          AND on_order.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
          AND amd_utils.getspolocation (loc_sid) IS NOT NULL
          AND on_order.last_update_dt =
                 (SELECT MAX (last_update_dt)
                    FROM amd_on_order o
                   WHERE     o.gold_order_number = on_order.gold_order_number
                         AND o.action_code <> 'D');


DROP VIEW AMD_OWNER.X_LP_ATTRIBUTE_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_LP_ATTRIBUTE_V
(
   LOCATION,
   PART,
   CONDEMNATION_RATE,
   PASSUP_RATE,
   CRITICALITY,
   VARIANCE_TO_MEAN_RATIO,
   DEMAND_FORECAST_TYPE,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   ATTRIBUTE_9,
   ATTRIBUTE_10,
   ATTRIBUTE_11,
   ATTRIBUTE_12,
   ATTRIBUTE_13,
   ATTRIBUTE_14,
   ATTRIBUTE_15,
   ATTRIBUTE_16,
   ATTRIBUTE_17,
   ATTRIBUTE_18,
   ATTRIBUTE_19,
   ATTRIBUTE_20,
   ATTRIBUTE_21,
   ATTRIBUTE_22,
   ATTRIBUTE_23,
   ATTRIBUTE_24,
   ATTRIBUTE_25,
   ATTRIBUTE_26,
   ATTRIBUTE_27,
   ATTRIBUTE_28,
   ATTRIBUTE_29,
   ATTRIBUTE_30,
   ATTRIBUTE_31,
   ATTRIBUTE_32,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT ntwks.spo_location     location,
          factors.part_no        part,
          factors.cmdmd_rate     condemnation_rate,
          factors.pass_up_rate,
          pref.criticality       criticality,
          1                      variance_to_mean_ratio,
          NULL                   demand_forecast_type,
          NULL                   attribute_1,
          NULL                   attribute_2,
          NULL                   attribute_3,
          NULL                   attribute_4,
          NULL                   attribute_5,
          NULL                   attribute_6,
          NULL                   attribute_7,
          NULL                   attribute_8,
          NULL                   attribute_9,
          NULL                   attribute_10,
          NULL                   attribute_11,
          NULL                   attribute_12,
          NULL                   attribute_13,
          NULL                   attribute_14,
          NULL                   attribute_15,
          NULL                   attribute_16,
          NULL                   attribute_17,
          NULL                   attribute_18,
          NULL                   attribute_19,
          NULL                   attribute_20,
          NULL                   attribute_21,
          NULL                   attribute_22,
          NULL                   attribute_23,
          NULL                   attribute_24,
          NULL                   attribute_25,
          NULL                   attribute_26,
          NULL                   attribute_27,
          NULL                   attribute_28,
          NULL                   attribute_29,
          NULL                   attribute_30,
          NULL                   attribute_31,
          NULL                   attribute_32,
          factors.last_update_dt last_modified
     FROM amd_part_factors   factors,
          amd_spare_parts    parts,
          amd_preferred_v    pref,
          amd_spare_networks ntwks
    WHERE     parts.is_spo_part = 'Y'
          AND parts.is_repairable = 'Y'
          AND parts.part_no = parts.spo_prime_part_no
          AND parts.part_no = factors.part_no
          AND factors.action_code <> 'D'
          AND parts.part_no = pref.part_no
          AND factors.cmdmd_rate IS NOT NULL
          AND factors.pass_up_rate IS NOT NULL
          AND factors.rts IS NOT NULL
          AND factors.cmdmd_rate + factors.pass_up_rate + factors.rts = 1
          AND factors.loc_sid = ntwks.loc_sid
          AND ntwks.loc_id = ntwks.spo_location;


DROP VIEW AMD_OWNER.X_LP_BACKORDER_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_LP_BACKORDER_V
(
   LOCATION,
   PART,
   BACKORDER_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT spo_location                location,
          backorder.spo_prime_part_no part,
          general_backorder           backorder_type,
          qty,
          backorder.last_update_dt    last_modified
     FROM amd_backorder_sum backorder, amd_spare_parts parts, amd_spo_types_v
    WHERE     backorder.action_code <> 'D'
          AND backorder.spo_prime_part_no = parts.part_no
          AND parts.is_spo_part = 'Y';


DROP VIEW AMD_OWNER.X_LP_DEMAND_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_LP_DEMAND_V
(
   TRANSACTION_ID,
   LOCATION,
   PART,
   CONTRACT,
   DEMAND_DATE,
   CUSTOMER_LOCATION,
   PRODUCT_SERIAL_NUMBER,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT doc_no || '-' || LPAD (TO_CHAR (loc_sid), 4, '0') transaction_id,
          amd_utils.getspolocation (loc_sid)                location,
          parts.spo_prime_part_no                           part,
          'C17'                                             contract,
          doc_date                                          demand_date,
          NULL
             customoer_location,
          NULL
             product_serial_number,
          quantity,
          dmnd.last_update_dt                               last_modified
     FROM amd_demands              dmnd,
          amd_national_stock_items items,
          amd_spare_parts          parts
    WHERE     dmnd.action_code <> 'D'
          AND dmnd.nsi_sid = items.nsi_sid
          AND items.prime_part_no = parts.part_no
          AND parts.is_spo_part = 'Y';


DROP VIEW AMD_OWNER.X_LP_IN_TRANSIT_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_LP_IN_TRANSIT_V
(
   LOCATION,
   PART,
   IN_TRANSIT_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT site_location           location,
          transits.part_no        part,
          DECODE (serviceable_flag,
                  'Y', general_in_transit,
                  'N', defective_in_transit,
                  serviceable_flag)
             in_transit_type,
          quantity,
          transits.last_update_dt last_modified
     FROM amd_in_transits_sum transits,
          amd_spare_parts     parts,
          amd_spo_types_v
    WHERE     transits.action_code <> 'D'
          AND transits.part_no = parts.part_no
          AND parts.is_spo_part = 'Y';


DROP VIEW AMD_OWNER.X_LP_LEAD_TIME_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_LP_LEAD_TIME_V
(
   LOCATION,
   PART,
   LEAD_TIME_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT ntwks.spo_location location,
          lt.part_no         part,
          repair_lead_time   lead_time_type,
          time_to_repair     quantity,
          lt.last_update_dt  last_modified
     FROM amd_location_part_leadtime lt,
          amd_spare_networks         ntwks,
          amd_spare_parts            parts,
          amd_spo_types_v
    WHERE     lt.action_code <> 'D'
          AND lt.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
          AND parts.is_repairable = 'Y'
          AND lt.loc_sid = ntwks.loc_sid
          AND ntwks.spo_location = ntwks.loc_id;


DROP VIEW AMD_OWNER.X_LP_ON_HAND_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_LP_ON_HAND_V
(
   LOCATION,
   PART,
   ON_HAND_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT spo_location        location,
          invs.part_no        part,
          general_on_hand     on_hand_type,
          qty_on_hand         quantity,
          invs.last_update_dt last_modified
     FROM amd_on_hand_invs_sum invs, amd_spare_parts parts, amd_spo_types_v
    WHERE     invs.action_code <> 'D'
          AND invs.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
   UNION
   SELECT site_location       location,
          invs.part_no        part,
          defective_on_hand   on_hand_type,
          qty_on_hand         quantity,
          invs.last_update_dt last_modified
     FROM amd_repair_invs_sum invs, amd_spare_parts parts, amd_spo_types_v
    WHERE     invs.action_code <> 'D'
          AND invs.part_no = parts.part_no
          AND parts.is_spo_part = 'Y';


DROP VIEW AMD_OWNER.X_NETWORK_PART_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_NETWORK_PART_V
(
   NETWORK,
   PART,
   SMR_CODE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
     SELECT CASE
               WHEN is_reparable = 'T' AND SUBSTR (attribute_10, 3, 1) = 'O'
               THEN
                  'LRU'
               WHEN is_reparable = 'T' AND SUBSTR (attribute_10, 3, 1) <> 'O'
               THEN
                  'Non LRU'
               ELSE
                  'Consumables'
            END
               network,
            name AS part,
            attribute_10,
            last_modified
       FROM x_part_v
   ORDER BY network, part;


DROP VIEW AMD_OWNER.X_PART_CAUSAL_TYPE_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_PART_CAUSAL_TYPE_V
(
   PART,
   CAUSAL_TYPE,
   QUANTITY,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT parts.part_no        part,
          flight_hours_causal  causal_type,
          1                    quantity,
          parts.last_update_dt last_modified
     FROM amd_spare_parts parts, amd_spo_types_v
    WHERE parts.is_spo_part = 'Y';


DROP VIEW AMD_OWNER.X_PART_PLANNED_PART_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_PART_PLANNED_PART_V
(
   PART,
   PLANNED_PART,
   SUPERSESSION_TYPE,
   BEGIN_DATE,
   END_DATE,
   LAST_MODIFIED,
   SPO_USER,
   SOURCE
)
   BEQUEATH DEFINER
AS
   SELECT part,
          parts2.spo_prime_part_no             planned_part,
          supersession_type,
          assignment_date                      begin_date,
          TO_DATE ('12/31/4100', 'MM/DD/YYYY') end_date,
          SYSDATE                              last_modified,
          'SPO'                                spo_user,
          'RBL_PAIRS'                          source
     FROM (SELECT old_prime_part_no                      part,
                  amd_utils.getprimepartno (planned_nsn) planned_part,
                  supersession_type
             FROM amd_twoway_rbl_pairs_v twoway,
                  (SELECT old_nsn planned_nsn, new_nsn
                     FROM amd_rbl_pairs a
                    WHERE     subgroup_code = (SELECT subgroup_code
                                                 FROM amd_rbl_pairs
                                                WHERE old_nsn = a.new_nsn)
                          AND part_pref_code =
                                 (SELECT MAX (part_pref_code)
                                    FROM amd_rbl_pairs
                                   WHERE     new_nsn = a.new_nsn
                                         AND subgroup_code =
                                                (SELECT subgroup_code
                                                   FROM amd_rbl_pairs
                                                  WHERE old_nsn = a.new_nsn)))
                  planned
            WHERE twoway.new_nsn = planned.new_nsn) twoway_planned,
          amd_nsi_parts   nsi,
          amd_spare_parts parts1,
          amd_spare_parts parts2,
          amd_spare_parts parts3
    WHERE     twoway_planned.part = parts1.part_no
          AND parts1.is_spo_part = 'Y'
          AND twoway_planned.planned_part = parts2.part_no
          AND parts2.is_spo_part = 'Y'
          AND part <> parts2.spo_prime_part_no
          AND nsi.part_no = twoway_planned.part
          AND nsi.unassignment_date IS NULL
          AND parts2.spo_prime_part_no = parts3.part_no
          AND parts3.is_spo_part = 'Y'
   UNION
   SELECT parts.part_no,
          parts.spo_prime_part_no planned_part,
          two_way_supersession    supersession_type,
          alts.assignment_date    begin_date,
          CASE
             WHEN parts.action_code = 'D' THEN parts.last_update_dt
             ELSE TO_DATE ('12/31/4100', 'MM/DD/YYYY')
          END
             end_date,
          SYSDATE                 last_modified,
          'SPO'                   spo_user,
          'ALTERNATE_PARTS'       source
     FROM amd_spare_parts          parts,
          amd_national_stock_items items,
          amd_nsi_parts            alts,
          amd_spo_types_v,
          amd_spare_parts          parts2
    WHERE     parts.is_spo_part = 'Y'
          AND parts.part_no <> parts.spo_prime_part_no
          AND parts.nsn = items.nsn
          AND items.action_code <> 'D'
          AND parts.part_no <> items.prime_part_no
          AND parts.part_no = alts.part_no
          AND alts.unassignment_date IS NULL
          AND alts.prime_ind = 'N'
          AND parts.spo_prime_part_no = parts2.part_no
          AND parts2.is_spo_part = 'Y';


DROP VIEW AMD_OWNER.X_PART_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_PART_V
(
   NAME,
   PART_TYPE,
   DESCRIPTION,
   COST,
   BEGIN_DATE,
   END_DATE,
   HOLDING_COST_RATE,
   FIXED_ORDER_COST,
   IS_ORDER_POLICY_ROQ_BASED,
   IS_REPARABLE,
   REPAIR_COST,
   DECAY_RATE,
   GENERATE_NEW_BUY,
   GENERATE_REPAIR,
   GENERATE_ALLOCATION,
   GENERATE_TRANSSHIPMENT,
   MAX_QTY_ALLOWANCE,
   MAX_TOTAL_TSL,
   LAST_MODIFIED,
   IS_PLANNED,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   ATTRIBUTE_9,
   ATTRIBUTE_10,
   ATTRIBUTE_11,
   ATTRIBUTE_12,
   ATTRIBUTE_13,
   ATTRIBUTE_14,
   ATTRIBUTE_15,
   ATTRIBUTE_16,
   ATTRIBUTE_17,
   ATTRIBUTE_18,
   ATTRIBUTE_19,
   ATTRIBUTE_20,
   ATTRIBUTE_21,
   ATTRIBUTE_22,
   ATTRIBUTE_23,
   ATTRIBUTE_24,
   ATTRIBUTE_25,
   ATTRIBUTE_26,
   ATTRIBUTE_27,
   ATTRIBUTE_28,
   ATTRIBUTE_29,
   ATTRIBUTE_30,
   ATTRIBUTE_31,
   ATTRIBUTE_32,
   MATERIAL_CLASS,
   WEIGHT,
   VOLUME,
   IS_EXEMPT,
   IGNORE_WEIGHT_AND_VOLUME,
   IS_SEASONAL,
   IS_CANNIBALIZABLE,
   PARTIAL_ONE_WAY_SUPERSESSION,
   IS_NEW,
   LIKE_PART,
   NEW_BUY_LEAD_TIME,
   REPAIR_LEAD_TIME,
   NEW_BUY_LEAD_TIME_VARIANCE,
   REPAIR_LEAD_TIME_VARIANCE,
   FORECAST_RISK_MULTIPLIER
)
   BEQUEATH DEFINER
AS
   SELECT parts.part_no                name,
          'AIRPLANE'                   AS part_type,
          parts.nomenclature,
          NVL (pref.unit_cost, 0)      unit_cost,
          nsi.assignment_date          begin_date,
          NULL                         end_date,
          NULL                         holding_cost_rate,
          NULL                         fixed_order_cost,
          CASE WHEN parts.is_repairable = 'Y' THEN 'F' ELSE 'T' END
             is_order_policy_roq_based,
          CASE WHEN parts.is_repairable = 'Y' THEN 'T' ELSE 'F' END
             is_reparable,
          NULL                         repair_cost,
          0                            decay_rate,
          'T'                          generate_new_buy,
          'F'                          generate_repair,
          'T'                          generate_allocation,
          'T'                          generate_transshipment,
          NULL                         max_qty_allowance,
          NULL                         max_total_tsl,
          parts.last_update_dt         last_modified,
          'T'                          is_planned,
          NULL                         attribute_1,
          NULL                         attribute_2,
          NULL                         attribute_3,
          NULL                         attribute_4,
          NULL                         attribute_5,
          NULL                         attribute_6,
          NULL                         attribute_7,
          NULL                         attribute_8,
          NULL                         attribute_9,
          pref.smr_code                attribute_10,
          items.nsn                    attribute_11,
          pref.criticality             attribute_12,
          NULL                         attribute_13,
          pref.planner_code            attribute_14,
          NULL                         attribute_15,
          NULL                         attribute_16,
          NULL                         attribute_17,
          NULL                         attribute_18,
          parts.mfgr                   attribute_19,
          CASE
             WHEN parts.is_repairable = 'N' THEN 'F'
             WHEN parts.is_repairable = 'Y' THEN 'T'
             ELSE NULL
          END
             attribute_20,
          NULL                         attribute_21,
          NULL                         attribute_22,
          NULL                         attribute_23,
          NULL                         attribute_24,
          NULL                         attribute_25,
          NULL                         attribute_26,
          NULL                         attribute_27,
          parts.spo_prime_part_no      attribute_28,
          CASE
             WHEN items.wesm_indicator IS NULL THEN NULL
             ELSE 'WESM Part'
          END
             attribute_29,
          CASE WHEN bsi.nsn IS NULL THEN NULL ELSE 'Bench Stock Item' END
             attribute_30,
          NULL                         attribute_31,
          NULL                         attribute_32,
          NULL                         material_class,
          NULL                         weight,
          NULL                         volume,
          'T'                          is_exempt,
          'T'                          ignore_weight_and_volume,
          'F'                          is_seasonal,
          'F'                          is_cannibalizable,
          'F'                          partial_one_way_supersession,
          CASE
             WHEN     parts.action_code = 'A'
                  AND items.action_code = 'A'
                  AND TRUNC (parts.last_update_dt) = TRUNC (SYSDATE)
             THEN
                'T'
             ELSE
                'F'
          END
             is_new,
          NULL                         like_part,
          pref.order_lead_time         new_buy_lead_time,
          pref.time_to_repair_off_base repair_lead_time,
          0                            new_buy_lead_time_variance,
          0                            repair_lead_time_variance,
          1                            forecast_risk_factor
     FROM amd_spare_parts          parts,
          amd_national_stock_items items,
          amd_bench_stock_items_v  bsi,
          amd_nsi_parts            nsi,
          amd_preferred_v          pref
    WHERE     parts.nsn = items.nsn
          AND (parts.action_code <> 'D' AND items.action_code <> 'D')
          AND parts.is_spo_part = 'Y'
          AND items.nsn = bsi.nsn(+)
          AND parts.part_no = nsi.part_no
          AND parts.part_no = pref.part_no
          AND nsi.unassignment_date IS NULL;


DROP VIEW AMD_OWNER.X_USER_PART_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_USER_PART_V
(
   SPO_USER,
   PART,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT TO_CHAR (TO_NUMBER (spousers.logon_id)) spo_user,
          parts.part_no                           part,
          parts.last_update_dt                    last_modified
     FROM amd_spare_parts          parts,
          amd_national_stock_items items,
          amd_planner_logons_v     spousers,
          amd_preferred_v          pref
    WHERE     parts.is_spo_part = 'Y'
          AND parts.nsn = items.nsn
          AND items.action_code <> 'D'
          AND parts.part_no = pref.part_no
          AND pref.planner_code = spousers.planner_code;


DROP VIEW AMD_OWNER.X_USER_USER_TYPE_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_USER_USER_TYPE_V
(
   SPO_USER,
   USER_TYPE,
   DATA_SOURCE,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT DISTINCT TO_CHAR (TO_NUMBER (logon_id)) spo_user,
                   'PLANNER'                      user_type,
                   'AMD_PLANNER_LOGONS_V'         data_source,
                   last_update_dt
     FROM amd_planner_logons_v
   UNION
   SELECT TO_CHAR (TO_NUMBER (bems_id)) spo_user,
          user_type,
          'AMD_USER_TYPE'               data_source,
          last_update_dt
     FROM amd_user_type
    WHERE action_code <> 'D'
   UNION
   SELECT TO_CHAR (TO_NUMBER (bems_id)) spo_user,
          'SYSTEM'                      user_type,
          'AMD_SITE_ASSET_MGR',
          last_update_dt
     FROM amd_site_asset_mgr
    WHERE     action_code <> 'D'
          AND bems_id NOT IN (SELECT bems_id
                                FROM amd_user_type
                               WHERE action_code <> 'D')
   UNION
   SELECT TO_CHAR (TO_NUMBER (bems_id)) spo_user,
          'ADMINISTRATOR'               user_type,
          'AMD_SITE_ASSET_MGR',
          last_update_dt
     FROM amd_site_asset_mgr
    WHERE     action_code <> 'D'
          AND bems_id NOT IN (SELECT bems_id
                                FROM amd_user_type
                               WHERE action_code <> 'D')
   UNION
   SELECT TO_CHAR (TO_NUMBER (bems_id)) spo_user,
          'PLANNER'                     user_type,
          'AMD_SITE_ASSET_MGR',
          last_update_dt
     FROM amd_site_asset_mgr
    WHERE     action_code <> 'D'
          AND bems_id NOT IN (SELECT bems_id
                                FROM amd_user_type
                               WHERE action_code <> 'D');


DROP VIEW AMD_OWNER.X_USER_V;

/* Formatted on 1/4/2019 2:49:39 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_USER_V
(
   NAME,
   EMAIL_ADDRESS,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   LAST_MODIFIED
)
   BEQUEATH DEFINER
AS
   SELECT TO_CHAR (TO_NUMBER (users.bems_id))           name,
          REPLACE (stable_email, ' ', '')               email_address,
          TRIM (last_name) || ', ' || TRIM (first_name) attribute_1,
          mgr.comments                                  attribute_2,
          NULL                                          attribute_3,
          NULL                                          attribute_4,
          NULL                                          attribute_5,
          NULL                                          attribute_6,
          NULL                                          attribute_7,
          'A'                                           attribute_8,
          users.last_update_dt                          last_modified
     FROM amd_users_v users, amd_site_asset_mgr mgr
    WHERE users.bems_id = mgr.bems_id(+);


DROP PUBLIC SYNONYM ACTIVE_PARTS_V;

CREATE PUBLIC SYNONYM ACTIVE_PARTS_V FOR AMD_OWNER.ACTIVE_PARTS_V;


DROP PUBLIC SYNONYM AMDII_2A_CAT1_V;

CREATE PUBLIC SYNONYM AMDII_2A_CAT1_V FOR AMD_OWNER.AMDII_2A_CAT1_V;


DROP PUBLIC SYNONYM AMDII_DI_DEMANDS_SRANS_CONV_V;

CREATE PUBLIC SYNONYM AMDII_DI_DEMANDS_SRANS_CONV_V FOR AMD_OWNER.AMDII_DI_DEMANDS_SRANS_CONV_V;


DROP PUBLIC SYNONYM AMDII_DI_DEMANDS_SUM_V;

CREATE PUBLIC SYNONYM AMDII_DI_DEMANDS_SUM_V FOR AMD_OWNER.AMDII_DI_DEMANDS_SUM_V;


DROP PUBLIC SYNONYM AMDII_DI_INVENTORY_SRAN_CONV_V;

CREATE PUBLIC SYNONYM AMDII_DI_INVENTORY_SRAN_CONV_V FOR AMD_OWNER.AMDII_DI_INVENTORY_SRAN_CONV_V;


DROP PUBLIC SYNONYM AMDII_DI_INVENTORY_SUMMED_W_V;

CREATE PUBLIC SYNONYM AMDII_DI_INVENTORY_SUMMED_W_V FOR AMD_OWNER.AMDII_DI_INVENTORY_SUMMED_W_V;


DROP PUBLIC SYNONYM AMDII_DI_INVENTORY_V;

CREATE PUBLIC SYNONYM AMDII_DI_INVENTORY_V FOR AMD_OWNER.AMDII_DI_INVENTORY_V;


DROP PUBLIC SYNONYM AMDII_IN_REPAIR_V;

CREATE PUBLIC SYNONYM AMDII_IN_REPAIR_V FOR AMD_OWNER.AMDII_IN_REPAIR_V;


DROP PUBLIC SYNONYM AMDII_PART_INFO2_V;

CREATE PUBLIC SYNONYM AMDII_PART_INFO2_V FOR AMD_OWNER.AMDII_PART_INFO2_V;


DROP PUBLIC SYNONYM AMDII_PART_INFO_A_V;

CREATE PUBLIC SYNONYM AMDII_PART_INFO_A_V FOR AMD_OWNER.AMDII_PART_INFO_A_V;


DROP PUBLIC SYNONYM AMDII_PART_INFO_B_V;

CREATE PUBLIC SYNONYM AMDII_PART_INFO_B_V FOR AMD_OWNER.AMDII_PART_INFO_B_V;


DROP PUBLIC SYNONYM AMDII_PART_INFO_C_V;

CREATE PUBLIC SYNONYM AMDII_PART_INFO_C_V FOR AMD_OWNER.AMDII_PART_INFO_C_V;


DROP PUBLIC SYNONYM AMD_BENCH_STOCK_ITEMS_V;

CREATE PUBLIC SYNONYM AMD_BENCH_STOCK_ITEMS_V FOR AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V;


DROP PUBLIC SYNONYM AMD_BLIS_V;

CREATE PUBLIC SYNONYM AMD_BLIS_V FOR AMD_OWNER.AMD_BLIS_V;


DROP PUBLIC SYNONYM AMD_CONSUMABLE_PARTS_V;

CREATE PUBLIC SYNONYM AMD_CONSUMABLE_PARTS_V FOR AMD_OWNER.AMD_CONSUMABLE_PARTS_V;


DROP PUBLIC SYNONYM AMD_DEFAULT_PLANNERS_V;

CREATE PUBLIC SYNONYM AMD_DEFAULT_PLANNERS_V FOR AMD_OWNER.AMD_DEFAULT_PLANNERS_V;


DROP PUBLIC SYNONYM AMD_DEFAULT_PLANNER_LOGONS_V;

CREATE PUBLIC SYNONYM AMD_DEFAULT_PLANNER_LOGONS_V FOR AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V;


DROP PUBLIC SYNONYM AMD_DEFAULT_USERS_V;

CREATE PUBLIC SYNONYM AMD_DEFAULT_USERS_V FOR AMD_OWNER.AMD_DEFAULT_USERS_V;


DROP PUBLIC SYNONYM AMD_FOR_DI_DEMANDS_SUM_V;

CREATE PUBLIC SYNONYM AMD_FOR_DI_DEMANDS_SUM_V FOR AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V;


DROP PUBLIC SYNONYM AMD_ISGP_CHILD_NSNS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_CHILD_NSNS_V FOR AMD_OWNER.AMD_ISGP_CHILD_NSNS_V;


DROP PUBLIC SYNONYM AMD_ISGP_GROUPS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_GROUPS_V FOR AMD_OWNER.AMD_ISGP_GROUPS_V;


DROP PUBLIC SYNONYM AMD_ISGP_MASTER_NSNS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_MASTER_NSNS_V FOR AMD_OWNER.AMD_ISGP_MASTER_NSNS_V;


DROP PUBLIC SYNONYM AMD_ISGP_RBL_PAIRS_V;

CREATE PUBLIC SYNONYM AMD_ISGP_RBL_PAIRS_V FOR AMD_OWNER.AMD_ISGP_RBL_PAIRS_V;


DROP PUBLIC SYNONYM AMD_PART_HEADER_V5;

CREATE PUBLIC SYNONYM AMD_PART_HEADER_V5 FOR AMD_OWNER.AMD_PART_HEADER_V5;


DROP PUBLIC SYNONYM AMD_PART_IDS;

CREATE PUBLIC SYNONYM AMD_PART_IDS FOR AMD_OWNER.AMD_PART_IDS;


DROP PUBLIC SYNONYM AMD_PEOPLE_ALL_V;

CREATE PUBLIC SYNONYM AMD_PEOPLE_ALL_V FOR AMD_OWNER.AMD_PEOPLE_ALL_V;


DROP PUBLIC SYNONYM AMD_PLANNER_LOGONS_V;

CREATE PUBLIC SYNONYM AMD_PLANNER_LOGONS_V FOR AMD_OWNER.AMD_PLANNER_LOGONS_V;


DROP PUBLIC SYNONYM AMD_PREFERRED_V;

CREATE PUBLIC SYNONYM AMD_PREFERRED_V FOR AMD_OWNER.AMD_PREFERRED_V;


DROP PUBLIC SYNONYM AMD_PSLMS_HA;

CREATE PUBLIC SYNONYM AMD_PSLMS_HA FOR AMD_OWNER.AMD_PSLMS_HA;


DROP PUBLIC SYNONYM AMD_PSLMS_HG;

CREATE PUBLIC SYNONYM AMD_PSLMS_HG FOR AMD_OWNER.AMD_PSLMS_HG;


DROP PUBLIC SYNONYM AMD_PSLMS_XA;

CREATE PUBLIC SYNONYM AMD_PSLMS_XA FOR AMD_OWNER.AMD_PSLMS_XA;


DROP PUBLIC SYNONYM AMD_PSLMS_XB;

CREATE PUBLIC SYNONYM AMD_PSLMS_XB FOR AMD_OWNER.AMD_PSLMS_XB;


DROP PUBLIC SYNONYM AMD_PSLMS_XC;

CREATE PUBLIC SYNONYM AMD_PSLMS_XC FOR AMD_OWNER.AMD_PSLMS_XC;


DROP PUBLIC SYNONYM AMD_PSLMS_XI;

CREATE PUBLIC SYNONYM AMD_PSLMS_XI FOR AMD_OWNER.AMD_PSLMS_XI;


DROP PUBLIC SYNONYM AMD_RBL_PAIRS_V;

CREATE PUBLIC SYNONYM AMD_RBL_PAIRS_V FOR AMD_OWNER.AMD_RBL_PAIRS_V;


DROP PUBLIC SYNONYM AMD_REPAIRABLE_PARTS_V;

CREATE PUBLIC SYNONYM AMD_REPAIRABLE_PARTS_V FOR AMD_OWNER.AMD_REPAIRABLE_PARTS_V;


DROP PUBLIC SYNONYM AMD_RSP_ON_HAND_N_OBJECTIVE_V;

CREATE PUBLIC SYNONYM AMD_RSP_ON_HAND_N_OBJECTIVE_V FOR AMD_OWNER.AMD_RSP_ON_HAND_N_OBJECTIVE_V;


DROP PUBLIC SYNONYM AMD_RSP_SUM_CONSUMABLES_V;

CREATE PUBLIC SYNONYM AMD_RSP_SUM_CONSUMABLES_V FOR AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V;


DROP PUBLIC SYNONYM AMD_RSP_SUM_REPAIRABLES_V;

CREATE PUBLIC SYNONYM AMD_RSP_SUM_REPAIRABLES_V FOR AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V;


DROP PUBLIC SYNONYM AMD_SPO_PARTS_V;

CREATE PUBLIC SYNONYM AMD_SPO_PARTS_V FOR AMD_OWNER.AMD_SPO_PARTS_V;


DROP PUBLIC SYNONYM AMD_SPO_TYPES_V;

CREATE PUBLIC SYNONYM AMD_SPO_TYPES_V FOR AMD_OWNER.AMD_SPO_TYPES_V;


DROP PUBLIC SYNONYM AMD_TWOWAY_RBL_PAIRS_V;

CREATE PUBLIC SYNONYM AMD_TWOWAY_RBL_PAIRS_V FOR AMD_OWNER.AMD_TWOWAY_RBL_PAIRS_V;


DROP PUBLIC SYNONYM AMD_USERS_V;

CREATE PUBLIC SYNONYM AMD_USERS_V FOR AMD_OWNER.AMD_USERS_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_BAD_NSN_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_BAD_NSN_V FOR AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_DELNSN_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_DELNSN_V FOR AMD_OWNER.AMD_WARNER_ROBINS_DELNSN_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_DUPMLTFILE_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_DUPMLTFILE_V FOR AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_DUPS_DET_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_DUPS_DET_V FOR AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_DUPS_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_DUPS_V FOR AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_FILES_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_FILES_V FOR AMD_OWNER.AMD_WARNER_ROBINS_FILES_V;


DROP PUBLIC SYNONYM AMD_WARNER_ROBINS_SUMMED_V;

CREATE PUBLIC SYNONYM AMD_WARNER_ROBINS_SUMMED_V FOR AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V;


DROP PUBLIC SYNONYM BSSM_2F_RAMP_V;

CREATE PUBLIC SYNONYM BSSM_2F_RAMP_V FOR AMD_OWNER.BSSM_2F_RAMP_V;


DROP PUBLIC SYNONYM COMPONENT_LRU_V;

CREATE PUBLIC SYNONYM COMPONENT_LRU_V FOR AMD_OWNER.COMPONENT_LRU_V;


DROP PUBLIC SYNONYM COMPONENT_PART_V;

CREATE PUBLIC SYNONYM COMPONENT_PART_V FOR AMD_OWNER.COMPONENT_PART_V;


DROP PUBLIC SYNONYM DATASYS_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM DATASYS_LP_OVERRIDE_V FOR AMD_OWNER.DATASYS_LP_OVERRIDE_V;


DROP PUBLIC SYNONYM DATASYS_PART_V;

CREATE PUBLIC SYNONYM DATASYS_PART_V FOR AMD_OWNER.DATASYS_PART_V;


DROP PUBLIC SYNONYM DATASYS_PLANNER_V;

CREATE PUBLIC SYNONYM DATASYS_PLANNER_V FOR AMD_OWNER.DATASYS_PLANNER_V;


DROP PUBLIC SYNONYM DATASYS_TRANS_PROCESSED_V;

CREATE PUBLIC SYNONYM DATASYS_TRANS_PROCESSED_V FOR AMD_OWNER.DATASYS_TRANS_PROCESSED_V;


DROP PUBLIC SYNONYM FEDLOG_ACTIVE_NIINS_V;

CREATE PUBLIC SYNONYM FEDLOG_ACTIVE_NIINS_V FOR AMD_OWNER.FEDLOG_ACTIVE_NIINS_V;


DROP PUBLIC SYNONYM GOLDSA_ITEM_V;

CREATE PUBLIC SYNONYM GOLDSA_ITEM_V FOR AMD_OWNER.GOLDSA_ITEM_V;


DROP PUBLIC SYNONYM GOLDSA_REQ1_V;

CREATE PUBLIC SYNONYM GOLDSA_REQ1_V FOR AMD_OWNER.GOLDSA_REQ1_V;


DROP PUBLIC SYNONYM GOLDSA_WHSE_V;

CREATE PUBLIC SYNONYM GOLDSA_WHSE_V FOR AMD_OWNER.GOLDSA_WHSE_V;


DROP PUBLIC SYNONYM LRU_MASTER_LCN_V;

CREATE PUBLIC SYNONYM LRU_MASTER_LCN_V FOR AMD_OWNER.LRU_MASTER_LCN_V;


DROP PUBLIC SYNONYM LRU_PN_V;

CREATE PUBLIC SYNONYM LRU_PN_V FOR AMD_OWNER.LRU_PN_V;


DROP PUBLIC SYNONYM PARTINFO_V;

CREATE PUBLIC SYNONYM PARTINFO_V FOR AMD_OWNER.PARTINFO_V;


DROP PUBLIC SYNONYM PGOLD_AUXB_V;

CREATE PUBLIC SYNONYM PGOLD_AUXB_V FOR AMD_OWNER.PGOLD_AUXB_V;


DROP PUBLIC SYNONYM PGOLD_CAT1_V;

CREATE PUBLIC SYNONYM PGOLD_CAT1_V FOR AMD_OWNER.PGOLD_CAT1_V;


DROP PUBLIC SYNONYM PGOLD_CATS$MERGED_V;

CREATE PUBLIC SYNONYM PGOLD_CATS$MERGED_V FOR AMD_OWNER.PGOLD_CATS$MERGED_V;


DROP PUBLIC SYNONYM PGOLD_CGVT_V;

CREATE PUBLIC SYNONYM PGOLD_CGVT_V FOR AMD_OWNER.PGOLD_CGVT_V;


DROP PUBLIC SYNONYM PGOLD_CHGH_V;

CREATE PUBLIC SYNONYM PGOLD_CHGH_V FOR AMD_OWNER.PGOLD_CHGH_V;


DROP PUBLIC SYNONYM PGOLD_FEDC_V;

CREATE PUBLIC SYNONYM PGOLD_FEDC_V FOR AMD_OWNER.PGOLD_FEDC_V;


DROP PUBLIC SYNONYM PGOLD_ISGP_V;

CREATE PUBLIC SYNONYM PGOLD_ISGP_V FOR AMD_OWNER.PGOLD_ISGP_V;


DROP PUBLIC SYNONYM PGOLD_ITEM_V;

CREATE PUBLIC SYNONYM PGOLD_ITEM_V FOR AMD_OWNER.PGOLD_ITEM_V;


DROP PUBLIC SYNONYM PGOLD_LVLS_V;

CREATE PUBLIC SYNONYM PGOLD_LVLS_V FOR AMD_OWNER.PGOLD_LVLS_V;


DROP PUBLIC SYNONYM PGOLD_MILS_V;

CREATE PUBLIC SYNONYM PGOLD_MILS_V FOR AMD_OWNER.PGOLD_MILS_V;


DROP PUBLIC SYNONYM PGOLD_MLIT_V;

CREATE PUBLIC SYNONYM PGOLD_MLIT_V FOR AMD_OWNER.PGOLD_MLIT_V;


DROP PUBLIC SYNONYM PGOLD_MLVT_V;

CREATE PUBLIC SYNONYM PGOLD_MLVT_V FOR AMD_OWNER.PGOLD_MLVT_V;


DROP PUBLIC SYNONYM PGOLD_NSN1_V;

CREATE PUBLIC SYNONYM PGOLD_NSN1_V FOR AMD_OWNER.PGOLD_NSN1_V;


DROP PUBLIC SYNONYM PGOLD_ORD1_V;

CREATE PUBLIC SYNONYM PGOLD_ORD1_V FOR AMD_OWNER.PGOLD_ORD1_V;


DROP PUBLIC SYNONYM PGOLD_ORDV_V;

CREATE PUBLIC SYNONYM PGOLD_ORDV_V FOR AMD_OWNER.PGOLD_ORDV_V;


DROP PUBLIC SYNONYM PGOLD_POI1_V;

CREATE PUBLIC SYNONYM PGOLD_POI1_V FOR AMD_OWNER.PGOLD_POI1_V;


DROP PUBLIC SYNONYM PGOLD_PRC1_V;

CREATE PUBLIC SYNONYM PGOLD_PRC1_V FOR AMD_OWNER.PGOLD_PRC1_V;


DROP PUBLIC SYNONYM PGOLD_RAMP_V;

CREATE PUBLIC SYNONYM PGOLD_RAMP_V FOR AMD_OWNER.PGOLD_RAMP_V;


DROP PUBLIC SYNONYM PGOLD_REQ1_V;

CREATE PUBLIC SYNONYM PGOLD_REQ1_V FOR AMD_OWNER.PGOLD_REQ1_V;


DROP PUBLIC SYNONYM PGOLD_RSV1_V;

CREATE PUBLIC SYNONYM PGOLD_RSV1_V FOR AMD_OWNER.PGOLD_RSV1_V;


DROP PUBLIC SYNONYM PGOLD_SC01_V;

CREATE PUBLIC SYNONYM PGOLD_SC01_V FOR AMD_OWNER.PGOLD_SC01_V;


DROP PUBLIC SYNONYM PGOLD_TMP1_V;

CREATE PUBLIC SYNONYM PGOLD_TMP1_V FOR AMD_OWNER.PGOLD_TMP1_V;


DROP PUBLIC SYNONYM PGOLD_TRHI_V;

CREATE PUBLIC SYNONYM PGOLD_TRHI_V FOR AMD_OWNER.PGOLD_TRHI_V;


DROP PUBLIC SYNONYM PGOLD_UIMS_V;

CREATE PUBLIC SYNONYM PGOLD_UIMS_V FOR AMD_OWNER.PGOLD_UIMS_V;


DROP PUBLIC SYNONYM PGOLD_USE1_V;

CREATE PUBLIC SYNONYM PGOLD_USE1_V FOR AMD_OWNER.PGOLD_USE1_V;


DROP PUBLIC SYNONYM PGOLD_VENC_V;

CREATE PUBLIC SYNONYM PGOLD_VENC_V FOR AMD_OWNER.PGOLD_VENC_V;


DROP PUBLIC SYNONYM PGOLD_VENN_V;

CREATE PUBLIC SYNONYM PGOLD_VENN_V FOR AMD_OWNER.PGOLD_VENN_V;


DROP PUBLIC SYNONYM PGOLD_WHSE_V;

CREATE PUBLIC SYNONYM PGOLD_WHSE_V FOR AMD_OWNER.PGOLD_WHSE_V;


DROP PUBLIC SYNONYM PGOLD_WIP1_V;

CREATE PUBLIC SYNONYM PGOLD_WIP1_V FOR AMD_OWNER.PGOLD_WIP1_V;


DROP PUBLIC SYNONYM PULL_ORD1_D_V;

CREATE PUBLIC SYNONYM PULL_ORD1_D_V FOR AMD_OWNER.PULL_ORD1_D_V;


DROP PUBLIC SYNONYM PULL_ORD1_V;

CREATE PUBLIC SYNONYM PULL_ORD1_V FOR AMD_OWNER.PULL_ORD1_V;


DROP PUBLIC SYNONYM RSP_ALL_ITEM_INV_V;

CREATE PUBLIC SYNONYM RSP_ALL_ITEM_INV_V FOR AMD_OWNER.RSP_ALL_ITEM_INV_V;


DROP PUBLIC SYNONYM RSP_INV_V;

CREATE PUBLIC SYNONYM RSP_INV_V FOR AMD_OWNER.RSP_INV_V;


DROP PUBLIC SYNONYM RSP_ITEMSA_INV_V;

CREATE PUBLIC SYNONYM RSP_ITEMSA_INV_V FOR AMD_OWNER.RSP_ITEMSA_INV_V;


DROP PUBLIC SYNONYM RSP_ITEM_INV_V;

CREATE PUBLIC SYNONYM RSP_ITEM_INV_V FOR AMD_OWNER.RSP_ITEM_INV_V;


DROP PUBLIC SYNONYM RSP_ON_HAND_AND_OBJECTIVE_V;

CREATE PUBLIC SYNONYM RSP_ON_HAND_AND_OBJECTIVE_V FOR AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V;


DROP PUBLIC SYNONYM RSP_RAMP_INV_V;

CREATE PUBLIC SYNONYM RSP_RAMP_INV_V FOR AMD_OWNER.RSP_RAMP_INV_V;


DROP PUBLIC SYNONYM RSP_RAMP_ITEM_V;

CREATE PUBLIC SYNONYM RSP_RAMP_ITEM_V FOR AMD_OWNER.RSP_RAMP_ITEM_V;


DROP PUBLIC SYNONYM RSP_WHSE_INV_V;

CREATE PUBLIC SYNONYM RSP_WHSE_INV_V FOR AMD_OWNER.RSP_WHSE_INV_V;


DROP PUBLIC SYNONYM SLIC_HA_SHELF_LIFE_V;

CREATE PUBLIC SYNONYM SLIC_HA_SHELF_LIFE_V FOR AMD_OWNER.SLIC_HA_SHELF_LIFE_V;


DROP PUBLIC SYNONYM SLIC_HA_V;

CREATE PUBLIC SYNONYM SLIC_HA_V FOR AMD_OWNER.SLIC_HA_V;


DROP PUBLIC SYNONYM SLIC_HB_V;

CREATE PUBLIC SYNONYM SLIC_HB_V FOR AMD_OWNER.SLIC_HB_V;


DROP PUBLIC SYNONYM SLIC_HD_V;

CREATE PUBLIC SYNONYM SLIC_HD_V FOR AMD_OWNER.SLIC_HD_V;


DROP PUBLIC SYNONYM SLIC_HF_V;

CREATE PUBLIC SYNONYM SLIC_HF_V FOR AMD_OWNER.SLIC_HF_V;


DROP PUBLIC SYNONYM SLIC_HG_SMR_CODES_V;

CREATE PUBLIC SYNONYM SLIC_HG_SMR_CODES_V FOR AMD_OWNER.SLIC_HG_SMR_CODES_V;


DROP PUBLIC SYNONYM SLIC_HG_V;

CREATE PUBLIC SYNONYM SLIC_HG_V FOR AMD_OWNER.SLIC_HG_V;


DROP PUBLIC SYNONYM SLIC_XA_V;

CREATE PUBLIC SYNONYM SLIC_XA_V FOR AMD_OWNER.SLIC_XA_V;


DROP PUBLIC SYNONYM SLIC_XB_V;

CREATE PUBLIC SYNONYM SLIC_XB_V FOR AMD_OWNER.SLIC_XB_V;


DROP PUBLIC SYNONYM SLIC_XC_V;

CREATE PUBLIC SYNONYM SLIC_XC_V FOR AMD_OWNER.SLIC_XC_V;


DROP PUBLIC SYNONYM SLIC_XH_V;

CREATE PUBLIC SYNONYM SLIC_XH_V FOR AMD_OWNER.SLIC_XH_V;


DROP PUBLIC SYNONYM SLIC_XI_V;

CREATE PUBLIC SYNONYM SLIC_XI_V FOR AMD_OWNER.SLIC_XI_V;


DROP PUBLIC SYNONYM SPO_BACKORDER_TYPE_V;

CREATE PUBLIC SYNONYM SPO_BACKORDER_TYPE_V FOR AMD_OWNER.SPO_BACKORDER_TYPE_V;


DROP PUBLIC SYNONYM SPO_BOM_DETAIL_V;

CREATE PUBLIC SYNONYM SPO_BOM_DETAIL_V FOR AMD_OWNER.SPO_BOM_DETAIL_V;


DROP PUBLIC SYNONYM SPO_BOM_LOCATION_CONTRACT_V;

CREATE PUBLIC SYNONYM SPO_BOM_LOCATION_CONTRACT_V FOR AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V;


DROP PUBLIC SYNONYM SPO_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM SPO_CAUSAL_TYPE_V FOR AMD_OWNER.SPO_CAUSAL_TYPE_V;


DROP PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_LINE_V;

CREATE PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V;


DROP PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_V FOR AMD_OWNER.SPO_CONFIRMED_REQUEST_V;


DROP PUBLIC SYNONYM SPO_CONTRACT_CAUSAL_FORECAST_V;

CREATE PUBLIC SYNONYM SPO_CONTRACT_CAUSAL_FORECAST_V FOR AMD_OWNER.SPO_CONTRACT_CAUSAL_FORECAST_V;


DROP PUBLIC SYNONYM SPO_CONTRACT_CAUSAL_V;

CREATE PUBLIC SYNONYM SPO_CONTRACT_CAUSAL_V FOR AMD_OWNER.SPO_CONTRACT_CAUSAL_V;


DROP PUBLIC SYNONYM SPO_CURRENT_PERIOD_V;

CREATE PUBLIC SYNONYM SPO_CURRENT_PERIOD_V FOR AMD_OWNER.SPO_CURRENT_PERIOD_V;


DROP PUBLIC SYNONYM SPO_DEMAND_FORECAST_TYPE_V;

CREATE PUBLIC SYNONYM SPO_DEMAND_FORECAST_TYPE_V FOR AMD_OWNER.SPO_DEMAND_FORECAST_TYPE_V;


DROP PUBLIC SYNONYM SPO_DEMAND_TYPE_V;

CREATE PUBLIC SYNONYM SPO_DEMAND_TYPE_V FOR AMD_OWNER.SPO_DEMAND_TYPE_V;


DROP PUBLIC SYNONYM SPO_EXCEPTION_V;

CREATE PUBLIC SYNONYM SPO_EXCEPTION_V FOR AMD_OWNER.SPO_EXCEPTION_V;


DROP PUBLIC SYNONYM SPO_FLAG_V;

CREATE PUBLIC SYNONYM SPO_FLAG_V FOR AMD_OWNER.SPO_FLAG_V;


DROP PUBLIC SYNONYM SPO_FX_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM SPO_FX_LP_DEMAND_FORECAST_V FOR AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V;


DROP PUBLIC SYNONYM SPO_INTERFACE_BATCH_V;

CREATE PUBLIC SYNONYM SPO_INTERFACE_BATCH_V FOR AMD_OWNER.SPO_INTERFACE_BATCH_V;


DROP PUBLIC SYNONYM SPO_IN_TRANSIT_TYPE_V;

CREATE PUBLIC SYNONYM SPO_IN_TRANSIT_TYPE_V FOR AMD_OWNER.SPO_IN_TRANSIT_TYPE_V;


DROP PUBLIC SYNONYM SPO_LOCATION_V;

CREATE PUBLIC SYNONYM SPO_LOCATION_V FOR AMD_OWNER.SPO_LOCATION_V;


DROP PUBLIC SYNONYM SPO_LP_ATTRIBUTE_V;

CREATE PUBLIC SYNONYM SPO_LP_ATTRIBUTE_V FOR AMD_OWNER.SPO_LP_ATTRIBUTE_V;


DROP PUBLIC SYNONYM SPO_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM SPO_LP_BACKORDER_V FOR AMD_OWNER.SPO_LP_BACKORDER_V;


DROP PUBLIC SYNONYM SPO_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM SPO_LP_DEMAND_FORECAST_V FOR AMD_OWNER.SPO_LP_DEMAND_FORECAST_V;


DROP PUBLIC SYNONYM SPO_LP_DEMAND_V;

CREATE PUBLIC SYNONYM SPO_LP_DEMAND_V FOR AMD_OWNER.SPO_LP_DEMAND_V;


DROP PUBLIC SYNONYM SPO_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM SPO_LP_IN_TRANSIT_V FOR AMD_OWNER.SPO_LP_IN_TRANSIT_V;


DROP PUBLIC SYNONYM SPO_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM SPO_LP_ON_HAND_V FOR AMD_OWNER.SPO_LP_ON_HAND_V;


DROP PUBLIC SYNONYM SPO_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM SPO_LP_OVERRIDE_V FOR AMD_OWNER.SPO_LP_OVERRIDE_V;


DROP PUBLIC SYNONYM SPO_MTBF_TYPE_V;

CREATE PUBLIC SYNONYM SPO_MTBF_TYPE_V FOR AMD_OWNER.SPO_MTBF_TYPE_V;


DROP PUBLIC SYNONYM SPO_ON_HAND_TYPE_V;

CREATE PUBLIC SYNONYM SPO_ON_HAND_TYPE_V FOR AMD_OWNER.SPO_ON_HAND_TYPE_V;


DROP PUBLIC SYNONYM SPO_OVERRIDE_REASON_TYPE_V;

CREATE PUBLIC SYNONYM SPO_OVERRIDE_REASON_TYPE_V FOR AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V;


DROP PUBLIC SYNONYM SPO_OVERRIDE_TYPE_V;

CREATE PUBLIC SYNONYM SPO_OVERRIDE_TYPE_V FOR AMD_OWNER.SPO_OVERRIDE_TYPE_V;


DROP PUBLIC SYNONYM SPO_PARAMETER_V;

CREATE PUBLIC SYNONYM SPO_PARAMETER_V FOR AMD_OWNER.SPO_PARAMETER_V;


DROP PUBLIC SYNONYM SPO_PART_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM SPO_PART_CAUSAL_TYPE_V FOR AMD_OWNER.SPO_PART_CAUSAL_TYPE_V;


DROP PUBLIC SYNONYM SPO_PART_MTBF_V;

CREATE PUBLIC SYNONYM SPO_PART_MTBF_V FOR AMD_OWNER.SPO_PART_MTBF_V;


DROP PUBLIC SYNONYM SPO_PART_PLANNED_PART_V;

CREATE PUBLIC SYNONYM SPO_PART_PLANNED_PART_V FOR AMD_OWNER.SPO_PART_PLANNED_PART_V;


DROP PUBLIC SYNONYM SPO_PART_UPGRADED_PART_V;

CREATE PUBLIC SYNONYM SPO_PART_UPGRADED_PART_V FOR AMD_OWNER.SPO_PART_UPGRADED_PART_V;


DROP PUBLIC SYNONYM SPO_PART_V;

CREATE PUBLIC SYNONYM SPO_PART_V FOR AMD_OWNER.SPO_PART_V;


DROP PUBLIC SYNONYM SPO_PERIOD_V;

CREATE PUBLIC SYNONYM SPO_PERIOD_V FOR AMD_OWNER.SPO_PERIOD_V;


DROP PUBLIC SYNONYM SPO_REQUEST_TYPE_V;

CREATE PUBLIC SYNONYM SPO_REQUEST_TYPE_V FOR AMD_OWNER.SPO_REQUEST_TYPE_V;


DROP PUBLIC SYNONYM SPO_SUPERSESSION_TYPE_V;

CREATE PUBLIC SYNONYM SPO_SUPERSESSION_TYPE_V FOR AMD_OWNER.SPO_SUPERSESSION_TYPE_V;


DROP PUBLIC SYNONYM SPO_USER_PART_V;

CREATE PUBLIC SYNONYM SPO_USER_PART_V FOR AMD_OWNER.SPO_USER_PART_V;


DROP PUBLIC SYNONYM SPO_USER_TYPE_V;

CREATE PUBLIC SYNONYM SPO_USER_TYPE_V FOR AMD_OWNER.SPO_USER_TYPE_V;


DROP PUBLIC SYNONYM SPO_USER_USER_TYPE_V;

CREATE PUBLIC SYNONYM SPO_USER_USER_TYPE_V FOR AMD_OWNER.SPO_USER_USER_TYPE_V;


DROP PUBLIC SYNONYM SPO_USER_V;

CREATE PUBLIC SYNONYM SPO_USER_V FOR AMD_OWNER.SPO_USER_V;


DROP PUBLIC SYNONYM SPO_X_IMP_INTERFACE_BATCH_V;

CREATE PUBLIC SYNONYM SPO_X_IMP_INTERFACE_BATCH_V FOR AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V;


DROP PUBLIC SYNONYM SRU_PN_V;

CREATE PUBLIC SYNONYM SRU_PN_V FOR AMD_OWNER.SRU_PN_V;


DROP PUBLIC SYNONYM V8_CAPABILITYREQUIREMENTLVL4_V;

CREATE PUBLIC SYNONYM V8_CAPABILITYREQUIREMENTLVL4_V FOR AMD_OWNER.V8_CAPABILITYREQUIREMENTLVL4_V;


DROP PUBLIC SYNONYM WECM_ACTIVE_NIINS_V;

CREATE PUBLIC SYNONYM WECM_ACTIVE_NIINS_V FOR AMD_OWNER.WECM_ACTIVE_NIINS_V;


DROP PUBLIC SYNONYM WECM_L11_V;

CREATE PUBLIC SYNONYM WECM_L11_V FOR AMD_OWNER.WECM_L11_V;


DROP PUBLIC SYNONYM X_BOM_DETAIL_V;

CREATE PUBLIC SYNONYM X_BOM_DETAIL_V FOR AMD_OWNER.X_BOM_DETAIL_V;


DROP PUBLIC SYNONYM X_BOM_LOCATION_CONTRACT_V;

CREATE PUBLIC SYNONYM X_BOM_LOCATION_CONTRACT_V FOR AMD_OWNER.X_BOM_LOCATION_CONTRACT_V;


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_V;


DROP PUBLIC SYNONYM X_LP_ATTRIBUTE_V;

CREATE PUBLIC SYNONYM X_LP_ATTRIBUTE_V FOR AMD_OWNER.X_LP_ATTRIBUTE_V;


DROP PUBLIC SYNONYM X_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM X_LP_BACKORDER_V FOR AMD_OWNER.X_LP_BACKORDER_V;


DROP PUBLIC SYNONYM X_LP_DEMAND_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_V FOR AMD_OWNER.X_LP_DEMAND_V;


DROP PUBLIC SYNONYM X_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM X_LP_IN_TRANSIT_V FOR AMD_OWNER.X_LP_IN_TRANSIT_V;


DROP PUBLIC SYNONYM X_LP_LEAD_TIME_V;

CREATE PUBLIC SYNONYM X_LP_LEAD_TIME_V FOR AMD_OWNER.X_LP_LEAD_TIME_V;


DROP PUBLIC SYNONYM X_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM X_LP_ON_HAND_V FOR AMD_OWNER.X_LP_ON_HAND_V;


DROP PUBLIC SYNONYM X_NETWORK_PART_V;

CREATE PUBLIC SYNONYM X_NETWORK_PART_V FOR AMD_OWNER.X_NETWORK_PART_V;


DROP PUBLIC SYNONYM X_PART_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM X_PART_CAUSAL_TYPE_V FOR AMD_OWNER.X_PART_CAUSAL_TYPE_V;


DROP PUBLIC SYNONYM X_PART_PLANNED_PART_V;

CREATE PUBLIC SYNONYM X_PART_PLANNED_PART_V FOR AMD_OWNER.X_PART_PLANNED_PART_V;


DROP PUBLIC SYNONYM X_PART_V;

CREATE PUBLIC SYNONYM X_PART_V FOR AMD_OWNER.X_PART_V;


DROP PUBLIC SYNONYM X_USER_PART_V;

CREATE PUBLIC SYNONYM X_USER_PART_V FOR AMD_OWNER.X_USER_PART_V;


DROP PUBLIC SYNONYM X_USER_USER_TYPE_V;

CREATE PUBLIC SYNONYM X_USER_USER_TYPE_V FOR AMD_OWNER.X_USER_USER_TYPE_V;


DROP PUBLIC SYNONYM X_USER_V;

CREATE PUBLIC SYNONYM X_USER_V FOR AMD_OWNER.X_USER_V;


GRANT SELECT ON AMD_OWNER.AMD_DEFAULT_USERS_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.AMD_PEOPLE_ALL_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.AMD_USERS_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.PGOLD_UIMS_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.PGOLD_USE1_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.SPO_USER_TYPE_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.SPO_USER_USER_TYPE_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.SPO_USER_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.X_USER_USER_TYPE_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.X_USER_V TO AMD_ADMIN;

GRANT SELECT ON AMD_OWNER.ACTIVE_PARTS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_2A_CAT1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_DI_DEMANDS_SRANS_CONV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_DI_DEMANDS_SUM_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_DI_INVENTORY_SRAN_CONV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_DI_INVENTORY_SUMMED_W_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_DI_INVENTORY_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_IN_REPAIR_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_PART_INFO2_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_PART_INFO_A_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_PART_INFO_B_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMDII_PART_INFO_C_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_BLIS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_CONSUMABLE_PARTS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_DEFAULT_PLANNERS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_DEFAULT_PLANNER_LOGONS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_FOR_DI_DEMANDS_SUM_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_ISGP_CHILD_NSNS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_ISGP_GROUPS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_ISGP_MASTER_NSNS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_ISGP_RBL_PAIRS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PART_HEADER_V5 TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PART_IDS TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PLANNER_LOGONS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PREFERRED_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_HA TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_HG TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_XA TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_XB TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_XC TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_XI TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_RBL_PAIRS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_REPAIRABLE_PARTS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_RSP_ON_HAND_N_OBJECTIVE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_RSP_SUM_CONSUMABLES_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_RSP_SUM_REPAIRABLES_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_SPO_PARTS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_SPO_TYPES_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_TWOWAY_RBL_PAIRS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DELNSN_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_FILES_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.BSSM_2F_RAMP_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.COMPONENT_LRU_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.COMPONENT_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.DATASYS_LP_OVERRIDE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.DATASYS_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.DATASYS_PLANNER_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.DATASYS_TRANS_PROCESSED_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.FEDLOG_ACTIVE_NIINS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.GOLDSA_ITEM_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.GOLDSA_REQ1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.GOLDSA_WHSE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.LRU_MASTER_LCN_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.LRU_PN_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PARTINFO_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_AUXB_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_CAT1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_CATS$MERGED_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_CGVT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_CHGH_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_FEDC_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_ISGP_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_ITEM_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_LVLS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_MILS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_MLIT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_MLVT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_NSN1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_ORD1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_ORDV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_POI1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_PRC1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_RAMP_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_REQ1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_RSV1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_SC01_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_TMP1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_TRHI_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_VENC_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_VENN_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_WHSE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PGOLD_WIP1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PULL_ORD1_D_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.PULL_ORD1_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_ALL_ITEM_INV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_INV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_ITEMSA_INV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_ITEM_INV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_RAMP_INV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_RAMP_ITEM_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.RSP_WHSE_INV_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HA_SHELF_LIFE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HA_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HB_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HD_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HF_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HG_SMR_CODES_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_HG_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_XA_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_XB_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_XC_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_XH_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_XI_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_BACKORDER_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_BOM_DETAIL_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_BOM_LOCATION_CONTRACT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_CAUSAL_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_CONTRACT_CAUSAL_FORECAST_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_CONTRACT_CAUSAL_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_CURRENT_PERIOD_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_DEMAND_FORECAST_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_DEMAND_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_EXCEPTION_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_FLAG_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_INTERFACE_BATCH_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_IN_TRANSIT_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LOCATION_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_ATTRIBUTE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_BACKORDER_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_DEMAND_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_IN_TRANSIT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_ON_HAND_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_LP_OVERRIDE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_MTBF_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_ON_HAND_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_OVERRIDE_REASON_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_OVERRIDE_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PARAMETER_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PART_CAUSAL_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PART_MTBF_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PART_PLANNED_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PART_UPGRADED_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_PERIOD_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_REQUEST_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_SUPERSESSION_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_USER_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SPO_X_IMP_INTERFACE_BATCH_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SRU_PN_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.V8_CAPABILITYREQUIREMENTLVL4_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.WECM_ACTIVE_NIINS_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.WECM_L11_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_BOM_DETAIL_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_BOM_LOCATION_CONTRACT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_LP_ATTRIBUTE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_LP_BACKORDER_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_LP_IN_TRANSIT_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_LP_ON_HAND_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_NETWORK_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_PART_CAUSAL_TYPE_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_PART_PLANNED_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_PART_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.X_USER_PART_V TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_PART_HEADER_V5 TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_PART_IDS TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PEOPLE_ALL_V TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_FILES_V TO AMD_WRITER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.PARTINFO_V TO AMD_WRITER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_HA TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_HG TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.AMD_PSLMS_XA TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.LRU_MASTER_LCN_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.LRU_PN_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_CAT1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_CGVT_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_CHGH_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_FEDC_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_ISGP_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_ITEM_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_LVLS_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_MILS_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_MLIT_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_MLVT_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_NSN1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_ORD1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_ORDV_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_POI1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_PRC1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_RAMP_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_REQ1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_RSV1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_SC01_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_TMP1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_TRHI_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_UIMS_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_USE1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_VENC_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_VENN_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_WHSE_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.PGOLD_WIP1_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HA_SHELF_LIFE_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HA_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HB_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HD_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HF_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HG_SMR_CODES_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_HG_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_XA_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_XB_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_XC_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_XH_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.SLIC_XI_V TO BSRM_LOADER;

GRANT SELECT ON AMD_OWNER.AMD_PEOPLE_ALL_V TO BSSM_OWNER;
