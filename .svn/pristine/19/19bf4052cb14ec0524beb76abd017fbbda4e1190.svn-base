SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_DEMAND_V;

/* Formatted on 2009/01/23 14:25 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_demand_v (transaction_id,
                                                      location,
                                                      part,
                                                      contract,
                                                      demand_type,
                                                      demand_date,
                                                      customer_location,
                                                      product_serial_number,
                                                      quantity,
                                                      timestamp
                                                     )
as
   select doc_no || '-' || LPAD (TO_CHAR (loc_sid), 4, '0') transaction_id,
          amd_utils.getspolocation (loc_sid) location,
          parts.spo_prime_part_no part, 'C17' contract, 'General' demand_type,
          doc_date demand_date, null customoer_location,
          null product_serial_number, quantity, dmnd.last_update_dt timestamp
     from amd_demands dmnd,
          amd_national_stock_items items,
          amd_spare_parts parts
    where dmnd.action_code <> 'D'
      and dmnd.nsi_sid = items.nsi_sid
      and items.prime_part_no = parts.part_no
      and parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_DEMAND_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_V FOR AMD_OWNER.X_LP_DEMAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_V TO AMD_READER_ROLE;


