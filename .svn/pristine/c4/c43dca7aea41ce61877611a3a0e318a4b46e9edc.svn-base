host mkdir &1

@@tmpA2ABackorderInfoDump.sql &1
@@tmpA2ABomDetailDump.sql &1
@@tmpA2ADemandsDump.sql &1
@@tmpA2AExtForecastDump.sql &1
@@tmpA2AInTransitsDump.sql &1
@@tmpA2AInvInfoDump.sql &1
@@tmpA2ALocPartLeadTimeDump.sql &1
@@tmpA2ALocPartOverrideDump.sql &1
@@tmpA2AOrderInfoLineDump.sql &1
@@tmpA2APartAltRelDeleteDump.sql &1
@@tmpA2APartEffectivityDump.sql &1
@@tmpA2APartFactorsDump.sql &1
@@tmpA2APartInfoDump.sql &1
@@tmpA2APartPricingDump.sql &1
@@tmpA2ARepairInfoDump.sql &1
@@tmpA2ARepairInvInfoDump.sql &1
@@tmpA2ASiteRespAssetMgrDump.sql &1
@@tmpA2ASpoUsersDump.sql &1

define TimeStamp = to_char(sysdate,'YYYY_MM_DD_HHMISS')

column mc new_value myTimeStamp noprint

select &TimeStamp mc from dual ;

host mkdir &1./&2

host tar cvf &1./&2./&myTimeStamp._tmpa2a.tar &1./*.csv

host gzip &1./&2./&myTimeStamp._tmpa2a.tar

host rm -f &1./*.csv

