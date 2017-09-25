CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SPARE_PARTS_AFTER_UPD_TRIG
AFTER UPDATE
ON AMD_OWNER.AMD_SPARE_PARTS 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.4  $
    $Date:   07 Aug 2009 10:11:14  $
    $Workfile:   AMD_SPARE_PARTS_AFTER_UPD_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SPARE_PARTS_AFTER_UPD_TRIG.trg.-arc  $
/*   
/*      Rev 1.4   07 Aug 2009 10:11:14   zf297a
/*   Use common sleep procedure
/*   
/*      Rev 1.3   16 Mar 2009 10:37:26   zf297a
/*   Record only spo parts 
/*   
/*      Rev 1.2   13 Mar 2009 11:42:56   zf297a
/*   Use revised amd_spo_part_history.  Save all the fields of interest and indicate if they have changed with their _chg column - Y for changed and N for not changed.
/*   
/*      Rev 1.1   02 Mar 2009 17:54:02   zf297a
/*   Fixed the name of the history table: amd_spo_parts_history.
/*   
/*      Rev 1.0   02 Mar 2009 12:36:00   zf297a
/*   Initial revision.
*
**/

    is_spo_part_chg         varchar2(1 byte) := 'N' ;
    is_repairable_chg       varchar2(1 byte) := 'N' ;
    is_consumable_chg       varchar2(1 byte) := 'N' ;
    spo_prime_part_no_chg   varchar2(1 byte) := 'N' ;
    unit_cost_chg           varchar2(1 byte) := 'N' ;
        
    
    PROCEDURE errorMsg(sqlFunction IN VARCHAR2, 
              tableName IN VARCHAR2, 
              location IN NUMBER) IS
    BEGIN
        dbms_output.put_line('sqlcode('||SQLCODE||') sqlerrm('|| SQLERRM||')') ;
        dbms_output.put_line('part_no=' || :NEW.part_no) ;
        Amd_Utils.InsertErrorMsg (
            pLoad_no => Amd_Utils.GetLoadNo(pSourceName => SUBSTR(sqlFunction,1,20),
                    pTableName  => SUBSTR(tableName,1,20)),
            pData_line_no => location,
            pData_line    => 'amd_spare_parts_after_upd_trig', 
            pKey_1 => SUBSTR(:NEW.part_no,1,50),
            pKey_2 => sysdate,
            pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
    END ErrorMsg;

    
    procedure doInsert is
    begin
        insert into amd_spo_parts_history
        (part_no,  is_spo_part, is_spo_part_chg,  is_repairable, is_repairable_chg, 
         is_consumable, is_consumable_chg, spo_prime_part_no, spo_prime_part_no_chg, unit_cost, unit_cost_chg)
        values (:OLD.part_no, :old.is_spo_part, is_spo_part_chg, :old.is_repairable, is_repairable_chg,
         :old.is_consumable, is_consumable_chg, :OLD.spo_prime_part_no,  spo_prime_part_no_chg,
         :old.unit_cost, unit_cost_chg) ; 
    end doInsert ;
    
     
BEGIN
    if :old.is_spo_part = 'Y' or :new.is_spo_part = 'Y' then -- only record for spo parts
    
        if amd_utils.ISDIFF(:old.spo_prime_part_no,:new.spo_prime_part_no)
        or amd_utils.isDiff(:old.is_spo_part,:new.is_spo_part)
        or amd_utils.isDiff(:old.is_repairable,:new.is_repairable)
        or amd_utils.isDiff(:old.is_consumable,:new.is_consumable) 
        or amd_utils.isDiff(:old.unit_cost,:new.unit_cost) then
        
            if amd_utils.isDiff(:old.spo_prime_part_no,:new.spo_prime_part_no) then
                spo_prime_part_no_chg := 'Y' ;
            else
                spo_prime_part_no_chg := 'N' ;
            end if ;
            if amd_utils.isDiff(:old.is_spo_part,:new.is_spo_part) then
                is_spo_part_chg := 'Y' ;
            else
                is_spo_part_chg := 'N' ;
            end if ;
            if amd_utils.isDiff(:old.is_repairable,:new.is_repairable) then
                is_repairable_chg := 'Y' ;
            else
                is_repairable_chg := 'N' ;
            end if ;
            if amd_utils.isDiff(:old.is_consumable,:new.is_consumable) then
                is_consumable_chg := 'Y' ;
            else
                is_consumable_chg := 'N' ;
            end if ;
            if amd_utils.isDiff(:old.unit_cost,:new.unit_cost) then
                unit_cost_chg := 'Y' ;
            else
                unit_cost_chg := 'N' ;
            end if;                                                                                                            
             
            <<insertSpoPartHist>>
            begin
                doInsert ;
            exception when standard.DUP_VAL_ON_INDEX then
                
                sleep(1) ;
                
                <<tryAgain>>
                begin
                    doInsert ;
                exception when standard.dup_val_on_index then
                    -- sleep didn't work            
                    raise_application_error(-20888,'part=' || :OLD.part_no || ' spoPrime=' || :OLD.spo_prime_part_no
                      || ' sysdate=' || sysdate || ' sqlcode=' || sqlcode || ' err=' || sqlerrm) ;
                end tryAgain ;
                             
            end insertSpoPartHist ;
        end if ; 
    end if ;               
        
EXCEPTION WHEN OTHERS THEN     
    errorMsg(sqlFunction => 'spo_part_changed', 
        tableName => 'amd_spo_part_history', 
        location => 30) ;
    RAISE;
END AMD_spare_part_AFTER_upd_TRIG ;
/
