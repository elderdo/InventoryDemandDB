/*
	$Author:   zf297a  $
      $Revision:   1.4  $
          $Date:   14 Feb 2008 10:38:12  $
      $Workfile:   PartFactors.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\PartFactors.sql.-arc  $
/*   
/*      Rev 1.4   14 Feb 2008 10:38:12   zf297a
/*   Filter out consumable parts
/*   
/*      Rev 1.3   13 Feb 2008 08:49:18   zf297a
/*   Added nrts <> 0 as a filter
/*   
/*      Rev 1.2   12 Feb 2008 15:24:42   zf297a
/*   use records with  the following condition  (cmdmd_rate <> 0 or criticality_code <> 0 or cmdmd_rate <> 0)
/*   
/*      Rev 1.1   12 Feb 2008 14:58:24   zf297a
/*   Make sure  cmdmd_rate <> 0 
/*   and criticality_code <> 0
/*   and cmdmd_rate <> 0
/*   to eliminate meaningless data.

*/

SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'PART_FACTORS' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
SOURCE_SYSTEM,
'' as CAGE_CODE,
PART_NO,
MTTR,
RTS,
NRTS,
CMDMD_RATE as CONDEMNATION_RATE,
BASE_NAME as SITE_LOCATION,
CRITICALITY_CODE as CRITICALITY
FROM tmp_a2a_part_factors
where 
action_code in ('A','C')
and (nrts <> 0 
	or criticality_code <> 0
	or cmdmd_rate <> 0)
and amd_utils.isPartConsumableYorN(part_no) = 'N'
