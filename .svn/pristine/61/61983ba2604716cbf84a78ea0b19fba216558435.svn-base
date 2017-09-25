/*
	$Author:   zf297a  $
      $Revision:   1.9  $
          $Date:   23 Jun 2008 09:53:58  $
      $Workfile:   PartInfo.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\PartInfo.sql.-arc  $
/*   
/*      Rev 1.9   23 Jun 2008 09:53:58   zf297a
/*   Removed rounding and check for null value - just accept the column as is per Aaron Shiley's suggestion on 6/19/2008.
/*   
/*      Rev 1.8   14 Feb 2008 13:36:56   zf297a
/*   No longer need to have it always return 'T' for IS_EXEMPT since the table should now have the correct value.
/*   
/*      Rev 1.7   13 Feb 2008 09:58:34   zf297a
/*   Make sure IS_EXEMPT is T for true  Xzero
/*   
/*      Rev 1.6   27 Sep 2007 18:48:18   zf297a
/*   Removed ph_prime_part and ph_prime_cage
/*   
/*      Rev 1.5   Aug 06 2007 11:06:00   c402417
/*   Add attribute29, 30  to meet consumables requirements.

*/

SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'003' as tran_priority,
'PART_INFO' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
PH_CAGE_CODE,
PH_PART_NO,
PH_LEAD_TIME,
PH_LEAD_TIME_TYPE,
pi.SOURCE_SYSTEM,
CAGE_CODE,
CAGE_CODE CAGE_CODE2,
pi.PART_NO,
UNIT_ISSUE,
replace(NOUN,'&','&amp;') NOUN,
RCM_IND,
HAZMAT_CODE,
pi.SHELF_LIFE,
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
decode(PLANNED_PART,'P','T','F') planned_part,
THIRD_PARTY_FLAG,
mtbf,
Nvl(MTBF_TYPE,'Engineering Flight Hours') mtbf_type,
SHELF_LIFE_ACTION_CODE,
PREFERRED_SMRCODE,
decode(DECAY_RATE,null,'0',DECAY_RATE) decay_rate,
INDENTURE,
IS_EXEMPT,
IGNORE_WEIGHT_AND_VOLUME,
IS_ORDER_POLICY_REQ_BASE,
nvl(price,4999.99) price,
'T' generate_new_buy,
'F' generate_repair,
'T' generate_allocation,
'T' generate_transhipment,
decode(part_no,ph_prime_part,'1','2') seq,
ph_prime_part as spo_prime_part_no,
decode(ansi.wesm_indicator,null,null,'WESM Part') attribute_29,
decode(bsi.nsn, null, null, 'Bench Stock Item') attribute_30
FROM tmp_a2a_part_info pi, amd_part_header_v5, amd_national_stock_items ansi,
(select distinct  n.nsn, prime_part_no
 from amd_demands d, amd_national_stock_items n
 where d.doc_no like 'B%'
 and d.nsi_sid = n.nsi_sid
 and n.action_code != 'D') bsi 
where pi.part_no = ph_part_no
and pi.part_no = ansi.prime_part_no(+)
and pi.action_code in ('A','C')
and ansi.action_code(+) <> 'D'
and concat(pi.nsn_fsc,pi.nsn_niin) = bsi.nsn(+)
