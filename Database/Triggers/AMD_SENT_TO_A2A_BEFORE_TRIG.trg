CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SENT_TO_A2A_BEFORE_TRIG
before UPDATE
ON AMD_OWNER.AMD_SENT_TO_A2A 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Oct 20 2006 12:36:20  $
    $Workfile:   AMD_SENT_TO_A2A_BEFORE_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SENT_TO_A2A_BEFORE_TRIG.trg.-arc  $
/*   
/*      Rev 1.1   Oct 20 2006 12:36:20   zf297a
/*   Generate A2A transactions for parts that get flagged as deleted because their parent prime part is flagged as deleted.
/*   
/*      Rev 1.0   Oct 20 2006 12:15:36   zf297a
/*   Initial revision.
*/		 
	
	procedure syncActionCode is
		action_code amd_sent_to_a2a.action_code%type ;
		nomenclature amd_spare_parts.nomenclature%type ;
		result number ;
	begin
		select action_code into action_code from amd_sent_to_a2a where part_no = :new.spo_prime_part_no ;
		if action_code = amd_defaults.DELETE_ACTION and :new.action_code <> amd_defaults.DELETE_ACTION then
			:new.action_code := amd_defaults.DELETE_ACTION ; -- must have the same action as its spo_prime_part_no
			select nomenclature into nomenclature from amd_spare_parts where part_no = :new.part_no ;
			result := a2a_pkg.DeletePartInfo(:new.part_no, nomenclature) ;
		end if ;
	end syncActionCode ;

	procedure verifySpoPrimePart is
	begin
		if not a2a_pkg.isPartSent(:new.spo_prime_part_no) then
			raise_application_error(-20000, 'The part_no (' || :new.spo_prime_part_no || ') has never been sent to the SPO, so it cannot be a spo_prime_part_no.') ;
		end if ;
	end verifySpoPrimePart ;

BEGIN
	IF :NEW.spo_prime_part_no IS NOT NULL THEN
		if :new.part_no <> :new.spo_prime_part_no then
			syncActionCode ;
			verifySpoPrimePart ;
		END IF ;
	END IF ;
EXCEPTION WHEN OTHERS THEN	 
	RAISE;
END ;
/
/
