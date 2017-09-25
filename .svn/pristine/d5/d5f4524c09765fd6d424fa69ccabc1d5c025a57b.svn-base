SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_REQS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Reqs_Pkg AS
	/*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.7  $
         $Date:   15 Jan 2009 15:57:06  $
     $Workfile:   AMD_REQS_PKG.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_REQS_PKG.pks-arc  $
/*   
/*      Rev 1.7   15 Jan 2009 15:57:06   zf297a
/*   converted from loc_sid to spo_location for amd_backorder_sum
/*   
/*      Rev 1.6   Nov 29 2006 13:40:36   c402417
/*   Modified functions for Backorder Diff using spo_prime_part_no due to modified table amd_backorder_sum.
/*   
/*      Rev 1.5   Jun 28 2006 13:15:06   zf297a
/*   Added the interfaces for the amd_backorder_spo_sum diff
/*   
/*      Rev 1.4   Jun 09 2006 12:25:06   zf297a
/*   added interface version
/*   
/*      Rev 1.3   Apr 28 2006 13:51:00   zf297a
/*   updated package end statment: end amd_reqs_pkg ;
/*
/*      Rev 1.2   12 Aug 2005 10:48:46   c402417
/*   Added amd_reqs and amd_backorder_sum diff fucntions
/*
/*      Rev 1.1   May 06 2005 09:07:02   c970183
/*   fixed deleteRow and added PVCS keywords

*/
	   -------------------------------------------------------------------
	   -- SCCSID: amd_reqs_pkg.sql 1.2 Modified: 06/26/02 10:36:43
	   --
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  12/10/01		  ks			initial implementation
	   --  06/26/02		  ks			modified action code from not Deleted to in
	   --  				  		add or change - performance issue
	   -------------------------------------------------------------------

	SUCCESS							CONSTANT  NUMBER := 0;
	FAILURE							   CONSTANT  NUMBER := 4;

	PROCEDURE LoadAmdReqs;
	 /* amd_reqs  diff  function */

	FUNCTION InsertRow(
			 		   		  	REQ_ID 			 		IN VARCHAR2,
								PART_NO					IN VARCHAR2,
								LOC_SID					IN NUMBER,
								QUANTITY_DUE			   IN NUMBER) RETURN NUMBER;

	FUNCTION UpdateRow(
			 		   			 REQ_ID					   	  IN VARCHAR2,
								 PART_NO					  IN VARCHAR2,
								 LOC_SID 					  IN NUMBER,
								 QUANTITY_DUE				  IN NUMBER) RETURN NUMBER;

	FUNCTION DeleteRow(
			 		   			 REQ_ID						   IN VARCHAR2,
								 PART_NO					   IN VARCHAR2,
								 LOC_SID					   IN NUMBER) RETURN NUMBER;


	/* amd_backorder_sum diff function */

	FUNCTION InsertRowBackorder(
			 		   	 SPO_PRIME_PART_NO	In varchar2,
						 spo_location							   IN varchar2,
						 QTY								   IN NUMBER) RETURN NUMBER;

	FUNCTION UpdateRowBackorder(
			 		   	 SPO_PRIME_PART_NO		In varchar2,
						 spo_location							   IN varchar2,
						 QTY								   IN NUMBER) RETURN NUMBER;


	FUNCTION DeleteRowBackorder(
			 		   	 SPO_PRIME_PART_NO		In varchar2,
						 spo_location							   IN varchar2) RETURN NUMBER;
						 
	-- added 6/9/2006 by dse
	procedure version ;

	-- added 6/28/2006 by dse
	FUNCTION InsertRowSpoSum(
	  		   			 spo_prime_part_no	IN amd_backorder_spo_sum.SPO_PRIME_PART_NO%type,
						 qty		IN amd_backorder_spo_sum.QTY%type) RETURN NUMBER ;
	FUNCTION UpdateRowSpoSum(
	  		   			 spo_prime_part_no	IN amd_backorder_spo_sum.SPO_PRIME_PART_NO%type,
						 qty		IN amd_backorder_spo_sum.QTY%type) RETURN NUMBER ;
	FUNCTION DeleteRowSpoSum(
	  		   			 spo_prime_part_no	IN amd_backorder_spo_sum.SPO_PRIME_PART_NO%type) RETURN NUMBER ;
	
END Amd_Reqs_Pkg;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_REQS_PKG;

CREATE PUBLIC SYNONYM AMD_REQS_PKG FOR AMD_OWNER.AMD_REQS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_REQS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_REQS_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_REQS_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Reqs_Pkg IS
	/* 
	    PVCS Keywords
		
       $Author:   zf297a  $
     $Revision:   1.20  $
         $Date:   24 Feb 2009 14:02:50  $
     $Workfile:   AMD_REQS_PKG.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_REQS_PKG.pkb-arc  $
/*   
/*      Rev 1.20   24 Feb 2009 14:02:50   zf297a
/*   Removed a2a code.
/*   
/*      Rev 1.19   15 Jan 2009 23:52:48   zf297a
/*   Temporairly fixed insert's for tmp_a2a_backorder_info for the no longer needed loc_sid by using arbitrary constants.  This column needs to be eliminated.
/*   
/*      Rev 1.18   15 Jan 2009 15:57:04   zf297a
/*   converted from loc_sid to spo_location for amd_backorder_sum
/*   
/*      Rev 1.17   07 Nov 2007 22:47:14   zf297a
/*   Use bulk collect for all cursors and bulk inserts for tmp_amd_reqs.
/*   
/*      Rev 1.16   Apr 05 2007 11:34:48   c402417
/*   Remove all TRIM from WHERE clauses.
/*   
/*      Rev 1.15   Dec 07 2006 09:54:02   zf297a
/*   Removed debug code from UpdateRowBackorder and DeleteRowBackorder
/*   
/*      Rev 1.14   Nov 29 2006 13:47:34   c402417
/*   Modified the backorder diff functions since the changes in table amd_backorder_sum with modified column spo_prime_part_no instead of part_no .
/*   
/*      Rev 1.13   Jul 07 2006 13:50:28   zf297a
/*   Fixed InsertRowSpoSum to handle a logical insert of a previously deleted row.
/*   
/*      Rev 1.11   Jun 09 2006 12:25:16   zf297a
/*   implemented version
/*   
/*      Rev 1.10   Apr 28 2006 13:51:00   zf297a
/*   updated package end statment: end amd_reqs_pkg ;
/*   
/*      Rev 1.9   Mar 23 2006 15:43:22   c402417
/*   Changed the way to get site_location into tmp_a2a_backorder_info to use Amd_Utils.getSpoLocation.
/*   
/*      Rev 1.8   Feb 10 2006 12:08:40   c402417
/*   changed to use fuction getSiteLocation from the amd_reqs_pkg instead of from amd_utils_pkg.
/*   
/*      Rev 1.7   Feb 09 2006 13:39:28   c402417
/*   Emergency fix -  getting the right spo_location for site_location in table tmp_a2a_backorder_info.
/*   
/*      Rev 1.6   Dec 06 2005 09:30:10   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.5   Dec 06 2005 09:10:34   zf297a
/*   Added check of isPartValid, wasPartSent, and site_location is not null for all invocations of doInsertTmpA2ABackOrderInfo.  Removed wasPartSent since it resides in the a2a_pkg.
/*   
/*      Rev 1.4   Dec 02 2005 13:50:04   zf297a
/*   Added doInsertTmpA2ABackOrderInfo and doUpdateTmpA2ABackOrderInfo.  Added errorMsg procedure. Changed insertRow, updateRow, and deleteRow to use doInsertTmpA2ABackOrderInfo
/*   
/*      Rev 1.3   Oct 05 2005 13:48:14   c402417
/*   Added function WasPartSent to make sure we sent backorder_info with part that exist in amd_sent_to_a2a.
/*   
/*      Rev 1.2   12 Aug 2005 10:43:16   c402417
/*   Changed sources for table amd_reqs .
/*   Added insert statement for table amd_backorder_sum which feeds table tmp_a2a_backorder_info for SPO .
/*   Added diff functions for table amd_reqs and amd_backorder_sum.
/*   
/*      Rev 1.1   May 06 2005 09:07:00   c970183
/*   fixed deleteRow and added PVCS keywords
   
   */
	ERRSOURCE CONSTANT VARCHAR2(20) := 'amd_req_pkg';
	PROCEDURE writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 IN VARCHAR2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_reqs_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	END writeMsg ;
	
	FUNCTION ErrorMsg(
					pSqlFunction IN VARCHAR2,
					pTableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					pReturn_code IN NUMBER,
					pKey_1 IN VARCHAR2,
			 		pKey_2 IN VARCHAR2 := '',
					pKey_3 IN VARCHAR2 := '',
					pKey_4 IN VARCHAR2 := '',					
					pKeywordValuePairs IN VARCHAR2 := '') RETURN NUMBER IS
	BEGIN
		ROLLBACK;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => pSqlFunction,
						pTableName  => pTableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_reqs_pkg',
				pKey_1 => pKey_1,
				pKey_2 => pKey_2,
				pKey_3 => pKey_3,
				pKey_4 => pKey_4,
				pKey_5 => 'rc=' || TO_CHAR(pReturn_code) ||
					       ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || pKeywordValuePairs,
				pComments => pSqlFunction || '/' || pTableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN pReturn_code;
	END ErrorMsg;
	-- added this procedure ...since function is not really necessary for most errors DSE 12/02/05
	 PROCEDURE ErrorMsg(
	     pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
	     pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
	     pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
	     pKey_1 IN AMD_LOAD_DETAILS.KEY_1%TYPE,
	      pKey_2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	     pKey_3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	     pKey_4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
	     pKeywordValuePairs IN VARCHAR2 := '') IS
	  result NUMBER ;
	 BEGIN
	   result := ErrorMsg(pSqlfunction => pSqlfunction,
				       pTableName => pTableName,
				       pErrorLocation => pError_location,
				       pReturn_code => FAILURE,
				       pKey_1 => pKey_1,
				       pKey_2 => pKey_2,
				       pKey_3 => pKey_3,
				       pKey_4 => pKey_4,
				       pKeywordValuePairs => pKeywordValuePairs) ;
	
	 EXCEPTION WHEN OTHERS THEN
	     COMMIT ;
	 END ErrorMsg;

	PROCEDURE LoadAmdReqs IS
	
        type reqRec is record (
            request_id req1.REQUEST_ID%type,
            part_no req1.SELECT_FROM_PART%type,
            loc_sid amd_spare_networks.loc_sid%type,
            quantity number,
            action_code tmp_amd_reqs.action_code%type,
            last_update_dt tmp_amd_reqs.LAST_UPDATE_DT%type
        ) ;
        type reqTab is table of reqRec ;
        reqRecs reqTab ;
        
		-- backorder from req1 table in Gold
		CURSOR req1_cur IS
			   SELECT
			   		  (REQ1.request_id) request_id,
					  (REQ1.select_from_part) part_no,
					  asn.loc_sid,
			   		  SUM((NVL(REQ1.qty_due,0) + NVL(REQ1.qty_reserved,0))) quantity,
                      amd_defaults.GETINSERT_ACTION action_code,
                      sysdate last_update_dt
			   FROM
			   		  REQ1,
			   		  AMD_SPARE_PARTS asp,
					  AMD_SPARE_NETWORKS asn
			   WHERE
			   		  REQ1.status IN ('U', 'O','H', 'R') AND
					  REQ1.request_priority IN (1,2,3,4,5) AND 
					  REQ1.mils_source_dic IS NOT NULL AND
			   		  asn.loc_id = SUBSTR(REQ1.request_id, 1, 6) AND
			   		  asp.part_no = REQ1.select_from_part AND
					  ((NVL(REQ1.qty_due,0) + NVL(REQ1.qty_reserved,0)) > 0 ) AND 
					  asn.action_code IN (Amd_Defaults.INSERT_ACTION,Amd_Defaults.UPDATE_ACTION)
				GROUP BY (REQ1.request_id),(REQ1.select_from_part), asn.loc_sid ;
		nsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE;
		
		-- backorder from tmp1 table in Gold
		CURSOR tmp1_cur IS
			   SELECT
			   		  (TMP1.temp_out_id) temp_out_id,
					  (TMP1.from_part) part_no,
					  asn.loc_sid,
			   		  SUM(TMP1.qty_due) qty_due,
                      amd_defaults.getINSERT_ACTION action_code,
                      sysdate last_update_dt
			   FROM
			   		  TMP1,
					  AMD_SPARE_NETWORKS asn,
					  AMD_SPARE_PARTS asp
			   WHERE
			   		  TMP1.returned_voucher IS NULL AND 
					  TMP1.status = 'O' AND 
   					  TMP1.TCN = 'LBR' AND
					  TMP1.qty_due != 0 AND
					  asn.loc_id = SUBSTR(TMP1.to_sc,8,6) AND
					  asp.part_no = TMP1.from_part
			   GROUP BY (TMP1.temp_out_id), (TMP1.from_part),asn.loc_sid ;
					  
		  result   NUMBER ;

	BEGIN
	
		 mta_truncate_table('TMP_AMD_REQS','reuse storage') ;
         
		 open req1_cur ;
         fetch req1_cur bulk collect into reqRecs ;
         close req1_cur ;
         
         if reqRecs.first is not null then
            forall indx in reqRecs.first .. reqRecs.last        
                     INSERT INTO TMP_AMD_REQS
                     VALUES reqRecs(indx) ;
            commit ;                     
        end if ;                     
		 
		 BEGIN
             open tmp1_cur ;
             fetch tmp1_cur bulk collect into reqRecs ;
             close tmp1_cur ;
             
             if reqRecs.first is not null then
                forall indx in reqRecs.first .. reqRecs.last
                        INSERT INTO TMP_AMD_REQS
                        VALUES reqRecs(indx) ;
                COMMIT;
             end if ;	  
	    END loadAmdReqs;
  END;
	
	
	
	FUNCTION getSiteLocation(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN
			 AMD_SPARE_NETWORKS.spo_location%TYPE IS
			 
			 site_location AMD_SPARE_NETWORKS.spo_location%TYPE ;
			 result NUMBER ;
	BEGIN
		SELECT spo_location INTO site_location 
		FROM AMD_SPARE_NETWORKS
		WHERE loc_sid = getSiteLocation.loc_sid ;
		
		RETURN site_location ;
	EXCEPTION WHEN OTHERS THEN
		result := ErrorMsg(pSqlFunction => 'select',
		pTableName => 'amd_reqs',
		pErrorLocation => 10 , 
		pReturn_code => FAILURE,
		pKey_1 => TO_CHAR(getSiteLocation.loc_sid)) ;
		RAISE ;
	END getSiteLocation ;
																		 	
	
	/* amd_reqs diff function */
	FUNCTION InsertRow(
			 		   req_id 				IN VARCHAR2,
					   part_no				IN VARCHAR2,
					   loc_sid				IN NUMBER,
					   quantity_due			IN NUMBER) RETURN NUMBER IS
					   
					   result  NUMBER ;
					   
	BEGIN
		 <<insertAmdReqs>>
		 DECLARE
		 		PROCEDURE doUpdate IS
				BEGIN
					 <<getActionCode>>
					 DECLARE
					 		action_code AMD_REQS.action_code%TYPE;
							badInsert EXCEPTION ;
				  	 BEGIN
					 	   SELECT action_code INTO action_code
						   FROM AMD_REQS
						   WHERE req_id = insertRow.req_id
						   AND part_no = InsertRow.part_no;
						   IF action_code != Amd_Defaults.DELETE_ACTION THEN
						   	  			  RAISE badInsert ;
						   END IF;
					EXCEPTION WHEN OTHERS THEN
							  	   		   result:= ErrorMsg(pSqlFunction=>'select',
										  								 	pTableName =>'amd_reqs',
																			pErrorLocation => 20,
																			pReturn_code => FAILURE,
																			pKey_1 => req_id,
																			pKey_2 => part_no,
																			pKey_3 => loc_sid,
																			pkey_4 => quantity_due);
					END getActionCode;
					
					UPDATE AMD_REQS
					SET loc_sid = InsertRow.loc_sid,
								quantity_due = InsertRow.quantity_due,
								action_code = Amd_Defaults.INSERT_ACTION,
								last_update_dt = SYSDATE
					WHERE req_id = InsertRow.req_id
						  		  AND part_no = InsertRow.part_no;
			END doUpdate;
																			
	BEGIN
		 <<insertAmdReqs>>
		 BEGIN
		    INSERT INTO AMD_REQS
			(
		  	  req_id,
			  part_no,
			  loc_sid,
			  quantity_due,
			  action_code,
			  last_update_dt
		 	)
		 	VALUES
		 	(
		  	  req_id,
			  part_no,
			  loc_sid,
			  quantity_due,
			  Amd_Defaults.INSERT_ACTION,
			  SYSDATE
			); 
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
		 		  WHEN OTHERS THEN
					  	 RETURN ErrorMsg(pSqlFunction => 'insert',
								  		 pTableName => 'amd_reqs1',
										 pErrorLocation => 30,
									     pReturn_code => FAILURE,
									     pKey_1 => req_id,
										 pKey_2 => part_no,
									     pKey_3 => loc_sid,
										 pKey_4 => quantity_due);							
      	  END  insertAmdReqs ;																							  										
			RETURN SUCCESS; 				
					
	END insertRow;
END;
								 
	FUNCTION UpdateRow(
			 		   	REQ_ID			IN VARCHAR2,
						PART_NO			IN VARCHAR2,
						LOC_SID			IN NUMBER,
						QUANTITY_DUE	IN NUMBER) RETURN NUMBER IS
	BEGIN
		 <<updateAmdReqs>>
		 BEGIN
		 	UPDATE AMD_REQS SET
					quantity_due = UpdateRow.quantity_due,
					action_code = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
			WHERE
					req_id = UpdateRow.req_id
					AND loc_sid = UpdateRow.loc_sid
					AND part_no = UpdateRow.part_no ;
			EXCEPTION 
				WHEN OTHERS THEN 
				   RETURN ErrorMsg(pSqlFunction => 'update',
								pTableName => 'amd_reqs',
								pErrorlocation => 40,
								pReturn_code => FAILURE,
								pKey_1 => req_id,
								pKey_2 => part_no,
								pKey_3 => loc_sid);
		END updateAmdReqs;	 
		 RETURN SUCCESS ;
		 
	END UpdateRow ;
	
	FUNCTION DeleteRow(
			 		   	REQ_ID	   			IN VARCHAR2,
						PART_NO				IN VARCHAR2,
						LOC_SID				IN NUMBER) RETURN NUMBER IS
	BEGIN
		 <<updateAmdReqs>>
		 BEGIN
		 	  	UPDATE AMD_REQS SET
	                req_id = DeleteRow.req_id,
					part_no =  DeleteRow.part_no,
					loc_sid = DeleteRow.loc_sid,
					action_code	= Amd_Defaults.DELETE_ACTION,
					last_update_dt  =  SYSDATE
				WHERE req_id = DeleteRow.req_id
				AND  part_no  = DeleteRow.part_no
				AND loc_sid = DeleteRow.loc_sid ;
							
		        EXCEPTION WHEN OTHERS THEN
				RETURN ErrorMsg(pSqlFunction => 'update',
							pTableName => 'amd_reqs',
							pErrorLocation => 50,
							pReturn_code => FAILURE,
							pKey_1 => req_id,
							pKey_2 => part_no,
							pKey_3 => loc_sid);
		END updateAmdReqs;
		RETURN SUCCESS ;
		
	END DeleteRow;
	  
	  
		
	  FUNCTION InsertRowBackorder(
	  		   			 spo_prime_part_no IN VARCHAR2,
						 spo_location	IN varchar2,
						 qty		IN NUMBER) RETURN NUMBER IS
			
			result NUMBER ;
		FUNCTION doUpdate RETURN NUMBER IS
	  		   action_code AMD_BACKORDER_SUM.action_code%TYPE;
			   badInsert EXCEPTION;
		BEGIN
			
			UPDATE AMD_BACKORDER_SUM
			SET qty = InsertRowBackorder.qty,
			action_code = Amd_Defaults.INSERT_ACTION,
			last_update_dt = SYSDATE
			WHERE spo_prime_part_no = InsertRowBackorder.spo_prime_part_no AND spo_location = InsertRowBackorder.spo_location;
			
			RETURN SUCCESS ;
			
		EXCEPTION WHEN OTHERS THEN
			result := ErrorMsg(pSqlFunction => 'update',
				pTableName => 'amd_backorder_sum',
				pErrorLocation => 60 , 
				pReturn_code => FAILURE,
				pKey_1 => spo_prime_part_no,
				pKey_2 => spo_location,
				pKey_3 => TO_CHAR(qty)) ;
			RAISE ;
		END doUpdate ;
			
		
	  BEGIN
	  	   writeMsg(pTableName => 'amd_backorder_sum', 
				 		pError_location => 999, 
						pKey1 => 'spo_prime_part_no=' || spo_prime_part_no, 
						pKey2 => 'loc_sid=' || spo_location,
						pKey3 => 'qty=' || to_char(qty)) ;
		  commit ;
	  	  
		<<validateData>>  
		DECLARE
		  			line_no NUMBER := 0 ;
					rec AMD_BACKORDER_SUM%ROWTYPE ;
		BEGIN
			line_no := line_no + 1; rec.spo_prime_part_no := spo_prime_part_no ;
			line_no := line_no + 1; rec.spo_location := insertRowBackorder.spo_location ;
			line_no := line_no + 1; rec.qty := qty ;
		EXCEPTION WHEN OTHERS THEN
		  
			result := ErrorMsg(pSqlFunction => 'insert',
				pTableName => 'amd_backorder_sum',
				pErrorLocation => 70 , 
				pReturn_code => FAILURE,
				pKey_1 => spo_prime_part_no,
				pKey_2 => spo_location,
				pKey_3 => TO_CHAR(qty),
				pKey_4 => TO_CHAR(line_no)) ;
			RAISE ;
		END validateDate ;
		
		IF (qty > 0) and spo_prime_part_no is not null THEN  
			BEGIN			
				INSERT INTO AMD_BACKORDER_SUM
					(
					spo_prime_part_no,
					spo_location,
					qty,
					action_code,
					last_update_dt
					)
					VALUES
					(
					InsertRowBackorder.spo_prime_part_no,
					InsertRowBackorder.spo_location,
					InsertRowBackorder.qty,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
					);
			  
			EXCEPTION
				WHEN standard.DUP_VAL_ON_INDEX THEN
					 result := doUpdate ; 
				WHEN OTHERS THEN
			
				result := ErrorMsg(pSqlFunction => 'insert',
					pTableName => 'amd_backorder_sum',
					pErrorLocation => 80 , 
					pReturn_code => FAILURE,
					pKey_1 => spo_prime_part_no,
					pKey_2 => spo_location,
					pKey_3 => TO_CHAR(qty) ) ;
				RAISE ;
			END insertAmdBackorderSum;
				  
			
		    RETURN SUCCESS ;
		END IF ;
	END InsertRowBackorder;
		
		
	FUNCTION  UpdateRowBackorder(
			  			spo_prime_part_no	IN VARCHAR2,
						spo_location		  IN varchar2,
						qty			  IN NUMBER) RETURN NUMBER IS
			result NUMBER;
			
	BEGIN
	  <<updateAmdBackorderSum>>
	  BEGIN
	  	   UPDATE AMD_BACKORDER_SUM SET
		   	 qty = UpdateRowBackorder.qty,
			 action_code = Amd_Defaults.UPDATE_ACTION,
			 last_update_dt = SYSDATE
		   WHERE spo_prime_part_no = UpdateRowBackorder.spo_prime_part_no
		   AND spo_location = UpdateRowBackorder.spo_location;
	
	  
	   END updateAmdBackorderSum;
	   
	   RETURN SUCCESS;
	   
	END UpdateRowBackorder;
	
	 
	 FUNCTION DeleteRowBackorder(
	 		  			spo_prime_part_no	IN VARCHAR2,
						spo_location			 IN varchar2) RETURN NUMBER IS
	
	 BEGIN
	 	<<updateAmdBackorderSum>>
		BEGIN
		
			  UPDATE AMD_BACKORDER_SUM SET
			    action_code = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			  WHERE spo_prime_part_no = DeleteRowBackorder.spo_prime_part_no
			  AND spo_location = DeleteRowBackorder.spo_location ;
		
			
			
				RETURN SUCCESS ;
				
		exception when standard.no_data_found then
				 writeMsg(pTableName => 'updateAmdBackorderSum', 
				 		pError_location => 100, 
						pKey1 => 'spo_prime_part_no=' || spo_prime_part_no, 
						pKey2 => 'loc_sid=' || spo_location) ;
				return success ;
		END updateAmdBackorderSum;
		
	END DeleteRowBackorder;
		 		    	
	FUNCTION InsertRowSpoSum(
	  		   			 spo_prime_part_no	IN AMD_BACKORDER_SPO_SUM.SPO_PRIME_PART_NO%TYPE,
						 qty		IN AMD_BACKORDER_SPO_SUM.QTY%TYPE) RETURN NUMBER IS
			
			result NUMBER ;
			
			PROCEDURE doUpdate IS
					  action_code AMD_BACKORDER_SPO_SUM.action_code%TYPE ;
			BEGIN
				 <<getActionCode>>
				 BEGIN
				 	  SELECT action_code INTO doUpdate.action_code
					  FROM AMD_BACKORDER_SPO_SUM
					  WHERE spo_prime_part_no = InsertRowSpoSum.spo_prime_part_no
					  AND action_code = Amd_Defaults.DELETE_ACTION ;
				 EXCEPTION WHEN standard.NO_DATA_FOUND THEN
				 	  RAISE_APPLICATION_ERROR(-20000, spo_prime_part_no || ' does not have a ' || Amd_Defaults.DELETE_ACTION || ' action_code.');
				 END getActionCode ;
				 
				UPDATE AMD_BACKORDER_SPO_SUM
				SET qty = InsertRowSpoSum.qty,
				action_code = Amd_Defaults.INSERT_ACTION,
				last_update_dt = SYSDATE
				WHERE spo_prime_part_no = InsertRowSpoSum.spo_prime_part_no ;
			END doUpdate ;
			
		
	BEGIN
	  	  
		<<validateData>>  
		DECLARE
		  			line_no NUMBER := 0 ;
					rec AMD_BACKORDER_SPO_SUM%ROWTYPE ;
		BEGIN
			line_no := line_no + 1; rec.spo_prime_part_no := spo_prime_part_no ;
			line_no := line_no + 1; rec.qty := qty ;
		EXCEPTION WHEN OTHERS THEN
		  
			result := ErrorMsg(pSqlFunction => 'insert',
				pTableName => 'amd_backorder_spo_sum',
				pErrorLocation => 90 , 
				pReturn_code => FAILURE,
				pKey_1 => spo_prime_part_no,
				pKey_2 => TO_CHAR(qty),
				pKey_3 => TO_CHAR(line_no)) ;
			RAISE ;
		END validateDate ;
		
		IF (qty > 0) THEN  
		    <<insertAmdBackorderSpoSum>>
			BEGIN			
				INSERT INTO AMD_BACKORDER_SPO_SUM
					(
					spo_prime_part_no,
					qty,
					action_code,
					last_update_dt
					)
					VALUES
					(
					spo_prime_part_no,
					qty,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
					);
			  
			EXCEPTION
			    WHEN standard.DUP_VAL_ON_INDEX THEN
					 doUpdate ;
				WHEN OTHERS THEN
			
				result := ErrorMsg(pSqlFunction => 'insert',
					pTableName => 'amd_backorder_spo_sum',
					pErrorLocation => 100 , 
					pReturn_code => FAILURE,
					pKey_1 => spo_prime_part_no,
					pKey_2 => TO_CHAR(qty) ) ;
				RAISE ;
			END insertAmdBackorderSpoSum;
					  
			
		    RETURN SUCCESS ;
		END IF ;
	END InsertRowSpoSum ;
	
	FUNCTION UpdateRowSpoSum(
	  		   			 spo_prime_part_no	IN AMD_BACKORDER_SPO_SUM.SPO_PRIME_PART_NO%TYPE,
						 qty		IN AMD_BACKORDER_SPO_SUM.QTY%TYPE) RETURN NUMBER IS
			
			result NUMBER ;
			
		
	  BEGIN
	  	  
		<<validateData>>  
		DECLARE
		  			line_no NUMBER := 0 ;
					rec AMD_BACKORDER_SPO_SUM%ROWTYPE ;
		BEGIN
			line_no := line_no + 1; rec.spo_prime_part_no := spo_prime_part_no ;
			line_no := line_no + 1; rec.qty := qty ;
		EXCEPTION WHEN OTHERS THEN
		  
			result := ErrorMsg(pSqlFunction => 'update',
				pTableName => 'amd_backorder_spo_sum',
				pErrorLocation => 110 , 
				pReturn_code => FAILURE,
				pKey_1 => spo_prime_part_no,
				pKey_2 => TO_CHAR(qty),
				pKey_3 => TO_CHAR(line_no)) ;
			RAISE ;
		END validateDate ;
		
		IF (qty > 0) THEN
		    <<updateAmdBackorderSpoSum>>  
			BEGIN			
				UPDATE AMD_BACKORDER_SPO_SUM
				SET qty = UpdateRowSpoSum.qty,
				action_code = Amd_Defaults.UPDATE_ACTION,
				last_update_dt = SYSDATE
				WHERE spo_prime_part_no = UpdateRowSpoSum.spo_prime_part_no ;
			EXCEPTION
				WHEN OTHERS THEN
			
				result := ErrorMsg(pSqlFunction => 'update',
					pTableName => 'amd_backorder_spo_sum',
					pErrorLocation => 120 , 
					pReturn_code => FAILURE,
					pKey_1 => spo_prime_part_no,
					pKey_2 => TO_CHAR(qty) ) ;
				RAISE ;
			END updateAmdBackorderSpoSum;
					  
			
		    RETURN SUCCESS ;
			
		END IF ;
	END UpdateRowSpoSum ;
	
	FUNCTION DeleteRowSpoSum(
	  		   			 spo_prime_part_no	IN AMD_BACKORDER_SPO_SUM.SPO_PRIME_PART_NO%TYPE) RETURN NUMBER IS
			
			result NUMBER ;
			
		
	  BEGIN
	  	  
		
			UPDATE AMD_BACKORDER_SPO_SUM
			SET action_code = Amd_Defaults.DELETE_ACTION,
			last_update_dt = SYSDATE
			WHERE spo_prime_part_no = DeleteRowSpoSum.spo_prime_part_no ;
			
		    RETURN SUCCESS ;

	 EXCEPTION
		WHEN OTHERS THEN
	
		result := ErrorMsg(pSqlFunction => 'update',
			pTableName => 'amd_backorder_spo_sum',
			pErrorLocation => 130 , 
			pReturn_code => FAILURE,
			pKey_1 => spo_prime_part_no) ;
		RAISE ;
			
	END DeleteRowSpoSum ;
	
	PROCEDURE version IS
	BEGIN
		 writeMsg(pTableName => 'amd_reqs_pkg', 
		 		pError_location => 110, pKey1 => 'amd_reqs_pkg', pKey2 => '$Revision:   1.20  $') ;
	END version ;
		  	
	 
END Amd_Reqs_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_REQS_PKG;

CREATE PUBLIC SYNONYM AMD_REQS_PKG FOR AMD_OWNER.AMD_REQS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_REQS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_REQS_PKG TO AMD_WRITER_ROLE;

