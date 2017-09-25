/*
      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   26 Sep 2007 10:24:14  $
    $Workfile:   SiteAsset_DEL.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\SiteAsset_DEL.sql.-arc  $
/*   
/*      Rev 1.3   26 Sep 2007 10:24:14   zf297a
/*   Send Data Source 2 planner/bems_id when the data source 1 no longer exists and the data source 2 planner/bems_id does not exist in Data Systems.
*/
SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'005' as tran_priority,
'SITE_RESP_ASSET_MGR' as tran_type,
action_code as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
SITE_RESP_ASSET_MGR,
to_number(replace(TOOL_LOGON_ID,';','')) TOOL_LOGON_ID
FROM tmp_a2a_site_resp_asset_mgr
where action_code = 'D'
union
SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'005' as tran_priority,
'SITE_RESP_ASSET_MGR' as tran_type,
'D' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
planner_code SITE_RESP_ASSET_MGR,
to_number(replace(a.logon_id,':','')) TOOL_LOGON_ID
from amd_planner_logons a,
amd_users
where data_source = 2
and a.action_code <> 'D'
and a.logon_id = bems_id
and  exists (select null from amd_planner_logons 
            where a.planner_code = planner_code
            and a.logon_id <> logon_id
            and data_source = 1
            and action_code <> 'D')
and exists (select null from datasys_planner_v
            where a.planner_code = planner_code
            and a.logon_id = spo_user)       

