CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_NAT_STOCK_ITEMS_AFTER_TRIG
AFTER INSERT OR UPDATE
ON AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DISABLE
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.3
        $Date:   13 Feb 2015
    $Workfile:   AMD_NAT_STOCK_ITEMS_AFTER_TRIG.trg  $
    
        Rev 1.3 commented out old Spo code
/*   
/*      Rev 1.2   19 Sep 2007 21:15:56   zf297a
/*   Removed reference to amd_log table, which is only used in development for debugging purposes.
/*   
/*      Rev 1.1   19 Sep 2007 17:08:20   zf297a
/*   Added PVCS keywords
/*   
/*      Rev 1.0   Sep 19 2007 17:03:16   zf297a
/*   Initial revision.

******************************************************************************/
  action_code varchar2(1) ;
  cursor equivalentParts is
    select part_no, nomenclature, mfgr, unit_of_issue, nsn, 
    amd_preferred_pkg.GetPreferredValue(:new.smr_code_cleaned, :new.smr_code) smr_code,
    amd_preferred_pkg.getPreferredValue(:new.mtbdr_cleaned, :new.mtbdr_computed, :new.mtbdr) mtbdr,            
    amd_preferred_pkg.getPreferredValue(:new.planner_code_cleaned, :new.planner_code) planner_code,
    amd_preferred_pkg.getPreferredValue(:new.unit_cost_cleaned, unit_cost) price
    from amd_spare_parts
    where part_no <> :new.prime_part_no
    and :new.nsn = nsn 
    and action_code <> amd_defaults.DELETE_ACTION ;
    

begin
   if inserting then
    action_code := amd_defaults.INSERT_ACTION ;
   else 
    action_code := amd_defaults.UPDATE_ACTION ;
   end if ;
   /*
   if amd_utils.isDiff(:old.planner_code, :new.planner_code)
   or amd_utils.isDiff(:old.planner_code_cleaned, :new.planner_code_cleaned) then
    for rec in equivalentParts loop
        if amd_utils.isRepairableSmrCode( preferred_smr_code => rec.smr_code)        
           and a2a_pkg.isPartValid(partNo => rec.part_no, preferredSmrCode => rec.smr_code, 
                preferredMtbdr => rec.mtbdr, preferredPlannerCode => rec.planner_code) THEN
                        
            a2a_pkg.insertTmpA2APartInfo(mfgr => rec.mfgr, part_no => rec.part_no, 
                unit_issue => rec.unit_of_issue, nomenclature => rec.nomenclature, rcm_ind => SUBSTR(rec.smr_code,6,1) , 
                nsn => :new.nsn, planner_code => rec.planner_code, mtbdr => rec.mtbdr, preferred_smrcode => rec.smr_code,
                indenture => a2a_pkg.getIndenture(rec.smr_code), action_code => action_code, price => rec.price) ;
        else
            if amd_utils.isPartConsumable(preferred_smr_code => rec.smr_code,
                preferred_planner_code => rec.planner_code, nsn => :new.nsn) 
               and a2a_consumables_pkg.isPartValid(part_no => rec.part_no, 
                smr_code => rec.smr_code, nsn => :new.nsn, planner_code => rec.planner_code,
                    mtbdr => rec.mtbdr) then
                a2a_consumables_pkg.insertPartInfo(action_code => action_code, 
                    part_no => rec.part_no, nomenclature => rec.nomenclature,
                    mfgr => rec.mfgr,  unit_issue => rec.unit_of_issue, 
                    smr_code => rec.smr_code, nsn => :new.nsn, planner_code => rec.planner_code,
	                third_party_flag => a2a_pkg.THIRD_PARTY_FLAG, mtbdr => rec.mtbdr, 
                    price => rec.price) ;
            end if ;                
        end if ;                
            
    end loop ;
        
   end if ;
   */
end AMD_NAT_STOCK_ITEMS_AFTER_TRIG ;
/