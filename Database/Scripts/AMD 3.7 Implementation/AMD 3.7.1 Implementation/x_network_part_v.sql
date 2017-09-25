SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_NETWORK_PART_V;

/* Formatted on 2009/03/31 16:04 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_network_part_v (network,
                                                         part,
                                                         smr_code,
                                                         timestamp
                                                        )
as
   select   case
               when is_reparable = 'T'
               and SUBSTR (attribute_10, 3, 1) = 'O'
                  then 'LRU'
               when is_reparable = 'T' and SUBSTR (attribute_10, 3, 1) <> 'O'
                  then 'Non LRU'
               else 'Consumables'
            end network,
            name as part, attribute_10, timestamp
       from x_part_v
   order by network, part;


DROP PUBLIC SYNONYM X_NETWORK_PART_V;

CREATE PUBLIC SYNONYM X_NETWORK_PART_V FOR AMD_OWNER.X_NETWORK_PART_V;


GRANT SELECT ON AMD_OWNER.X_NETWORK_PART_V TO AMD_READER_ROLE;


