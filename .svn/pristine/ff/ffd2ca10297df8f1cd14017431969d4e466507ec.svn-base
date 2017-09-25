SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_SPO_TYPES_V;

/* Formatted on 2009/06/09 15:50 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_spo_types_v (general_backorder,
                                                        external_demand_forecast,
                                                        general_demand,
                                                        general_in_transit,
                                                        defective_in_transit,
                                                        general_on_hand,
                                                        defective_on_hand,
                                                        tsl_fixed_override,
                                                        rop_fixed_override,
                                                        roq_fixed_override,
                                                        fixed_tsl_load_override_reason,
                                                        flight_hours_causal,
                                                        engineering_flight_hours_mtbf,
                                                        new_buy_request,
                                                        repair_request,
                                                        new_buy_lead_time,
                                                        repair_lead_time,
                                                        two_way_supersession
                                                       )
as
   select (select name
             from spo_backorder_type_v
            where id = 1001) general_backorder,
          (select name
             from spo_demand_forecast_type_v
            where id = 1003) external_demand_forecast,
          (select name
             from spo_demand_type_v
            where id = 1001) general_demand,
          (select name
             from spo_in_transit_type_v
            where id = 1001) general_in_transit,
          (select name
             from spo_in_transit_type_v
            where id = 1004) defective_in_transit,
          (select name
             from spo_on_hand_type_v
            where id = 1001) general_on_hand,
          (select name
             from spo_on_hand_type_v
            where id = 1004) defective_on_hand,
          (select name
             from spo_override_type_v
            where id = 1004) tsl_fixed_override,
          (select name
             from spo_override_type_v
            where id = 1008) rop_fixed_override,
          (select name
             from spo_override_type_v
            where id = 1010) roq_fixed_override,
          (select name
             from spo_override_reason_type_v
            where id = 10001) fixed_load_override_reason,
          (select name
             from spo_causal_type_v
            where id = 1002) flight_hours_causal,
          (select name
             from spo_mtbf_type_v
            where id = 1004) engineering_flight_hours_mtbf,
          (select name
             from spo_request_type_v
            where id = 1001) new_buy_request,
          (select name
             from spo_request_type_v
            where id = 1002) repair_request,
           (select name
             from spo_request_type_v
            where id = 1001) new_buy_lead_time,
          (select name
             from spo_request_type_v
            where id = 1002) repair_lead_time,
          (select name
             from spo_supersession_type_v
            where id = 1002) two_way_supersession
     from DUAL;


DROP PUBLIC SYNONYM AMD_SPO_TYPES_V;

CREATE PUBLIC SYNONYM AMD_SPO_TYPES_V FOR AMD_OWNER.AMD_SPO_TYPES_V;


GRANT SELECT ON AMD_OWNER.AMD_SPO_TYPES_V TO AMD_READER_ROLE;

