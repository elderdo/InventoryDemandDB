/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   10 Aug 2011 23:45:44  $
    $Workfile:   loadLRU_Breakdown.sql  $
         Desc:   This script loads the table amd_owner.lru_breakdown
   using as input amd_owner.lru_master_lcn_v sorted by lcn and an outer join
   of views amd_owner.slic_hg_v and amd_pslms_xb sorted by lcn.   

      Rev 1.0   18 Jul 2011 09:39:44   initial rev
      Rev 1.1   10 Aug 2011 23:45:44   created new view and
                                       defined load algorithm
      Rev 1.2   09 Feb 2012 added more columns to lru_breakdown

*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set serveroutput on size 100000
set echo on

exec amd_owner.mta_truncate_table('amd_owner.lru_breakdown','reuse storage');

declare
TYPE hb_xb_rec
   IS                 record (
     Part_no       amd_owner.slic_hg_v.REFNUMHA%type,
     lcn           amd_owner.slic_hg_v.LSACONXB%type,
     pccn          amd_owner.slic_hg_v.PCCNUMXC%type,
     plisn         amd_owner.slic_hg_v.PLISNOHG%type,
     QPA           number,
     indenture     amd_owner.slic_hg_v.INDCODHG%type,
     slic_smr      amd_owner.slic_hg_v.SMRCODHG%type,
     slic_wuc      amd_owner.slic_hg_v.WRKUCDHG%type,
     tocc          amd_owner.slic_hg_v.TOCCODHG%type,
     slic_cage     amd_owner.slic_hg_v.CAGECDXH%type,
     slic_noun     amd_owner.slic_xb_v.LCNAMEXB%type,
     gold_noun     amd_owner.pgold_cat1_v.noun%type,
     usable_from   whse.user_ref4%type,
     usable_to     whse.user_ref5%type,
     ims           amd_owner.pgold_cat1_v.ims_designator_code%type,
     aac           amd_owner.pgold_cat1_v.user_ref7%type,
     sos           amd_owner.pgold_cat1_v.source_code%type,
     nsn           amd_owner.pgold_cat1_v.nsn%type,
     last_update_dt date
) ;
                                                 -- 123456789012345678 ... ruler
HIGH_VALUES constant amd_owner.slic_hg_v.lsaconxb%type := 'ZZZZZZZZZZZZZZZZZZ' ; 
cursor hg is
/* Formatted on 9/6/2011 10:09:14 AM (QP5 v5.163.1008.3004) */
SELECT DISTINCT amd_owner.slic_hg_v.REFNUMHA Part_no,
                  amd_owner.slic_hg_v.LSACONXB LCN,
                  amd_owner.slic_hg_v.PCCNUMXC PCCN,
                  amd_owner.slic_hg_v.PLISNOHG PLISN,
                  amd_owner.slic_hg_v.QTYASYHG QPA,
                  amd_owner.slic_hg_v.INDCODHG Indenture,
                  amd_owner.slic_hg_v.SMRCODHG SLIC_SMR,
                  amd_owner.slic_hg_v.WRKUCDHG SLIC_WUC,
                  amd_owner.slic_hg_v.TOCCODHG TOCC,
                  case when length(amd_owner.slic_hg_v.CAGECDXH) > 5 then
			substr(trim(amd_owner.slic_hg_v.cagecdxh),1,5)
			else substr(amd_owner.slic_hg_v.cagecdxh,1,5)
		  end SLIC_Cage,
                  amd_owner.slic_xb_v.LCNAMEXB SLIC_Noun,
                  amd_owner.pgold_cat1_v.noun gold_noun,
                  whse.user_ref4 usable_from,
                  whse.user_ref5 usable_to,
                  amd_owner.pgold_cat1_v.ims_designator_code IMS,
                  amd_owner.pgold_cat1_v.user_ref7 aac,
                  amd_owner.pgold_cat1_v.source_code sos,
                  amd_owner.pgold_cat1_v.nsn nsn,
                  SYSDATE
    FROM amd_owner.slic_hg_v,
         amd_owner.slic_xb_v,
         amd_owner.pgold_cat1_v,
         (SELECT part,
                 prime,
                 user_ref4,
                 user_ref5
            FROM amd_owner.pgold_whse_v
           WHERE sc = AMD_DEFAULTS.GETPARAMVALUE ('lru_whse_sc_filter')
                 AND part = prime) whse
   WHERE amd_owner.slic_hg_v.LSACONXB = amd_owner.slic_XB_v.LSACONXB(+)
         AND refnumha = whse.part(+)
         and refnumha = pgold_cat1_v.part(+)
ORDER BY lcn ;
cursor mstr is select lcn from amd_owner.lru_master_lcn_v ;
hg_rec  hb_xb_rec ;
master_lcn amd_owner.lru_master_lcn_v.lcn%type ;
rows_loaded_cnt number := 0 ;
hg_cnt number := 0 ;
mstr_cnt number := 0 ;
eof_mstr boolean := false ;
eof_hg boolean := false ;
procedure readHg is
begin
  if not eof_hg then
    fetch hg into hg_rec  ;
    if hg%notfound then 
      eof_hg := true ;
      hg_rec.lcn := HIGH_VALUES ;
    else
      hg_cnt := hg_cnt + 1 ;
    end if ;        
  end if ;
end readHg ;
procedure readMstr is
begin
  if not eof_mstr then
    fetch mstr into master_lcn ;
    if mstr%notfound then
      eof_mstr := true ;
      master_lcn := HIGH_VALUES ;
    else
      mstr_cnt := mstr_cnt + 1 ;
    end if ;
  end if ;                
end readMstr ;
function matchLcn(master_lcn varchar2, lcn varchar2 ) return boolean is
begin
    return ( length(master_lcn) <= length(lcn) 
                 and master_lcn = substr(lcn,1,length(master_lcn))
             ) ;                    
end matchLcn ;
procedure showRowsLoadedCnt is
begin
  -- show count in increments of 10,000
  if rows_loaded_cnt > 0 and mod(rows_loaded_cnt,10000) = 0 then
    dbms_output.put_line('rows_loaded_cnt=' || rows_loaded_cnt) ;
  end if ;              
end showRowsLoadedCnt ;
procedure loadLruBreakdown is
begin
  insert into amd_owner.lru_breakdown
  values (hg_rec.part_no,master_lcn,
          hg_rec.lcn, hg_rec.pccn,
          hg_rec.plisn,hg_rec.qpa,
          hg_rec.indenture,hg_rec.slic_smr,
          hg_rec.slic_wuc,hg_rec.tocc,
          substr(hg_rec.slic_cage,1,5),hg_rec.slic_noun,
	  hg_rec.gold_noun,
	  hg_rec.usable_from,hg_rec.usable_to,
	  hg_rec.ims,hg_rec.aac,
	  hg_rec.sos,hg_rec.nsn,
          sysdate) ;
  rows_loaded_cnt := rows_loaded_cnt + 1 ;
end loadLruBreakdown ;
begin
  open  hg ;
  open mstr ;
  readHg ;
  readMstr ;
  loop
    if matchLcn(master_lcn,hg_rec.lcn) then
      loadLruBreakdown ;
      readHg ;
    else
      if master_lcn > hg_rec.lcn then
        readHg ;
      else
        readMstr ;
      end if ;
    end if ;                                                                        
    exit when eof_mstr and eof_hg ;
    showRowsLoadedCnt ;
  end loop ;
  close hg ;
  close mstr ;
  dbms_output.put_line('rows_loaded_cnt=' || rows_loaded_cnt) ;
  dbms_output.put_line('hg_cnt=' || hg_cnt) ;
  dbms_output.put_line('mstr_cnt=' || mstr_cnt) ;
end ;
/

commit ;

exit
