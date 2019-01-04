DROP TRIGGER AMD_OWNER.AMD_DEPOTPARTNER_CHKLOCID_TRIG;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_DEPOTPARTNER_CHKLOCID_TRIG                                             
BEFORE INSERT OR UPDATE OF loc_id ON AMD_OWNER.AMD_DEPOT_PARTNERING_LOCATIONS FOR EACH ROW
WHEN (
new.loc_id IS NOT NULL
      )
DECLARE
   Dummy              varchar2(6);  -- used for cursor fetch below
   Invalid_loc_id EXCEPTION;
   Valid_loc_id   EXCEPTION;
   Mutating_table     EXCEPTION;
   PRAGMA EXCEPTION_INIT (Mutating_table, -4091);

-- Cursor used to verify parent key value exists.  If
-- present, lock parent key's row so it can't be
-- deleted by another transaction until this
-- transaction is committed or rolled back.
  CURSOR Dummy_cursor (LocId varchar2) IS
   SELECT substr(request_id,1,6) FROM req1
      WHERE substr(request_id,1,6) = LocId
         FOR UPDATE OF request_id;
BEGIN
   OPEN Dummy_cursor (:new.loc_id);
   FETCH Dummy_cursor INTO Dummy;

 -- Verify parent key.  If not found, raise user-specified
 -- error number and message.  If found, close cursor
 -- before allowing triggering statement to complete:
   IF Dummy_cursor%NOTFOUND THEN
      RAISE Invalid_loc_id;
   ELSE
      RAISE valid_loc_id;
   END IF;
   CLOSE Dummy_cursor;
EXCEPTION
   WHEN Invalid_loc_id THEN
      CLOSE Dummy_cursor;
      Raise_application_error(-20000, 'Invalid loc_id: '
         || :new.loc_id) ;
   WHEN Valid_loc_id THEN
      CLOSE Dummy_cursor;
   WHEN Mutating_table THEN
      NULL;
END;
/


DROP TRIGGER AMD_OWNER.AMD_LISTS_BEF_DEL;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_LISTS_BEF_DEL
   BEFORE DELETE
   ON AMD_OWNER.AMD_LISTS
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   /******************************************************************************
          Author:   $Author$
        Revision:   $Revision$
            Date:   $Date$

       Rev 1.0   3/27/2017 Douglas Elder Initial revision.
      PURPOSE: Don't allow deletes

   ******************************************************************************/



   myRole   session_roles.role%TYPE;
BEGIN
   BEGIN
      SELECT NULL
        INTO myRole
        FROM DUAL
       WHERE EXISTS
                (SELECT NULL
                   FROM session_roles
                  WHERE role IN ('AMD_ADMIN', 'DEVELOPER'));
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         raise_application_error (
            -20347,
            'You cannot delete a row. Update the action_code to a D, to
            mark it as deleted');
   END;
END AMD_LISTS_bef_del;
/


DROP TRIGGER AMD_OWNER.AMD_LISTS_BEF_INS_UPD;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_LISTS_BEF_INS_UPD
   BEFORE INSERT OR UPDATE
   ON AMD_OWNER.AMD_LISTS
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   /******************************************************************************
          Author:   $Author$
        Revision:   $Revision$
            Date:   $Date$

       Rev 1.0   3/27/2017 Douglas Elder Initial revision.
      PURPOSE: Don't allow deletes

   ******************************************************************************/



   num   NUMBER;
BEGIN
   IF :new.is_number <> 'N'
   THEN
      BEGIN
         num := TO_NUMBER (:new.list_value);
      EXCEPTION
         WHEN INVALID_NUMBER
         THEN
            raise_application_error (-20349, 'List value is not a number');
      END;
   END IF;

   IF UPDATING
   THEN
      IF :new.action_code <> amd_defaults.DELETE_ACTION
      THEN
         :new.action_code := amd_defaults.UPDATE_ACTION;
      END IF;
   END IF;
END AMD_LISTS_bef_ins_upd;
/


DROP TRIGGER AMD_OWNER.AMD_LOC_PART_OVERRIDE_TRG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_LOC_PART_OVERRIDE_TRG1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.amd_location_part_override
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Sep 25 2006 08:31:42  $
    $Workfile:   AMD_LOC_PART_OVERRIDE_TRG1.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_LOC_PART_OVERRIDE_TRG1.trg.-arc  $
/*
/*      Rev 1.0   Sep 25 2006 08:31:42   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.loc_sid = Amd_Location_Part_Override_Pkg.THE_WAREHOUSE_LOC_SID
	and amd_utils.isPartRepairable(:new.part_no) then
	:new.tsl_override_qty := 0 ;
	:new.last_update_dt := sysdate ;
  end if ;
END amd_loc_part_override_trg1 ;
/


DROP TRIGGER AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS_TRIG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS_TRIG1
before insert
on AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS
for each row
--
-- SCCSID:  %M%   %I%   Modified: %G%  %U%
--
--   $Author:   c970408  $
-- $Revision:   1.1  $
--     $Date:   13 Feb 2003 12:11:22  $
-- $Workfile:   AMD_NATIONAL_STOCK_ITEMS_TRIG1.TRG  $
--
-- 02/13/03  FF     Added check to allow user-specific nsi_sids.
--                  Useful when copying data from one db to another.
declare
begin
	if (:new.nsi_sid is null) then
		select amd_nsi_sid_seq.nextval into :new.nsi_sid from dual;
	end if;
end;
/


DROP TRIGGER AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_TRG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_TRG1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
voucher varchar2(2) ;
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.3  $
	    $Date:   Aug 24 2006 10:31:14  $
    $Workfile:   AMD_ON_ORDER_DATE_FILTERS_TRG1.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_ON_ORDER_DATE_FILTERS_TRG1.trg.-arc  $
/*
/*      Rev 1.3   Aug 24 2006 10:31:14   zf297a
/*   Do not allow create_order_date and the scheduled_receipt_date range to be entered at the same time.
/*
/*      Rev 1.2   Aug 22 2006 09:44:00   zf297a
/*   Added check to make sure that any order_create_date is greater than the scheduled_receipt_date_to if it is entered.
/*
/*      Rev 1.1   May 17 2006 14:51:36   zf297a
/*   removed start_date - column is not needed
/*
/*      Rev 1.0   May 17 2006 12:00:34   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if inserting then
   	  begin
   	  	   select distinct substr(gold_order_number,1,2) into voucher from amd_on_order where substr(gold_order_number,1,2) = :new.voucher_prefix ;
	  exception when standard.no_data_found then
		   RAISE_APPLICATION_ERROR(-20000, 'The voucher prefix does not exist in amd_on_order.');
	  end ;
   else
   	   :new.last_update_dt := sysdate ;
	   :new.oracle_userid := user ;
   end if ;
   if :new.calendar_days is not null then
   	  if :new.calendar_days < 0 then
	  	 RAISE_APPLICATION_ERROR(-20001, 'calendar_days must be positive.');
	  end if ;
   	  if :new.scheduled_receipt_date_from is not null then
	  	 RAISE_APPLICATION_ERROR(-20002, 'Cannot have scheduled_receipt_date_from with calendar_days.');
	  elsif :new.scheduled_receipt_date_to is not null then
	  	 RAISE_APPLICATION_ERROR(-20003, 'Cannot have scheduled_receipt_date_to with calendar_days.');
	  end if ;
   else
   	   if :new.scheduled_receipt_date_from is not null then
	   	  if :new.scheduled_receipt_date_to is null then
		  	 RAISE_APPLICATION_ERROR(-20004, 'You must enter scheduled_receipt_date_to.');
		  end if ;
	   else
	   	   if :new.scheduled_receipt_date_to is not null then
		  	 RAISE_APPLICATION_ERROR(-20005, 'You must enter scheduled_receipt_date_from.');
		   end if ;
	   end if ;
	   if :new.scheduled_receipt_date_from > :new.scheduled_receipt_date_to then
		  	 RAISE_APPLICATION_ERROR(-20006, 'scheduled_receipt_date_from must be <= scheduled_receipt_date_to.');
	   else
	   	   :new.calendar_days := null ; -- the calendar days are no longer needed
	   end if ;
   end if ;
   if :new.order_create_date is not null
   and (:new.scheduled_receipt_date_from is not null or :new.scheduled_receipt_date_to is not null) then
	  	 RAISE_APPLICATION_ERROR(-20007, 'Cannot have both order_create_date and scheduled_receipt_date range.');
   end if ;
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END AMD_ON_ORDER_DATE_FILTERS_TRG1;
/


DROP TRIGGER AMD_OWNER.AMD_PART_NEXT_ASSEMBLIES_TRIG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_PART_NEXT_ASSEMBLIES_TRIG1
BEFORE INSERT
ON AMD_OWNER.AMD_PART_NEXT_ASSEMBLIES
FOR EACH ROW
DECLARE
BEGIN
 SELECT amd_part_next_assemblies_seq.NEXTVAL INTO :new.pn_na_sid FROM DUAL;
END;
/


DROP TRIGGER AMD_OWNER.AMD_PART_NEXT_ASSEMBLIES_TRIG2;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_PART_NEXT_ASSEMBLIES_TRIG2
BEFORE UPDATE
OF PN_NA_SID
ON AMD_OWNER.AMD_PART_NEXT_ASSEMBLIES
FOR EACH ROW
DECLARE
BEGIN
 IF :old.pn_na_sid <> :new.pn_na_sid THEN
  RAISE_APPLICATION_ERROR(-20601, 'Can not change pn_na_sid');
 END IF;
END;
/


DROP TRIGGER AMD_OWNER.AMD_SENT_TO_A2A_AFTER_TRIG;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SENT_TO_A2A_AFTER_TRIG
AFTER UPDATE
ON AMD_OWNER.AMD_SENT_TO_A2A
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
	    $Date:   31 Oct 2007 09:23:04  $
    $Workfile:   amd_sent_to_a2a_after_trig.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.1 Implementation\amd_sent_to_a2a_after_trig.sql.-arc  $
/*
/*      Rev 1.0   31 Oct 2007 09:23:04   zf297a
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
          null;
		end doUpdate ;
	begin
      null ;
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
      null;
	EXCEPTION
		 WHEN standard.DUP_VAL_ON_INDEX THEN
		 	  BEGIN
                null;
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
      null;
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


DROP TRIGGER AMD_OWNER.AMD_SITE_ASSET_MGR_BEFORE_TRIG;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SITE_ASSET_MGR_BEFORE_TRIG
before INSERT
ON AMD_OWNER.AMD_SITE_ASSET_MGR REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   05 Nov 2008 09:50:04  $
    $Workfile:   AMD_SITE_ASSET_MGR_BEFORE_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SITE_ASSET_MGR_BEFORE_TRIG.trg.-arc  $
/*
/*      Rev 1.0   05 Nov 2008 09:50:04   zf297a
/*   Initial revision.

*/
wk_bems_id amd_people_all_v.bems_id%type ;
BEGIN
    select bems_id into wk_bems_id from amd_people_all_v
    where :new.bems_id = amd_people_all_v.bems_id;
exception when standard.no_data_found then
    raise_application_error(-20900,'bems_id ' || :new.bems_id || ' does not exist in amd_people_all_v.') ;
END ;
/


DROP TRIGGER AMD_OWNER.AMD_SPARE_NETWORKS_BEF_INS_UPD;

CREATE OR REPLACE TRIGGER AMD_OWNER.amd_spare_networks_bef_ins_upd
BEFORE INSERT OR UPDATE
ON AMD_OWNER.AMD_SPARE_NETWORKS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.3  $
	    $Date:   May 23 2006 10:10:26  $
    $Workfile:   AMD_SPARE_NETWORKS_BEF_INS_UPD.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SPARE_NETWORKS_BEF_INS_UPD.trg.-arc  $
/*
/*      Rev 1.3   May 23 2006 10:10:26   zf297a
/*   Make sure last_update_dt gets filled in
/*
/*      Rev 1.2   May 16 2006 09:49:16   zf297a
/*   Added trim for all varchar2 fields to prevent erroneous leading spaces and to remove unnecessary trailing spaces.
/*
/*
/*
/*      Rev 1.1   Apr 10 2006 08:33:46   zf297a
/*   Trigger automatically removes blanks from all spo_location fields.  So, if the field contains one or more blanks, then the field gets a null value
/*
/*      Rev 1.0   Apr 07 2006 12:42:22   zf297a
/*   Initial revision.
   PURPOSE: Make sure the spo_location is never a blank and gets rid of leading or trailing spaces

******************************************************************************/
BEGIN
	 :new.location_name := trim(:new.location_name) ;
     :new.loc_id := trim(:new.loc_id) ;
  	 :new.loc_type := trim(:new.loc_type) ;
  	 :new.mob := trim(:new.mob) ;
  	 :new.repair_flag := trim(:new.repair_flag) ;
  	 :new.command := trim(:new.command) ;
  	 :new.sub_command := trim(:new.sub_command) ;
  	 :new.icao := trim(:new.icao) ;
  	 :new.calendar_name := trim(:new.calendar_name) ;
	 :new.spo_location := trim(:new.spo_location) ;
	 :new.last_update_dt := sysdate ;
END amd_spare_networks_bef_ins_upd;
/


DROP TRIGGER AMD_OWNER.AMD_SPARE_NETWORKS_TRIG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.amd_spare_networks_trig1
	BEFORE INSERT ON AMD_OWNER.AMD_SPARE_NETWORKS
	FOR EACH ROW
DECLARE
BEGIN
	if (:new.loc_sid is null) then
		SELECT amd_spare_networks_seq.NEXTVAL INTO :new.loc_sid FROM DUAL;
	end if;
END;
/


DROP TRIGGER AMD_OWNER.AMD_SPARE_NETWORKS_TRIG2;

CREATE OR REPLACE TRIGGER AMD_OWNER.amd_spare_networks_trig2
BEFORE UPDATE
OF LOC_SID
ON AMD_OWNER.AMD_SPARE_NETWORKS
FOR EACH ROW
DECLARE
BEGIN
 IF :old.loc_sid <> :new.loc_sid THEN
  RAISE_APPLICATION_ERROR(-20600, 'Can not change loc_sid');
 END IF;
END;
/


DROP TRIGGER AMD_OWNER.AMD_SPARE_PARTS_AFTER_UPD_TRIG;

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


DROP TRIGGER AMD_OWNER.AMD_SUBSTITUTIONS_BEF_DEL;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SUBSTITUTIONS_BEF_DEL
   BEFORE DELETE
   ON AMD_OWNER.AMD_SUBSTITUTIONS
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   /******************************************************************************
          Author:   $Author$
        Revision:   $Revision$
            Date:   $Date$

       Rev 1.0   3/27/2017 Douglas Elder Initial revision.
      PURPOSE: Don't allow deletes

   ******************************************************************************/



   myRole   session_roles.role%TYPE;
BEGIN
   BEGIN
      SELECT NULL
        INTO myRole
        FROM DUAL
       WHERE EXISTS
                (SELECT NULL
                   FROM session_roles
                  WHERE role IN ('AMD_ADMIN', 'DEVELOPER'));
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         raise_application_error (
            -20347,
            'You cannot delete a row. Update the action_code to a D, to
            mark it as deleted');
   END;
END AMD_SUBSTITUTIONS_bef_del;
/


DROP TRIGGER AMD_OWNER.AMD_SUBSTITUTIONS_BEF_IU;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SUBSTITUTIONS_BEF_IU
   BEFORE INSERT OR UPDATE
   ON AMD_OWNER.AMD_SUBSTITUTIONS
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   /******************************************************************************
          Author:   $Author$
        Revision:   $Revision$
            Date:   $Date$

       Rev 1.0   3/27/2017 Douglas Elder Initial revision.
      PURPOSE: Make sure the ORIGINAL_VALUE and NEW_VALUE exists in amd_spare_networks
      when type is SRAN

   ******************************************************************************/



   locId   amd_spare_networks.loc_id%TYPE;
BEGIN
   IF :new.SUBSTITUTION_TYPE = 'SRAN'
   THEN
      BEGIN
         SELECT loc_id
           INTO locId
           FROM amd_spare_networks
          WHERE :new.ORIGINAL_VALUE = loc_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20343,
                  'The original sran must exist in amd_spare_networks: ORIGINAL_VALUE='
               || :new.ORIGINAL_VALUE
               || ' NEW_VALUE='
               || :new.NEW_VALUE);
      END;

      BEGIN
         SELECT loc_id
           INTO locId
           FROM amd_spare_networks
          WHERE :new.ORIGINAL_VALUE = loc_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20345,
                  'The new sran must exist in amd_spare_networks: ORIGINAL_VALUE='
               || :new.ORIGINAL_VALUE
               || ' NEW_VALUE='
               || :new.NEW_VALUE);
      END;
   END IF;

   IF UPDATING
   THEN
      :new.last_update_dt := SYSDATE;
      :new.updated_by := USER;


      IF :new.action_code IS NULL
      THEN
         :new.action_code := amd_defaults.update_action;
      END IF;
   END IF;
END AMD_SUBSTITUTIONS_bef_iu;
/


DROP TRIGGER AMD_OWNER.AMD_TRG_NSI_GROUPS_BRI;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_TRG_NSI_GROUPS_BRI
-- SCCSID: amd_trg_nsi_groups_bri.sql 1.3 Modified: 02/13/03 12:07:35
--
-- Date      By      History
-- 07/03/02  FF      Changed amd_nsi_groups_sid_seq to amd_nsi_group_sid_seq.
--
before insert
on AMD_OWNER.AMD_NSI_GROUPS
for each row
declare
begin
	if (:new.nsi_group_sid is null) then
		select amd_nsi_group_sid_seq.nextval into :new.nsi_group_sid from dual;
	end if;
end;
/


DROP TRIGGER AMD_OWNER.AMD_TRG_RELATED_NSI_PAIRS_RT;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_TRG_RELATED_NSI_PAIRS_RT
after update of tcto_number on AMD_OWNER.AMD_RELATED_NSI_PAIRS
	--
        -- SCCSID: trigAmdRelatedNsiPairs.sql  1.3  Modified: 06/04/02 15:48:41
        --
       -- Date      By             History
        -- 05/22/02  kcs	    Initial
	-- 05/25/02  kcs	    change access of user
        --

for each row
declare
begin
	 if (:new.tcto_number is null) then
 		 update amd_retrofit_tctos
			set last_nsi_pairs_update_dt = SYSDATE, last_nsi_pairs_update_id=substr(user, 1, 8)
	 		where tcto_number = :old.tcto_number;
	 elsif (:old.tcto_number is null) then
	 	 update amd_retrofit_tctos i
			set last_nsi_pairs_update_dt = SYSDATE, last_nsi_pairs_update_id=substr(user, 1, 8)
	 		where tcto_number = :new.tcto_number;
	 elsif (:old.tcto_number != :new.tcto_number) then
 	 	 update amd_retrofit_tctos
			set last_nsi_pairs_update_dt = SYSDATE, last_nsi_pairs_update_id=substr(user, 1, 8)
	 		where tcto_number in (:old.tcto_number, :new.tcto_number);
	 end if;
end AMD_TRG_RELATED_NSI_PAIRS_RT;
/


DROP TRIGGER AMD_OWNER.AMD_TRG_RETROFIT_SCHEDULES_RT;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_TRG_RETROFIT_SCHEDULES_RT
after update of scheduled_complete_date on AMD_OWNER.AMD_RETROFIT_SCHEDULES
	--
        -- SCCSID: trigAmdRetrofitScheds.sql  1.3  Modified: 06/04/02 15:48:57
        --
        -- Date      By             History
        -- 05/22/02  kcs	    Initial
	-- 05/25/02  kcs	    change access of user
        --
for each row
declare
begin
	 update amd_retrofit_tctos
			set last_sched_update_dt = SYSDATE,
			    last_sched_update_id=substr(user, 1, 8)
	 		where tcto_number = :old.tcto_number;
end AMD_TRG_RETROFIT_SCHEDULES_RT;
/


DROP TRIGGER AMD_OWNER.AMD_USER_TYPE_BEFORE_TRIG;

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_USER_TYPE_BEFORE_TRIG
before INSERT
ON AMD_OWNER.AMD_USER_TYPE REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author$
    $Revision$
        $Date$
    $Workfile$
         $Log$

*/
wk_bems_id amd_people_all_v.bems_id%type ;
wk_user_type spo_user_type_v.NAME%type ;
BEGIN
    begin
        select bems_id into wk_bems_id from amd_people_all_v
        where :new.bems_id = amd_people_all_v.bems_id;
    exception when standard.no_data_found then
        raise_application_error(-20800,'bems_id ' || :new.bems_id || ' does not exist in amd_people_all_v.') ;
    end   ;
    begin
        select name into wk_user_type from spo_user_type_v
        where :new.user_type = spo_user_type_v.name ;
    exception when standard.no_data_found then
        raise_application_error(-20900,'user_type ' || :new.bems_id || ' does not exist in spo_user_type_v.') ;
    end ;
END ;
/


DROP TRIGGER AMD_OWNER.NAME_VALUE_PAIRS_BEFORE_INSUPD;

CREATE OR REPLACE TRIGGER AMD_OWNER.NAME_VALUE_PAIRS_BEFORE_INSUPD
BEFORE INSERT OR UPDATE
ON AMD_OWNER.NAME_VALUE_PAIRS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
tmpVar NUMBER;
/******************************************************************************
   NAME:       name_value_pairs_before_insupd
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/24/2016      zf297a       1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     name_value_pairs_before_insupd
      Sysdate:         10/24/2016
      Date and Time:   10/24/2016, 12:52:38 PM, and 10/24/2016 12:52:38 PM
      Username:        zf297a (set in TOAD Options, Proc Templates)
      Table Name:      NAME_VALUE_PAIRS (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   :new.last_update_dt := sysdate ;
   :new.update_by := user ;

   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END name_value_pairs_before_insupd;
/


DROP TRIGGER AMD_OWNER.TMP_LOC_PART_OVERRIDE_TRG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.TMP_LOC_PART_OVERRIDE_TRG1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.tmp_amd_location_part_override
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   Sep 25 2006 08:30:22  $   Aug 23 2006 09:35:44  $
    $Workfile:   TMP_LOC_PART_OVERRIDE_TRG1.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\TMP_LOC_PART_OVERRIDE_TRG1.trg.-arc  $
/*
/*      Rev 1.1   Sep 25 2006 08:30:22   zf297a
/*   Make sure that the last_update_dt gets the updated
/*
/*      Rev 1.0   Aug 24 2006 10:09:44   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.loc_sid = Amd_Location_Part_Override_Pkg.THE_WAREHOUSE_LOC_SID
	and amd_utils.isPartRepairable(:new.part_no) then
	:new.tsl_override_qty := 0 ;
	:new.last_update_dt := sysdate ;
  end if ;
END tmp_loc_part_override_trg1 ;
/
