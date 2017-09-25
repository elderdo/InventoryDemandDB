/*
      $Author:   zf297a  $
    $Revision:   1.5  $
        $Date:   26 Sep 2007 10:23:06  $
    $Workfile:   SiteAsset.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\SiteAsset.sql.-arc  $
/*   
/*      Rev 1.5   26 Sep 2007 10:23:06   zf297a
/*   Send Data Source 2 planner/bems_id when the data source 1 no longer exists and the data source 2 planner/bems_id does not exist in Data Systems. 
*/
SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'004' as tran_priority,
'SITE_RESP_ASSET_MGR' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
SITE_RESP_ASSET_MGR,
to_number(TOOL_LOGON_ID) TOOL_LOGON_ID
FROM tmp_a2a_site_resp_asset_mgr
where action_code in ('A','C')
union
SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'004' as tran_priority,
'SITE_RESP_ASSET_MGR' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
planner_code SITE_RESP_ASSET_MGR,
to_number(LOGON_ID) TOOL_LOGON_ID
from amd_planner_logons a,
amd_users
where data_source = 2
and a.action_code <> 'D'
and a.logon_id = bems_id
and  not exists (select null from amd_planner_logons 
            where a.planner_code = planner_code
            and a.logon_id <> logon_id
            and data_source = 1
            and action_code <> 'D') 
and not exists (select null from datasys_planner_v
            where a.planner_code = planner_code
           and a.logon_id = spo_user)

