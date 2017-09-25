SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LOCATION_V;

/* Formatted on 2008/11/26 10:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_location_v (ID,
                                                       NAME,
                                                       location_type,
                                                       description,
                                                       is_dgi_location,
                                                       max_part_unit_weight,
                                                       max_part_unit_volume,
                                                       TIMESTAMP,
                                                       attribute_1,
                                                       attribute_2,
                                                       attribute_3,
                                                       attribute_4,
                                                       attribute_5,
                                                       attribute_6,
                                                       attribute_7,
                                                       attribute_8
                                                      )
AS
   SELECT "ID", "NAME", "LOCATION_TYPE", "DESCRIPTION", "IS_DGI_LOCATION",
          "MAX_PART_UNIT_WEIGHT", "MAX_PART_UNIT_VOLUME", "TIMESTAMP",
          "ATTRIBUTE_1", "ATTRIBUTE_2", "ATTRIBUTE_3", "ATTRIBUTE_4",
          "ATTRIBUTE_5", "ATTRIBUTE_6", "ATTRIBUTE_7", "ATTRIBUTE_8"
     FROM spoc17v2.v_location@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LOCATION_V;

CREATE PUBLIC SYNONYM SPO_LOCATION_V FOR AMD_OWNER.SPO_LOCATION_V;


GRANT SELECT ON AMD_OWNER.SPO_LOCATION_V TO AMD_READER_ROLE;


