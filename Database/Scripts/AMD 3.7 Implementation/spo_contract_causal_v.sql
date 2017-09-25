SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_CONTRACT_CAUSAL_V;

/* Formatted on 2008/12/22 11:26 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_contract_causal_v (location,
                                                              contract,
                                                              contract_type,
                                                              causal_type,
                                                              period,
                                                              quantity,
                                                              timestamp
                                                             )
as
   select "LOCATION", "CONTRACT", "CONTRACT_TYPE", "CAUSAL_TYPE", "PERIOD",
          "QUANTITY", "TIMESTAMP"
     from spoc17v2.v_contract_causal@stl_escm_link;


DROP PUBLIC SYNONYM SPO_CONTRACT_CAUSAL_V;

CREATE PUBLIC SYNONYM SPO_CONTRACT_CAUSAL_V FOR AMD_OWNER.SPO_CONTRACT_CAUSAL_V;


GRANT SELECT ON AMD_OWNER.SPO_CONTRACT_CAUSAL_V TO AMD_READER_ROLE;


