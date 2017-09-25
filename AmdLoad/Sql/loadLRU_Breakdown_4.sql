/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   15 Jul 2011 09:39:44  $
    $Workfile:   loadLRU_Breakdown_4.sql  $

      Rev 1.0   15 Jul 2011 09:39:44   zf297a
   Added link variable */

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on


exec amd_owner.mta_truncate_table('amd_owner.lru_breakdown_4','reuse storage');


 insert into amd_owner.lru_breakdown_4
(
PGOLD_CAT1_IMS,
LRU_PN,
COMPONENT_LRU_PN,
SRU_PN,
PGOLD_CAT_OR_XB_NOUN,
PGOLD_CAT1_SOS,
SLIC_PN,
PGOLD_CAT1_NSN,
NSN_AMD_FORMAT,
PGOLD_CAT1_AAC,
LCN,
SLIC_PCCN_PLISN,
INDENTURE,
PCCN,
PLISN,
SLIC_WUC,
SLIC_SMRC,
TOCC,
USABLE_FROM,
USABLE_TO,
VENDOR,
VENDOR_NO        
)
select
PGOLD_CAT1_IMS,
LRU_PN,
COMPONENT_LRU_PN,
SRU_PN,
PGOLD_CAT_OR_XB_NOUN,
PGOLD_CAT1_SOS,
SLIC_PN,
PGOLD_CAT1_NSN,
NSN_AMD_FORMAT,
PGOLD_CAT1_AAC,
LCN,
SLIC_PCCN_PLISN,
INDENTURE,
PCCN,
PLISN,
SLIC_WUC,
SLIC_SMRC,
TOCC,
USABLE_FROM,
USABLE_TO,
VENDOR,
VENDOR_NO        
from amd_owner.lru_breakdown_4_v;

commit ;
