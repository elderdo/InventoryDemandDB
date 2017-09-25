SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_CURRENT_PERIOD_V;

/* Formatted on 2009/05/11 13:33 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.amd_current_period_v (id,
                                                             begin_date,
                                                             end_date,
                                                             year_number,
                                                             month_number,
                                                             week_number,
                                                             calendar_year_number,
                                                             calendar_month_number,
                                                             source
                                                            )
as
   select id, begin_date, end_date, year_number, month_number, week_number,
          calendar_year_number, calendar_month_number,
          'FIXED_CURRENT_PERIOD' source
     from spo_period_v, spo_fixed_current_period_v
    where exists (select 1
                    from spo_flag_v
                   where name = 'CURRENT_PERIOD' and UPPER (value) = 'FIXED')
      and period = id
   union
   select id, begin_date, end_date, year_number, month_number, week_number,
          calendar_year_number, calendar_month_number, 'SYSDATE' source
     from spo_period_v
    where (   not exists (
                      select 1
                        from spo_flag_v
                       where name = 'CURRENT_PERIOD'
                             and UPPER (value) = 'FIXED')
           or not exists (select 1
                            from spo_fixed_current_period_v, spo_period_v
                           where period = id)
          )
      and TRUNC (begin_date, 'mon') = TRUNC (SYSDATE, 'mon');


DROP PUBLIC SYNONYM AMD_CURRENT_PERIOD_V;

CREATE PUBLIC SYNONYM AMD_CURRENT_PERIOD_V FOR AMD_OWNER.AMD_CURRENT_PERIOD_V;


GRANT SELECT ON AMD_OWNER.AMD_CURRENT_PERIOD_V TO AMD_READER_ROLE;


