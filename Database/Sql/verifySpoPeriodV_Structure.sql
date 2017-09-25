set serveroutput on size 100000

declare
cursor ids is
select id,begin_date,end_date from spo_period_v 
order by id;
prev_id number := null ;
prev_begin_date date := null ;
prev_end_date date := null ;
ok boolean := true ;
begin
    for rec in ids loop
        if prev_id is null then
            prev_id := rec.id ;
            prev_begin_date := trunc(rec.begin_date) ;
            prev_end_date := trunc(rec.end_date) ;
        else
            if rec.id <> prev_id + 1
            and rec.begin_date <> add_months(trunc(prev_begin_date),1)
            and rec.end_date <> add_months(trunc(prev_end_date),1) then
                dbms_output.put_line('spo_period_v is in error for id=' || rec.id || ' prev_id=' || prev_id 
                || ' prev_begin_date: '|| to_char(prev_begin_date,'MM/DD/YYYY') || ' begin_date: ' || to_char(rec.begin_date,'MM/DD/YYYY')
                || ' prev_end_date: ' || to_char(prev_end_date,'MM/DD/YYYY') || 'end_date: ' || to_char(rec.end_date,'MM/DD/YYYY') ) ;
                ok := false ;
                exit ;
            else                
                prev_id := rec.id ;
                prev_begin_date := trunc(rec.begin_date) ;
                prev_end_date := trunc(rec.end_date) ;
            end if ;                
        end if ;            
    end loop ;
    if ok then
        dbms_output.put_line('spo_period_v has the correct structure for x_lp_demnad_forecast_v') ;
    end if ;
end ;
/


exit
