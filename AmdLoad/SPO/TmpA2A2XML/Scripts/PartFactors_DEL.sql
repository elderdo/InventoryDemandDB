/*
	  $Author:   zf297a  $
	$Revision:   1.1  $
	    $Date:   14 Feb 2008 10:47:34  $
	$Workfile:   PartFactors_DEL.sql  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\PartFactors_DEL.sql.-arc  $
/*   
/*      Rev 1.1   14 Feb 2008 10:47:34   zf297a
/*   Filter out consumables
*/

SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'007' as tran_priority,
'PART_FACTORS' as tran_type,
action_code as tran_action,
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
WHERE action_code = 'D' 
and amd_utils.isPartConsumableYorN(part_no) = 'N'
