SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_PERIOD_V;

/* Formatted on 2009/05/11 13:13 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_period_v (id,
                                                     begin_date,
                                                     end_date,
                                                     year_number,
                                                     month_number,
                                                     week_number,
                                                     calendar_year_number,
                                                     calendar_month_number,
                                                     timestamp
                                                    )
as
   select "ID", "BEGIN_DATE", "END_DATE", "YEAR_NUMBER", "MONTH_NUMBER",
          "WEEK_NUMBER", "CALENDAR_YEAR_NUMBER", "CALENDAR_MONTH_NUMBER",
          "TIMESTAMP"
     from spoc17v2.v_period@stl_escm_link;


DROP PUBLIC SYNONYM SPO_PERIOD_V;

CREATE PUBLIC SYNONYM SPO_PERIOD_V FOR AMD_OWNER.SPO_PERIOD_V;


GRANT SELECT ON AMD_OWNER.SPO_PERIOD_V TO AMD_READER_ROLE;


