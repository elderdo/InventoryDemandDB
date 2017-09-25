SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_SENT_TO_A2A_V;

/* Formatted on 2009/03/02 17:49 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_sent_to_a2a_v (part_no,
                                                          spo_prime_part_no,
                                                          action_code,
                                                          transaction_date,
                                                          spo_prime_part_chg_date
                                                         )
as
   select /*+ index(hist amd_spo_parts_history_nk01) index(hist amd_spo_parts_history_nk02)  */
          hist.part_no part_no, hist.spo_prime_part_no spo_prime_part_no,
          action_code, hist.last_update_dt transaction_date,
          spo_prime_part_chg_date
     from amd_spo_parts_history hist, amd_spare_parts parts
    where hist.part_no = parts.part_no
      and hist.last_update_dt in (select min (last_update_dt)
                                    from amd_spo_parts_history a
                                   where a.part_no = hist.part_no);


DROP PUBLIC SYNONYM AMD_SENT_TO_A2A_V;

CREATE PUBLIC SYNONYM AMD_SENT_TO_A2A_V FOR AMD_OWNER.AMD_SENT_TO_A2A_V;


GRANT SELECT ON AMD_OWNER.AMD_SENT_TO_A2A_V TO AMD_READER_ROLE;


