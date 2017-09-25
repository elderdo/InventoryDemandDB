CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SENT_TO_A2A_AFTER_TRIG
AFTER UPDATE
ON AMD_OWNER.AMD_SENT_TO_A2A 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
	    $Date:   01 Nov 2007 09:36:00  $
    $Workfile:   amd_sent_to_a2a_after_trig.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.1 Implementation\amd_sent_to_a2a_after_trig.sql.-arc  $
/*   
/*      Rev 1.0   01 Nov 2007 09:36:00   zf297a
/*   Initial revision.
/*   
/*      Rev 1.10   31 Oct 2007 09:18:16   zf297a
/*   moved procedure altPart to be within the trigger and moved the code related to the altPart within the trigger.  Added end triggerName at the end of the trigger.
/*   
/*      Rev 1.9   Oct 30 2007 15:06:10   c402417
/*   Added procedure partAlt for table tmp_a2a_part_alt.
/*   
/*      Rev 1.8   21 Jun 2007 16:11:08   zf297a
/*   Added sleep routine to make sure the key for amd_sent_to_a2a_history is unique by at least 1 second.
/*   
/*      Rev 1.7   12 Jun 2007 21:59:14   zf297a
/*   Added a raise application error whenever a duplicate condition occurs for amd_sent_to_a2a_history so the value of the key and other related data will get displayed in the error message.
/*   
/*      Rev 1.6   22 Mar 2007 09:03:58   zf297a
/*   Record the "old" values in the history table.
/*   
/*      Rev 1.5   01 Mar 2007 10:59:56   zf297a
/*   Record all changes to any amd_sent_to_a2a in amd_sent_to_a2a_history
/*   
/*      Rev 1.4   Oct 20 2006 12:24:40   zf297a
/*   Fixed time format - MI for minutes not MM which is the format for months.
/*   
/*      Rev 1.3   Nov 30 2005 11:04:04   zf297a
/*   use a2a_pkg.populateBomDetail procedure
/*   
/*      Rev 1.2   Sep 21 2005 11:24:48   zf297a
/*   Added populateBomDetail
/*   
/*      Rev 1.1   Jul 15 2005 11:51:06   zf297a
/*   changed range_from and range_to to all upper case.
/*   
/*      Rev 1.0   Jul 11 2005 15:10:24   zf297a
/*   Initial revision.
*/		 
    spo_prime_part_no_chg    amd_sent_to_a2a_history.SPO_PRIME_PART_NO_CHG%type ;
    action_code_chg          amd_sent_to_a2a_history.ACTION_CODE_CHG%type ;
    transaction_date_chg     amd_sent_to_a2a_history.TRANSACTION_DATE_CHG%type ;
    spo_prime_part_chg_date_chg amd_sent_to_a2a_history.SPO_PRIME_PART_CHG_DATE_CHG%type ;
        
    procedure altPart(alternatePart in varchar2,primePart in varchar2, action in varchar2) is  
		procedure doUpdate is
		begin
			update tmp_a2a_part_alt
            set tran_action = action
			where part_no = alternatePart
			and prime_part = primePart ;				
		end doUpdate ;
	begin
		insert into tmp_a2a_part_alt
		(part_no, prime_part, tran_action)
		values (alternatePart, primePart, action) ;
	exception when standard.dup_val_on_index then
		doUpdate ;
	end altPart ;
    
	PROCEDURE errorMsg(sqlFunction IN VARCHAR2, 
			  tableName IN VARCHAR2, 
			  location IN NUMBER) IS
	BEGIN
		dbms_output.put_line('sqlcode('||SQLCODE||') sqlerrm('|| SQLERRM||')') ;
		dbms_output.put_line('part_no=' || :NEW.part_no || ' action_code=' || :NEW.action_code) ;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => SUBSTR(sqlFunction,1,20),
						                        pTableName  => SUBSTR(tableName,1,20)),
				pData_line_no => location,
				pData_line    => 'amd_sent_to_a2a_after_trig', 
				pKey_1 => SUBSTR(:NEW.part_no,1,50),
				pKey_2 => SUBSTR(:NEW.action_code,1,50),
				pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS'),
				pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
	END ErrorMsg;

	procedure sleep(
							secs in number) is
		ss varchar2(2);
	begin
		ss := to_char(sysdate,'ss');
		while to_number(ss) + secs > to_number(to_char(sysdate,'ss'))
		loop
			null;
		end loop;
	end;
	
	
	PROCEDURE populatePartEffectivity IS
	BEGIN
		 INSERT INTO TMP_A2A_PART_EFFECTIVITY
		 (part_no, mdl, series, effectivity_type, range_from, range_to, range_flag, qpei, customer, action_code, last_update_dt)
		 VALUES
		 (:NEW.spo_prime_part_no, 'C17', 'A', 'P', 'C17FULL','C17FULL','B','1','AF', :NEW.action_code, SYSDATE) ;
	EXCEPTION
		 WHEN standard.DUP_VAL_ON_INDEX THEN
		 	  BEGIN
			 	  UPDATE TMP_A2A_PART_EFFECTIVITY
				  SET action_code = :NEW.action_code,
				  last_update_dt = SYSDATE
				  WHERE part_no = :NEW.spo_prime_part_no ;
			  EXCEPTION WHEN OTHERS THEN
			  	  errormsg(sqlFunction => 'update',
				    tableName => 'tmp_a2a_part_effectivity',
					location => 10) ;
			  END ;
	     WHEN OTHERS THEN
		   errormsg(sqlFunction => 'insert',
		     tableName => 'tmp_a2a_part_effectivity',
			 location => 20) ;
	       RAISE;
		 
	END populatePartEffectivity ;

   PROCEDURE populateBomDetail IS
	BEGIN
		 a2a_pkg.populateBomDetail(part_no => :NEW.spo_prime_part_no,
		 	included_part => :NEW.spo_prime_part_no,
			action_code => :NEW.action_code) ;
	END populateBomDetail ;
    
        procedure doInsert is
    begin
        insert into amd_sent_to_a2a_history
        (part_no,  spo_prime_part_no, spo_prime_part_no_chg, action_code, action_code_chg, 
         transaction_date, transaction_date_chg, spo_prime_part_chg_date, spo_prime_part_chg_date_chg)
         values (:OLD.part_no, :OLD.spo_prime_part_no, spo_prime_part_no_chg, :OLD.action_code, action_code_chg,
         :OLD.transaction_date, transaction_date_chg, :OLD.spo_prime_part_chg_date, spo_prime_part_chg_date_chg) ;
    end doInsert ;
     
BEGIN
	IF :NEW.spo_prime_part_no IS NOT NULL THEN
		populatePartEffectivity ;
		populateBomDetail ;
	END IF ;
    if amd_utils.ISDIFF(:OLD.spo_prime_part_no, :NEW.spo_prime_part_no)
    or amd_utils.ISDIFF(:OLD.ACTION_CODE, :NEW.ACTION_CODE)
    or amd_utils.ISDIFF(:OLD.transaction_date,  :NEW.transaction_date)
    or amd_utils.ISDIFF(:OLD.spo_prime_part_chg_date,:NEW.spo_prime_part_chg_date) then
        if amd_utils.ISDIFF(:OLD.spo_prime_part_no, :NEW.spo_prime_part_no) then
            spo_prime_part_no_chg := 'Y' ;
        else
            spo_prime_part_no_chg := null ;
        end if ;
        if amd_utils.ISDIFF(:OLD.ACTION_CODE, :NEW.ACTION_CODE) then
            action_code_chg := 'Y' ;
        else
            action_code_chg := null ;
        end if ;
        if amd_utils.ISDIFF(:OLD.transaction_date,  :NEW.transaction_date) then
            transaction_date_chg := 'Y' ;
        else
            transaction_date_chg := null ;
        end if ;
        if amd_utils.ISDIFF(:OLD.spo_prime_part_chg_date,:NEW.spo_prime_part_chg_date) then 
            spo_prime_part_chg_date_chg := 'Y' ;
        else
            spo_prime_part_chg_date_chg := null ;
        end if ;
         
        begin
            doInsert ;
        exception when standard.DUP_VAL_ON_INDEX then
            
            sleep(1) ;
            
            begin
                doInsert ;
            exception when standard.dup_val_on_index then
                -- sleep didn't work            
                raise_application_error(-20888,'part=' || :OLD.part_no || ' spoPrime=' || :OLD.spo_prime_part_no
                  || ' prtchg=' || spo_prime_part_no_chg || ' ac=' || :OLD.action_code || ' acchg=' || action_code_chg
                  || ' sysdate=' || sysdate || ' sqlcode=' || sqlcode || ' err=' || sqlerrm) ;
            end ;
                         
        end ;
         
    end if ;
    
    if :old.spo_prime_part_no is null then
        -- this part does not currently have a prime part
        -- if there is a prime part and this is an alternate part
        if :new.spo_prime_part_no is not null and :new.spo_prime_part_no <> :new.part_no then
            -- assign the alternate part to this new prime part
            altPart(alternatePart => :new.part_no,primePart => :new.spo_prime_part_no , action => Amd_defaults.INSERT_ACTION);
        end if ;
    else
        -- there is a prime part currently assigned this part        
        if amd_utils.isDiff(:new.spo_prime_part_no,:old.spo_prime_part_no) then
            -- the prime part no has changed
            if :new.spo_prime_part_no is null then
                -- check if this is an alternate part
                if :old.spo_prime_part_no <> :new.part_no then
                    -- delete the old spo_prime_part no from this alternate part_no
                    altPart(alternatePart => :new.part_no,primePart => :old.spo_prime_part_no , action => Amd_defaults.DELETE_ACTION);
                end if ;                        
            else
                -- check if this is an alternate part
                if :new.spo_prime_part_no <> :new.part_no then
                    -- delete the old spo_prime_part no from this alternate part_no
                    altPart(alternatePart => :new.part_no,primePart => :old.spo_prime_part_no , action => Amd_defaults.DELETE_ACTION);
                    -- assign the :new.spo_prime_part_no to this alternate part_no
                    altPart(alternatePart => :new.part_no,primePart => :new.spo_prime_part_no, action => Amd_defaults.INSERT_ACTION);
                end if ;                        
            end if ;
        end if ;
    end if ;                    
EXCEPTION WHEN OTHERS THEN	 
	errorMsg(sqlFunction => 'populate', 
		tableName => 'bom & effectivity', 
		location => 30) ;
	RAISE;
END AMD_SENT_TO_A2A_AFTER_TRIG ;
/
