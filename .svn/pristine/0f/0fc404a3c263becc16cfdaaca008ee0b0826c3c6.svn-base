/*
     $Author:   zf297a  $
   $Revision:   1.7  $
       $Date:   03 Oct 2007 16:21:40  $
   $Workfile:   PartInfo_DEL.sql  $
        $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\PartInfo_DEL.sql.-arc  $
/*   
/*      Rev 1.7   03 Oct 2007 16:21:40   zf297a
/*   removed ph_prime_part and ph_prime_cage from union'ed query.
/*   
/*      Rev 1.6   27 Sep 2007 18:50:02   zf297a
/*   Removed ph_prime_part and ph_prime_cage.
/*   
/*      Rev 1.5   06 Aug 2007 09:24:04   zf297a
/*   Added 2nd replace for the noun column to handle ampersands in the generated xml
/*   
/*      Rev 1.4   30 Jul 2007 11:05:14   zf297a
/*   Added a replace function for the noun column that makes sure that an ampersand is converted to &amp; which is required by xml.
/*   
/*      Rev 1.3   Dec 12 2006 12:10:12   zf297a
/*   Added PVCS keywords
*/
SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'006' as tran_priority,
'PART_INFO' as tran_type,
pi.action_code as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
PH_CAGE_CODE,
PH_PART_NO,
PH_LEAD_TIME,
PH_LEAD_TIME_TYPE,
pi.SOURCE_SYSTEM,
CAGE_CODE,
pi.PART_NO,
UNIT_ISSUE,
replace(NOUN,'&','&amp;') noun,
RCM_IND,
HAZMAT_CODE,
SHELF_LIFE,
EQUIPMENT_TYPE,
NSN_COG,
NSN_MCC,
NSN_FSC,
NSN_NIIN,
NSN_SMIC_MMAC,
NSN_ACTY,
ESSENTIALITY_CODE,
RESP_ASSET_MGR,
UNIT_PACK_CUBE,
UNIT_PACK_QTY,
UNIT_PACK_WEIGHT,
UNIT_PACK_WEIGHT_MEASURE,
ELECTRO_STATIC_DISCHARGE,
PERF_BASED_LOG_INFO,
PLANNED_PART,
THIRD_PARTY_FLAG,
MTBF,
Nvl(MTBF_TYPE,'Engineering Flight Hours') mtbf_type,
SHELF_LIFE_ACTION_CODE,
PREFERRED_SMRCODE,
DECAY_RATE,
INDENTURE,
IS_EXEMPT,
IGNORE_WEIGHT_AND_VOLUME,
IS_ORDER_POLICY_REQ_BASE,
nvl(price,4999.99) price,
'T' generate_new_buy,
'T' generate_repair,
'T' generate_allocation
FROM tmp_a2a_part_info pi, amd_part_header_v5
where pi.part_no = ph_part_no
and pi.action_code = 'D'
union
SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'006' as tran_priority,
'PART_INFO' as tran_type,
pi.action_code as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
nvl(parts.mfgr,'99999') PH_CAGE_CODE,
parts.part_no PH_PART_NO,
0 as PH_LEAD_TIME,
'NEW-BUY' PH_LEAD_TIME_TYPE,
pi.SOURCE_SYSTEM,
parts.mfgr CAGE_CODE,
pi.PART_NO,
UNIT_ISSUE,
replace(NOUN,'&','&amp;') noun,
RCM_IND,
HAZMAT_CODE,
pi.SHELF_LIFE,
pi.EQUIPMENT_TYPE,
NSN_COG,
NSN_MCC,
NSN_FSC,
NSN_NIIN,
NSN_SMIC_MMAC,
NSN_ACTY,
ESSENTIALITY_CODE,
RESP_ASSET_MGR,
UNIT_PACK_CUBE,
UNIT_PACK_QTY,
UNIT_PACK_WEIGHT,
UNIT_PACK_WEIGHT_MEASURE,
ELECTRO_STATIC_DISCHARGE,
PERF_BASED_LOG_INFO,
PLANNED_PART,
THIRD_PARTY_FLAG,
MTBF,
Nvl(MTBF_TYPE,'Engineering Flight Hours') mtbf_type,
SHELF_LIFE_ACTION_CODE,
PREFERRED_SMRCODE,
DECAY_RATE,
INDENTURE,
IS_EXEMPT,
IGNORE_WEIGHT_AND_VOLUME,
IS_ORDER_POLICY_REQ_BASE,
nvl(price,4999.99) price,
'T' generate_new_buy,
'T' generate_repair,
'T' generate_allocation
from tmp_a2a_part_info pi,
amd_spare_parts parts,
amd_sent_to_a2a sent,
amd_national_stock_items items
where not exists
(select ph_part_no from amd_part_header_v5 where ph_part_no = pi.part_no)
and pi.action_code = 'D'
and pi.part_no = parts.part_no
and pi.part_no = sent.part_no
and sent.spo_prime_part_no = items.PRIME_PART_NO 

