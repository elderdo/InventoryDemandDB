select 'insert into i_item_planner_enumeration (item_id, planner_code) values (''' || nsn || ''', ''' || planner_code || ''');'
from amd_national_stock_items
where action_code != 'D'
order by nsn
