CREATE OR REPLACE TRIGGER AMD_OWNER.A2A_PART_INFO_AFTER_TRIG
AFTER INSERT
ON AMD_OWNER.TMP_A2A_PART_INFO REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.8  $
	    $Date:   01 Mar 2007 10:31:52  $
    $Workfile:   A2A_PART_INFO_AFTER_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\A2A_PART_INFO_AFTER_TRIG.trg-arc  $
/*   
/*      Rev 1.8   01 Mar 2007 10:31:52   zf297a
/*   Removed recording of sent to a2a history
/*   
/*      Rev 1.7   Aug 09 2005 11:51:34   zf297a
/*   added debugMsg for any error encountered.
/*   
/*      Rev 1.6   Aug 09 2005 10:44:54   zf297a
/*   Added sleep routine when saving comments is occuring to fast and the key is not unique.
/*   
/*      Rev 1.5   Jul 20 2005 13:40:52   zf297a
/*   Record some historical comment about why the part is being added to the spo, updated for the spo, or deleted from the spo.
/*   
/*      Rev 1.3   Jun 28 2005 14:48:44   zf297a
/*   Fixed errorMsg
/*   
/*      Rev 1.2   Jun 28 2005 14:35:26   zf297a
/*   added update of tmp_a2a_part_effectivity
/*   
/*      Rev 1.1   May 31 2005 10:04:24   c970183
/*   Updated amd_sent_to_a2a when a duplicate index exception occurs.
/*   
/*      Rev 1.0   May 13 2005 14:24:12   c970183
/*   Initial revision.
*/		 
	procedure errorMsg(sqlFunction in varchar2, 
			  tableName in varchar2, 
			  location in number) is
	begin
		dbms_output.put_line('sqlcode('||sqlcode||') sqlerrm('|| sqlerrm||')') ;
		dbms_output.put_line('part_no=' || :new.part_no || ' action_code=' || :new.action_code) ;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => substr(sqlFunction,1,20),
						                        pTableName  => substr(tableName,1,20)),
				pData_line_no => location,
				pData_line    => 'a2a_part_info_after_trig', 
				pKey_1 => substr(:new.part_no,1,50),
				pKey_2 => substr(:new.action_code,1,50),
				pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MM:SS'),
				pComments => substr('sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')',1,2000));
	end ErrorMsg;
	
	
	procedure populateSentToA2a is
	begin

	   insert into amd_sent_to_a2a 
	   (part_no, action_code, transaction_date)  
	   values
	   (:new.part_no, :new.action_code, sysdate) ;
	exception
		 when standard.dup_val_on_index then
		      begin
			 	  update amd_sent_to_a2a
				  set action_code = :new.action_code,
				  transaction_date = sysdate
				  where part_no = :new.part_no ;

				  
			  exception when others then
			  	  amd_utils.debugMsg(pMsg => 'update error', 
				  	pPackage => 'a2a_part_info_after_trig', 
			  		pLocation => 10,
					pMsg2 => :new.part_no) ; 
			  end ;
	     when others then
	  	  amd_utils.debugMsg(pMsg => 'insert error', 
		  	pPackage => 'a2a_part_info_after_trig', 
	  		pLocation => 20,
			pMsg2 => :new.part_no) ; 
	end populateSentToA2A ;
	
	procedure populatePartEffectivity is
	begin
		 insert into tmp_a2a_part_effectivity
		 (part_no, mdl, series, effectivity_type, range_from, range_to, range_flag, qpei, customer, action_code, last_update_dt)
		 values
		 (:NEW.part_no, 'C17', 'A', 'P', 'C17Full','C17Full','B','1','AF', :new.action_code, sysdate) ;
	exception
		 when standard.dup_val_on_index then
		 	  begin
			 	  update tmp_a2a_part_effectivity
				  set action_code = :new.action_code,
				  last_update_dt = sysdate
				  where part_no = :new.part_no ;
			  exception when others then
			  	  errormsg(sqlFunction => 'update',
				    tableName => 'tmp_a2a_part_effectivity',
					location => 30) ;
			  end ;
	     when others then
		   errormsg(sqlFunction => 'insert',
		     tableName => 'tmp_a2a_part_effectivity',
			 location => 40) ;
	       raise;
		 
	end populatePartEffectivity ;
BEGIN
	 populateSentToA2A ;
	 -- populatePartEffectivity ;
exception when others then	 
	errorMsg(sqlFunction => 'populate', 
		tableName => 'SentToA2A & PartEffectivity', 
		location => 50) ;
	raise;
END ;
/
