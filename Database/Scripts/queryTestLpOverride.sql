select * from SPOV22ICSV2.X_IMP_INTERFACE_BATCH 
where interface = 'X_IMP_LP_OVERRIDE' 
order by batch desc ; --23892152

update SPOV22ICSV2.X_IMP_INTERFACE_BATCH 
set exception = null;

commit;

select * from SPOV22ICSV2.exception where id = 1368;

--delete SPOV22ICSV2.X_IMP_LP_OVERRIDE where batch < 24215347 

rollback

--exec spoc17v2.pr_imp();

select * from SPOV22ICSV2.X_IMP_LP_OVERRIDE
order by Location

where exception is not null

select distinct exception from SPOV22ICSV2.X_IMP_LP_OVERRIDE

select count(*) from SPOV22ICSV2.X_IMP_LP_OVERRIDE where exception is not null

select count(*) from SPOV22ICSV2.X_IMP_INTERFACE_BATCH 

select count(*) from SPOV22ICSV2.LP_OVERRIDE;

select count(*) from AMD_LP_OVERRIDE_V;

select count(*) from C17DEVLPR.TMP_AMD_LP_OVERRIDE


select count(*) from SPOV22ICSV2.X_IMP_LP_OVERRIDE where batch = 13571912 and exception is not null;

select distinct substr(OVERRIDE_USER, 2) from SPOV22ICSV2.X_IMP_LP_OVERRIDE where substr(OVERRIDE_USER, 1, 1) = '0' and batch = 24215347; 

select * from SPOV22ICSV2.X_IMP_LP_OVERRIDE where rownum = 1;

select count(*) from AMD_LP_OVERRIDE_V;

call spov22icsv2.pkg_escmspo.truncate_table('X_IMP_LP_OVERRIDE');

commit;

delete SPOV22ICSV2.X_IMP_INTERFACE_BATCH; 

select count(*) FROM amd_owner.tmp_a2a_loc_part_override@lgb_amd_link 

where override_user is null;

select * from C17DEVLPR.TMP_AMD_LP_OVERRIDE;

select * from spov22icsv2.v_lp_override

--AMDD:
select count(*) from SPO_LP_OVERRIDE_V;

select count(*) from X_LP_OVERRIDE_V;

select count(*) from SPO_LP_OVERRIDE_V where part is null;

select count(*) from X_LP_OVERRIDE_V where 
part is null or
LOCATION is null or
override_type is null or
quantity is null or
override_reason is null or
override_user is null;



select * from SPOV22ICSV2.LP_OVERRIDE; 

select count(*) from SPOV22ICSV2.LP_OVERRIDE; 

select SPOV22ICSV2.interface_sequence.nextval from dual;

select SPOV22ICSV2.batch_sequence.nextval from dual;


select * from SPOV22ICSV2.x_imp_lp_override
where exception is not null
and part || location in (select part || location from SPOV22ICSV2.x_imp_lp_override where exception is null)

select * from SPOV22ICSV2.x_imp_lp_override
where exception is not null
and location in (select location from SPOV22ICSV2.x_imp_lp_override where exception is null)


select * from SPOV22ICSV2.x_imp_lp_override where ACTION = 'UPD'

select * from SPOV22ICSV2.x_imp_lp_override where part like '%-3E'

select *  from SPOV22ICSV2.lp_override where to_char(part) = '172BS101-3E'

select count(*) from SPOV22ICSV2.x_imp_lp_override
where exception is not null
and exception = 1806


and part || location in (select to_char(part || location) from SPOV22ICSV2.lp_override)


select * from SPOV22ICSV2.x_imp_lp_override
where exception is not null
and location in (select to_char(location) from SPOV22ICSV2.lp_override);



select distinct OVERRIDE_USER from SPOV22ICSV2.X_IMP_LP_OVERRIDE where batch = 24215346; 

select distinct OVERRIDE_USER from amd_lp_override_v where OVERRIDE_USER not in 
(select distinct OVERRIDE_USER from SPOV22ICSV2.LP_OVERRIDE);

delete SPOV22ICSV2.LP_OVERRIDE;

delete SPOV22ICSV2.X_IMP_LP_OVERRIDE;

delete SPOV22ICSV2.X_IMP_INTERFACE_BATCH where interface = 'X_IMP_LP_OVERRIDE' 

commit;

select count(*) from SPOV22ICSV2.v_lp_override

select distinct OVERRIDE_USER from amd_lp_override_v 
minus 
select distinct TO_CHAR(OVERRIDE_USER) from SPOV22ICSV2.LP_OVERRIDE;

select distinct TO_CHAR(OVERRIDE_USER) from SPOV22ICSV2.LP_OVERRIDE;



select distinct OVERRIDE_USER from amd_lp_override_v 
minus 
select distinct TO_CHAR(ID) from SPOV22ICSV2.SPO_USER


select distinct TO_CHAR(ID) from SPOV22ICSV2.SPO_USER order by 1 desc
where id IN (select distinct OVERRIDE_USER from amd_lp_override_v)



select distinct NAME from SPOV22ICSV2.SPO_USER 
where NAME = '332765'

IN (select distinct OVERRIDE_USER from amd_lp_override_v)

select distinct OVERRIDE_USER from SPOV22ICSV2.LP_OVERRIDE
where Override_user in (select distinct ID  from SPOV22ICSV2.SPO_USER)

select * from SPOV22ICSV2.EXCEPTION
where id in (1806, 1807, 1810)

commit;

alter session enable parallel dml;
alter session disable parallel dml; 

truncate table TMP_AMD_LP_OVERRIDE;
commit;

select sysdate from dual