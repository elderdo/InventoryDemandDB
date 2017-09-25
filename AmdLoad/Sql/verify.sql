-- 1. get the number of spo_prime_parts's
select count(distinct spo_prime_part_no) 
from amd_sent_to_a2a
where action_code <> 'D' ;

-- 2. check for bogus spo_locations
select *
from amd_spare_networks
where 
(spo_location is not null and (substr(spo_location,1,1) = ' '
or substr(spo_location,length(spo_location),1) = ' ') 
) 
or 
(mob is not null and (substr(mob,1,1) = ' ' or substr(mob,length(mob),1) = ' '))

-- 3.
select count(distinct spo_location) 
from amd_spare_networks
where action_code <> 'D'
and spo_location is not null ;

-- 4.
select count(*), site_location 
from tmp_a2a_loc_part_override
group by site_location
order by count(*) ;

-- 5.
select spo_prime_parts, locations, spo_prime_parts * locations from
(select count(distinct spo_prime_part_no) spo_prime_parts 
from amd_sent_to_a2a
where action_code <> 'D' ),
(select count(distinct spo_location) locations 
from amd_spare_networks
where action_code <> 'D'
and spo_location is not null) ;

-- 6.
select spo_prime_parts, locations, spo_prime_parts * locations, locPartOverrides,
	   case when ((spo_prime_parts * locations) = locPartOverrides) then 'FULL A2A LOAD'
	   else 'NOT A FULL A2A LOAD'
	   end TestDescription
from (select count(distinct spo_prime_part_no) spo_prime_parts 
from amd_sent_to_a2a
where action_code <> 'D' ),
(select count(distinct spo_location) locations 
from amd_spare_networks
where action_code <> 'D'
and spo_location is not null),
(select count(*) locPartOverrides from tmp_a2a_loc_part_override) ;

-- 7.
select count(*), site_location 
from tmp_a2a_loc_part_override
group by site_location
having site_location = 'VIRTUAL UAB' or site_location = 'VIRTUAL COD'
order by count(*) ;

-- 8.
-- RSP
select * from tmp_a2a_inv_info
where part_no in ('711420-4','765-101000-515','767-101000-511',
'768-101000-509','770-101000-509','773-101000-507')
and site_location like '%RSP' ;

-- 9.
select nsn, substr(part_no,1,20) from amd_spare_parts
where part_no in ('711420-4','765-101000-515','979806-11') ;

-- 10.
select nsn, substr(part_no,1,20), amd_rbl_pairs.* 
from amd_spare_parts,
amd_rbl_pairs
where part_no in ('711420-4','765-101000-515','979806-11') 
and new_nsn = nsn ;

-- 11.
select substr(current_stock_number,1,16) current_stock_number, 
substr(sc,8,6) sc, wrm_balance, spram_balance, hpmsk_balance, 
total_inaccessible_qty 
from ramp 
where current_stock_number in ('6130-01-446-4497','1680-01-510-9122','4810-01-334-6399', '1680-01-483-1392') 
and substr(sc,8,6) = 'FB6242' ;

-- 12.
select * from amd_rsp
where part_no in ('711420-4','765-101000-515','979806-11')
and loc_sid = 6 ;

-- 13.
select * from tmp_a2a_inv_info
where part_no in ('1160824-1-2','17B1B2412-1') ;

-- 14.
select * from tmp_a2a_repair_info
where part_no in ('1150824-1-2','17B1B2412-1') ;

-- 15.
select * from tmp_a2a_order_info
where part_no in ('3290408-1-1','17B1E7000-1') ;

-- 16.
select * from tmp_a2a_in_transits
where part_no in ('1150824-1-1','17B1U404-1') ;

-- 17.
select * from tmp_a2a_backorder_info
where part_no in ('72213','747-3120-011') ;

-- 18.
select substr(part_no,1,20) part_no, nsn, unit_cost
from amd_spare_parts
where part_no in ('17B1B2412-1','839890-401','17B1E7000-1','1150824-1-1','1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
and action_code <> 'D' ;

-- 19.
select substr(prime_part_no,1,20), nsn, nsi_sid, smr_code
from amd_national_stock_items
where prime_part_no in ('17B1B2412-1','3290408-1-1', '17B1E7000-1',
'1150824-1-1', '1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
and action_code <> 'D' ;

-- 20.
select substr(part_no,1,20) part_no, 
nsi_sid, assignment_date, unassignment_date, prime_ind
from amd_nsi_parts
where part_no in ('17B1B2412-1','3290408-1-1', '17B1E7000-1',
'1150824-1-1', '1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
order by part_no, assignment_date ;

-- 21.
select substr(part_no,1,20) part_no, 
loc_sid, inv_qty
from amd_on_hand_invs
where part_no in ('17B1B2412-1','3290408-1-1', '17B1E7000-1',
'1150824-1-1', '1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
and action_code <> 'D'
order by part_no, loc_sid ;

-- 22.
select substr(part_no,1,20) part_no, 
loc_sid, repair_qty, order_no
from amd_in_repair
where part_no in ('17B1B2412-1','3290408-1-1', '17B1E7000-1',
'1150824-1-1', '1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
and action_code <> 'D'
order by part_no, loc_sid ;

-- 23.
select substr(part_no,1,20) part_no, 
loc_sid, order_qty, gold_order_number
from amd_on_order
where part_no in ('17B1B2412-1','3290408-1-1', '17B1E7000-1',
'1150824-1-1', '1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
and action_code <> 'D'
order by part_no, loc_sid ;

-- 24.
select substr(part_no,1,20) part_no, 
to_loc_sid, quantity, serviceable_flag, document_id
from amd_in_transits
where part_no in ('17B1B2412-1','3290408-1-1', '17B1E7000-1',
'1150824-1-1', '1150824-1-2', '17B1U4044-1', '3290174-2-1', '3290408-1-1')
and action_code <> 'D'
order by part_no, to_loc_sid ;

-- 25.
select substr(part_no,1,20) part_no, 
loc_sid, quantity_due, substr(req_id,1,15) req_id
from amd_reqs
where part_no in ('72213','747-3120-011','747-4800-001')
and action_code <> 'D'
order by part_no, loc_sid ;
