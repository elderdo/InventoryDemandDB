SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 2009/03/12 13:52 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_confirmed_request_line_v (confirmed_request,
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
                                                                     timestamp,
                                                                     attribute_1,
                                                                     attribute_2,
                                                                     attribute_3,
                                                                     attribute_4,
                                                                     attribute_5,
                                                                     attribute_6,
                                                                     attribute_7,
                                                                     attribute_8
                                                                    )
as
   select confirmed_request, line, location, part, proposed_request,
          request_date, due_date, quantity_ordered, quantity_received,
          request_status, supplier_location, timestamp, attribute_1,
          attribute_2, attribute_3, attribute_4, attribute_5, attribute_6,
          attribute_7, attribute_8
     from spoc17v2.v_confirmed_request_line@stl_escm_link;


DROP PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_LINE_V;

CREATE PUBLIC SYNONYM SPO_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V;


GRANT SELECT ON AMD_OWNER.SPO_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;


