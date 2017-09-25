SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_LEAD_TIME_V;

/* Formatted on 2009/02/11 13:33 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_lead_time_v (location,
                                                         part,
                                                         lead_time_type,
                                                         quantity,
                                                         timestamp
                                                        )
as
   select ntwks.spo_location location, lt.part_no part,
          'REPAIR' lead_time_type, time_to_repair quantity,
          lt.last_update_dt timestamp
     from amd_location_part_leadtime lt,
          amd_spare_networks ntwks,
          amd_spare_parts parts
    where lt.action_code <> 'D'
      and lt.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.is_repairable = 'Y'
      and lt.loc_sid = ntwks.loc_sid
      and ntwks.spo_location = ntwks.loc_id;


DROP PUBLIC SYNONYM X_LP_LEAD_TIME_V;

CREATE PUBLIC SYNONYM X_LP_LEAD_TIME_V FOR AMD_OWNER.X_LP_LEAD_TIME_V;


GRANT SELECT ON AMD_OWNER.X_LP_LEAD_TIME_V TO AMD_READER_ROLE;


