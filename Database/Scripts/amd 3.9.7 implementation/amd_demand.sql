DROP PACKAGE AMD_OWNER.AMD_DEMAND;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_demand as
/*
      $Author:   zf297a  $
    $Revision:   1.18  $
        $Date:   11 Sep 2009 12:43:30  $
    $Workfile:   amd_demand.sql  $

      Rev 1.18   Added Procedure LoadFmsDemand per ClearQuest # LBPSS00002393 by Laurie Compton.
   
      Rev 1.17   11 Sep 2009 12:43:30   zf297a
     Added getVersion, setDebug, and getDebugYorN and added pragma for ErrorMsg 
   
      Rev 1.16   11 Sep 2009 12:39:48   zf297a
   Added interfaces getVersion, setDebug, and getDebugYorN
   
      Rev 1.15   24 Feb 2009 14:13:28   zf297a
   Removed a2a code
   
      Rev 1.14   03 Oct 2007 13:24:28   zf297a
   Changed interface getCurrentPeriod to getCalendarDate for a given period.
   Added interface getFiscalPeriod.
   
      Rev 1.13   20 Aug 2007 09:29:30   zf297a
   Merged branch 1.11.1.1 changes + added interface for procedure loadAllA2A
   
      Rev 1.11.1.1   01 Aug 2007 13:32:28   zf297a
   added duplicate to the doDmndFrcstConsumablesDiff.  Added interfaces for getCurrentPeriod and genDuplicateForConsumables.
   
      Rev 1.12   23 May 2007 00:11:54   zf297a
   Added interface for doDmndFrcstConsumablesDiff and added exception badActionCode.
   
      Rev 1.11   Jun 09 2006 12:51:12   zf297a
   added interface version

      Rev 1.10   Jul 27 2005 11:56:20   zf297a
   Modified by Dean Hoang for a2a transactions
*/

	--
	-- SCCSID: amd_demand.sql  1.9  Modified: 11/23/04 09:05:30
	--
	-- -------------------------------------------------------------------
	-- This program loads demand data into amd_af_reqs table.
	--
	-- Prior to execution of this procedure, we assume that the lcf data
	-- have been successfully loaded into tmp_lcf_raw table.
	--
	-- The temporary table amd_l67_tmp and tmp_lcf_icp should be truncated
	-- prior to the execution of the procedure.
	-- -------------------------------------------------------------------
	--
	-- Date     By     History
	-- 10/12/01 FF     Initial implementation
	-- 10/25/01 FF     Removed DedupL67() and moved into InsertL67TmpLcfIcp()
	-- 10/28/01 FF     Added LoadBascUkDemands().
	-- 11/21/01 FF     Removed use of mfgr, manuf_cage as part of key when
	--                 accessing data from amd_spare_parts
	-- 11/26/01 FF     Changed action_code to use defaults package.
	-- 12/13/01 FF     Added logic in Insertl67TmpLcfIcp() to handle 15-char
	--                 nsn's. MMC is added to NSN if numeric.
	-- 08/06/01 FF     Removed use of CalcReqDate(). Using trans_date instead.
	-- 10/23/02 FF     Added translation of loc_type='TMP' srans to its MOB val.
	-- 11/04/04 TP	   Added EY1213 to Request Id field.
	--

	badActionCode             EXCEPTION ;

	procedure LoadAmdDemands;
    procedure LoadFmsDemands;
	procedure LoadBascUkDemands;
	procedure amd_demand_a2a;
	procedure prime_part_change (old_part_no amd_national_stock_items.prime_part_no%TYPE,
                                new_part_no amd_national_stock_items.prime_part_no%TYPE);

    -- added by dse 5/22/2007
	FUNCTION doDmndFrcstConsumablesDiff(
			 nsn	IN VARCHAR2,
			 sran       IN VARCHAR2,
			 period		     IN NUMBER,
			 demand_forecast IN NUMBER,
             duplicate in NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER ;
							
	-- added 6/9/2006 by dse
	procedure version ;
    -- added 7/31/2007 by dse
    
    procedure genDuplicateForConsumables ;
    function getCalendarDate(period in number) return date ;
    function getFiscalPeriod(aDate in date) return number ;

	function getVersion return varchar2 ;
        function getDebugYorN return varchar2 ;
	procedure setDebug(switch in varchar2) ;



end amd_demand;
/


DROP PUBLIC SYNONYM AMD_DEMAND;

CREATE PUBLIC SYNONYM AMD_DEMAND FOR AMD_OWNER.AMD_DEMAND;


GRANT EXECUTE ON AMD_OWNER.AMD_DEMAND TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_DEMAND TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_DEMAND;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Demand AS
/*
      $Author:   402417  $
    $Revision:   1.45 $
        $Date:   27  Jul 2010 12:25:00  $
    $Workfile:   amd_demand.sql  $
    
      Rev 1.45   Additional criteria to the REASON in function CalcQuantity per CQ# LBPSS00002694 (L67 Demand DOC TTPC Action Taken Code Modification) requested by LC.

      Rev 1.44   Added Procedure LoadFmsDemand per ClearQuest# LBPSS00002393 by Laurie Compton. 

      Rev 1.43   Thuy switched reason and dmd_cd for CalcQuantity and CalcBadQuantity
                 Thuy modified CalcQuantity and CalcBadQuantity

      Rev 1.42   11 Sep 2009 12:40:20   zf297a
   Implemented interfaces getVersion, setDebug, and getDebugYorN
   and added pragma for ErrorMsg
   
      Rev 1.41   24 Feb 2009 14:13:40   zf297a
   Removed a2a code.
   
      Rev 1.40   28 Oct 2008 08:46:46   zf297a
   When creating ExtForecast A2A transactions, make the duplicate column 1 when it is null.
   
      Rev 1.39   10 Apr 2008 11:07:02   zf297a
   Thuy Pham added EB as request_id to be part of LoadBascUKDemand.
   
      Rev 1.38   23 Oct 2007 18:29:34   zf297a
   For genDuplicateForConsumables fix the cursor demandsNotSame to make sure that it only retrieves the current period and beyond.
   
      Rev 1.37   03 Oct 2007 13:25:08   zf297a
   Implemented interface getCalendarDate and interface getFiscalPeriod.
   
      Rev 1.36   12 Sep 2007 13:58:38   zf297a
   Removed commits from for loop.
   
      Rev 1.35   21 Aug 2007 11:52:00   zf297a
   Passed part_no instead of rec.nsn to amd_utils.isPartActive for nested procedure insertA2A which is subordinate to procedure loadAllA2A.
   
      Rev 1.34   20 Aug 2007 09:32:02   zf297a
   Added constant EXTERNAL and implemented procedure loadAllA2A.
   
      Rev 1.33   17 Aug 2007 13:42:36   zf297a
   Changed the program code to count the total number of periods that should have the same quantity for each part/location - so the A2A record with the PERIOD counts that record itself as being included in the DUPLICATE count.  Where we had DUPLICATE value of '1' before goes to '2', and value of '63' goes to '64'.   
   
      Rev 1.32   08 Aug 2007 11:23:42   zf297a
   Fixed getCurrentPeriod for when the period > cur_year to compute the current period as 10/01/period - 1 when the cur_month < 10, and cur_month/01/period - 1  when the cur_month >= 10.
   
      Rev 1.31   08 Aug 2007 09:59:42   zf297a
   Adjusted the duplicate count to be 1 less so that the count includes the record that contains the duplicate: ie a duplicate of 1 means the current record plus 1 = 2 records of the 66 total allowed and a duplicate of 63 means the current record plus 63 = 64 of the 66 total allowed.
   
      Rev 1.30   08 Aug 2007 00:26:06   zf297a
   Fixed getCurrentPeriod to return 10/1/period when period > current year.
   Fixed genDuplicateForConsumables to sum periods together that have the same demand_forecast.  Fixed final update to update only those periods belonging to the current_period with 66.
   
      Rev 1.29   07 Aug 2007 13:31:04   zf297a
   Fixed update of tmp_amd_dmnd_frcst_consumables - the where clause should have period = (select min(period)....) not perdiod <> (select min(period)...)
   
      Rev 1.28   01 Aug 2007 16:58:56   zf297a
   Make sure the update of tmp_amd_dmnd_frcst_consumables updates only the current_period with the duplicate of  DUP_THRESHOLD
   
      Rev 1.27   01 Aug 2007 16:38:38   zf297a
   removed function getDuplicate.  Enhanced procedure doDmndFrcstConsumablesDiff by adding duplicate to the interface.  
   Added function getCurrentPeriod, which will be using in creating the tmp_a2a_ext_forecast table.
   Create a routine to read tmp_amd_dmnd_frcst_consumables and create the duplicate column needed for the ExtForecast A2A transactions.
   
      Rev 1.26   23 Jul 2007 15:47:22   zf297a
   Implemented interface for getDuplicate, which is a function used to get the duplicate # for the A2A External Forecast Transaction.
   
   Used amd_loc_part_forecasts_pkg.getCurrentPeriod, which gets it data from the amd_param_changes table, for the period and the new function getDuplicate(cur_period) to get the duplicate # for the A2A External  Forecast Transaction.
   
      Rev 1.25   Jul 20 2007 07:03:38   c402417
   Added Canada Demand(EY1414).
   
      Rev 1.24   Jul 19 2007 19:19:26   c402417
   Modified procedure insertA2A
   to get correct Period and Duplicate.
   
      Rev 1.23   23 May 2007 00:12:14   zf297a
   Implemented interface doDmndFrcstConsumablesDiff
   
      Rev 1.22   Apr 05 2007 11:13:10   c402417
   Remove all the  TRIM from WHERE clauses for AMD v1.8.06.6
   
      Rev 1.21   Mar 05 2007 12:09:46   c402417
   Added AU demand.
   
      Rev 1.20   Jun 09 2006 12:51:26   zf297a
   implemented version
   
      Rev 1.19   Mar 07 2006 13:17:32   c402417
   Changed field Site to get spo_location from amd_spare_networks instead of loc_id.
   
      Rev 1.18   Dec 07 2005 13:12:20   zf297a
   When joining with amd_sent_to_a2a, make sure the part was not deleted from the SPO - i.e. action_code != 'D'.
   
   Check that the super prime part no is actually vaild and that it has been sent to the SPO.
   
      Rev 1.17   Dec 05 2005 16:43:30   c402417
   Added version 1.10.1.2 to the current version.
   
      Rev 1.14   Dec 01 2005 09:30:38   zf297a
   added pvcs keywords
*/
	debug 						boolean := false ;

    EXTERNAL constant varchar2(8) := 'External' ;

	FUNCTION CalcQuantity(
							pDocNo VARCHAR2,
							pDic VARCHAR2) RETURN NUMBER;
	FUNCTION CalcBadQuantity(
							pDocNo VARCHAR2,
							pDic VARCHAR2) RETURN NUMBER;
	PROCEDURE InsertTmpLcf1;
	PROCEDURE InsertTmpLcfIcp;
	PROCEDURE InsertL67TmpLcfIcp;
    
	PROCEDURE errorMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					pError_Location IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',					
					keywordValuePairs IN VARCHAR2 := '') IS
         	pragma autonomous_transaction ;

	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pError_Location,
				pData_line    => 'amd_demand',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => SqlFunction || '/' || TableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN ;
	END ErrorMsg;


	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_demand',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	    FUNCTION CalcQuantity(
                            pDocNo VARCHAR2,
                            pDic VARCHAR2) RETURN NUMBER IS
        qty     NUMBER := 0;
        qtyd1   NUMBER := 0;
        qtyd2      NUMBER := 0;
    BEGIN

        IF pDic = 'TIN' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'TIN'
                    AND ttpc = '1B'
                    AND dmd_cd IN ('B','C','J','V','X','A','D','F','G','K','L','Z',
                        '1','2','3','4','5','6','7','8','9');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        ELSIF pDic = 'TRN' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'TRN'
                    AND ttpc = '4S'
                    AND reason IN ('A','F','G','K','L','Z');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        ELSIF pDic = 'ISU' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'ISU'
                    AND ttpc IN ('1A','3P','3Q');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        ELSIF pDic = 'MSI' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'MSI'
                    AND ttpc IN ('1C','1G','1O','1Q','2I','2K','3P');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        ELSIF pDic = 'DUO' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'DUO'
                    AND ttpc IN ('2D','4W');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        ELSIF pDic = 'DOC' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qtyd1
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'DOC'
                    AND ttpc IN ('2A','2C')
                    AND ( reason IN ('B','C','J','V','X','A','F','G','K','L','Z') or reason is null); /* added on 7/20/2010 by TP requested by LC */
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qtyd1 := 0;
            END;
           qty := qtyd1 ;
        END IF;

        RETURN(qty);

    END CalcQuantity;


    FUNCTION CalcBadQuantity(
                            pDocNo VARCHAR2,
                            pDic VARCHAR2) RETURN NUMBER IS
        qty      NUMBER := 0;
    BEGIN

        IF pDic = 'TIN' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'TIN'
                    AND ttpc = '1B'
                    AND dmd_cd NOT IN ('B','C','J','V','X','A','D','F','G','K',
                                        'L','Z','1','2','3','4','5','6','7','8','9');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        ELSIF pDic = 'TRN' THEN
            BEGIN
                SELECT
                    NVL(SUM(action_qty),0)
                INTO qty
                FROM TMP_LCF_ICP
                WHERE doc_no = pDocNo
                    AND dic = 'TRN'
                    AND ttpc = '4S'
                    AND reason NOT IN ('A','F','G','K','L','Z');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    qty := 0;
            END;
        END IF;

        RETURN(qty);

    END CalcBadQuantity;




	PROCEDURE InsertTmpLcf1 IS
	BEGIN

		INSERT INTO TMP_LCF_1
		(
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			trans_date,
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			date_of_last_demand,
			unit_of_issue,
			supplemental_address
		)
		SELECT
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			TO_DATE(trans_date,'yyyyddd'),
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			TO_DATE(date_of_last_demand,'yyyyddd'),
			unit_of_issue,
			supplemental_address
		FROM TMP_LCF_RAW
		WHERE SUBSTR(doc_no,1,1) IN ('X','J','R','B','S')
		GROUP BY
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			TO_DATE(trans_date,'yyyyddd'),
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			TO_DATE(date_of_last_demand,'yyyyddd'),
			unit_of_issue,
			supplemental_address;


		UPDATE TMP_LCF_1 SET
			nsn = SUBSTR(stock_no,1,13),
			mmc = SUBSTR(stock_no,14,2),
			sran = 'FB'||sran;

		COMMIT;

	END InsertTmpLcf1;


	PROCEDURE InsertTmpLcfIcp IS
	BEGIN

		INSERT INTO TMP_LCF_ICP
		(
			nsn,
			mmc,
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			trans_date,
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			date_of_last_demand,
			supplemental_address
		)
		SELECT
			nsn,
			mmc,
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			trans_date,
			trans_ser,
			action_qty,
			DECODE(asn.loc_type,'TMP',asn.mob,sran) sran,
			nomenclature,
			marked_for,
			date_of_last_demand,
			supplemental_address
		FROM
			TMP_LCF_1 tl1,
			AMD_SPARE_NETWORKS asn
		WHERE
			tl1.sran = asn.loc_id;

		COMMIT;

	END InsertTmpLcfIcp;



	PROCEDURE InsertL67TmpLcfIcp IS
		CURSOR l67Cur IS
			SELECT DISTINCT
				nsn,
				mmc,
				erc,
				tric,
				ttpc,
				dmd_cd,
				reason,
				doc_no,
				trans_date,
				trans_ser,
				action_qty,
				DECODE(asn.loc_type,'TMP',asn.mob,sran) sran,
				nomenclature,
				marked_for,
				dold,
				supp_address
			FROM
				AMD_L67_SOURCE als,
				AMD_SPARE_NETWORKS asn
			WHERE
				SUBSTR(als.doc_no,1,1) IN ('X','S','B','J','R')
				AND als.sran = asn.loc_id;

		nsn         VARCHAR2(20);
		mmacCode    NUMBER;
	BEGIN

		FOR rec IN l67Cur LOOP
			BEGIN
				mmacCode := rec.mmc;
				nsn      := rec.nsn||rec.mmc;
			EXCEPTION
				WHEN OTHERS THEN
					nsn := rec.nsn;
			END;

			INSERT INTO TMP_LCF_ICP
			(
				nsn,
				mmc,
				stock_no,
				erc,
				dic,
				ttpc,
				dmd_cd,
				reason,
				doc_no,
				trans_date,
				trans_ser,
				action_qty,
				sran,
				nomenclature,
				marked_for,
				date_of_last_demand,
				supplemental_address
			)
			VALUES
			(
				nsn,
				rec.mmc,
				nsn,
				rec.erc,
				rec.tric,
				rec.ttpc,
				rec.dmd_cd,
				rec.reason,
				rec.doc_no,
				rec.trans_date,
				rec.trans_ser,
				rec.action_qty,
				rec.sran,
				rec.nomenclature,
				rec.marked_for,
				rec.dold,
				rec.supp_address
			);

		END LOOP;

		COMMIT;

	END;



	--
	-- LoadAmdDemands -
	--
	-- procedure to load amd_af_reqs from lcf data.
	--
	-- currently, we manually load lcf data into tmp_lcf_raw, tmp_lcf_1,
	-- tmp_lcf_icp tables manually.  we do not know at this time how we would
	-- receive the lcf data in the future.
	--
	-- assume we have data loaded into tmp_lcf_icp, the follows are processes
	-- to be perform to load data into amd_af_reqs table.
	--
	-- 1) loop for each doc_no.
	-- 2) for each doc_no:
	-- 	2.1) select sum of qualified tin into goodtin
	-- 	2.2) select sum of non-qualified tin into badtin
	-- 	2.3) select sum of qualified trn into goodtrn
	-- 	2.4) select sum of non-qualified trn into badtrn
	-- 	2.5) calculate tin quantity:
	-- 						tinqty = goodtin + goodtrn
	-- 	2.6) calculate badtin quantity:
	-- 			badtinqty = badtin + badtrn
	-- 2.7) select sum of qualified isu
	-- 2.8) select sum of qualified msi
	-- 2.9) select sum of qualified duo
	-- 2.10)select sum of qualified doc
	-- 2.11)calculate duo quantity:
	-- 			duoqty = duo - doc.
	-- 		  note: if duoqty is negative, set duoqty = 0.
	-- 2.12)calculate non tin quantity:
	-- 			ntinqty = isu + msi + duoqty - badtinqty
	-- 	2.13)calculate other quantity:
	-- 			otherqty = ntinqty - tinqty
	-- 2.14)calculate requisition quantity:
	-- 				if otherqty > 0 then
	-- 							qty		= tinqty + otherqty
	--					else
	--                      qty		= tinqty
	--					end if
	--	2.15) if the qty = 0, do not insert the requisition.
	--
	-- 3) select nsn of the doc_no and select prime part from amd_spare_parts
	-- 4) use trans_date as requistion_date
	-- 5) insert into amd_demands table.
	--
	PROCEDURE LoadAmdDemands IS
		vNsn         VARCHAR2(20);
		tinqty       NUMBER := 0;
		ntinqty      NUMBER := 0;
		otherqty     NUMBER := 0;
		qty	       NUMBER := 0;
		goodtin      NUMBER := 0;
		badtin       NUMBER := 0;
		goodtrn      NUMBER := 0;
		badtrn       NUMBER := 0;
		badtinqty    NUMBER := 0;
		isu          NUMBER := 0;
		msi          NUMBER := 0;
		duo          NUMBER := 0;
		doc          NUMBER := 0;
		duoqty       NUMBER := 0;
		reqDate      DATE;
		lcf1cnt      NUMBER;
		nsiSid       NUMBER;
		loadNo       NUMBER;

		CURSOR docCur IS
			SELECT
				tli.doc_no,
				asn.loc_sid,
				MIN(tli.trans_date) trans_date
			FROM
				TMP_LCF_ICP tli,
				AMD_SPARE_NETWORKS asn
			WHERE
				tli.sran = asn.loc_id
			GROUP BY
				tli.doc_no,
				asn.loc_sid;


	BEGIN
		loadNo := Amd_Utils.GetLoadNo('AMD_DEMAND','AMD_DEMANDS');

		--
		-- if there are no records in tmp_lcf_1 then
		-- insert them from tmp_lcf_raw
		--
		SELECT COUNT(*)
		INTO lcf1cnt
		FROM TMP_LCF_1;

		IF (lcf1cnt = 0) THEN
			InsertTmpLcf1;
		END IF;

		InsertTmpLcfIcp;                         --* limits locations to the ones specified in amd_spare_networks
		InsertL67TmpLcfIcp;

		FOR rec IN docCur LOOP

			goodtin   := CalcQuantity(rec.doc_no, 'TIN');
			badtin    := CalcBadQuantity(rec.doc_no, 'TIN');
			goodtrn   := CalcQuantity(rec.doc_no, 'TRN');
			badtrn    := CalcBadQuantity(rec.doc_no, 'TRN');
			tinqty    := goodtin + goodtrn;
			badtinqty := badtin  + badtrn;

			isu       := CalcQuantity(rec.doc_no, 'ISU');
			msi       := CalcQuantity(rec.doc_no, 'MSI');
			duo       := CalcQuantity(rec.doc_no, 'DUO');
			doc       := CalcQuantity(rec.doc_no, 'DOC');

			duoqty    := duo - doc;

			IF duoqty < 0 THEN
				duoqty := 0;
			END IF;

			ntinqty   := isu + msi + duoqty - badtinqty;
			otherqty  := ntinqty - tinqty;

			IF otherqty > 0 THEN
				qty    := tinqty + otherqty;
			ELSE
				qty    := tinqty;
			END IF;

			IF qty != 0 THEN

				--
				--  Get the NSN to use for BSSM
				--
				IF tinqty > 0 THEN
					SELECT MAX(nsn)
					INTO vNsn
					FROM TMP_LCF_ICP
					WHERE doc_no = rec.doc_no
						AND dic IN ('TIN', 'TRN');
				ELSE
					SELECT MAX(nsn)
					INTO vNsn
					FROM TMP_LCF_ICP
					WHERE doc_no = rec.doc_no
						AND dic NOT IN ('TIN', 'TRN');
				END IF;

				IF (vNsn IS NOT NULL) THEN
					reqDate := rec.trans_date;

					--
					-- send data to bssm table for extract to bssm
					--
					INSERT INTO AMD_BSSM_SOURCE
					(
						requisition_no,
						requisition_date,
						quantity,
						loc_sid,
						nsn
					)
					VALUES
					(
						rec.doc_no,
						reqDate,
						qty,
						rec.loc_sid,
						vNsn
					);

					BEGIN
						nsiSid := Amd_Utils.GetNsiSid(pNsn=>vNsn);

						INSERT INTO TMP_AMD_DEMANDS
						(
							doc_no,
							doc_date,
							nsi_sid,
							loc_sid,
							quantity,
							action_code,
							last_update_dt
						)
						VALUES
						(
							rec.doc_no,
							reqDate,
							nsiSid,
							rec.loc_sid,
							qty,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);

					EXCEPTION
						WHEN NO_DATA_FOUND THEN
							NULL;      -- nsiSid not found generates this, just ignore
--						when others then
--							amd_utils.InsertErrorMsg(loadNo,'AMD_DEMAND.LoadAmdDemands',
--									'Exception: OTHERS','insert into tmp_amd_demands',null,sysdate,
--									pMsg=>substr(sqlerrm,1,2000));
					END;

				END IF;

			END IF;

		END LOOP;

	END LoadAmdDemands;
    
    
PROCEDURE LoadFmsDemands IS
		CURSOR demandCur IS
SELECT
                RTRIM(asp.nsn) nsn,
                RTRIM(t.tran_id) tran_id,
                t.created_datetime,
                (NVL(t.qty ,0)) quantity,
                asn2.loc_sid,
                substr(t.sc,8,6),
                RTRIM(t.part) part
            FROM
                TRHI t,
                amd_spare_parts asp,
                amd_spare_networks asn1,
                amd_spare_networks asn2
 
            WHERE
                asp.part_no = t.part
                and asp.action_code != 'D'
                AND (NVL(t.qty ,0)) != 0
                AND SUBSTR(t.sc,8,6) = (asn1.loc_id)
                and asn1.mob = asn2.loc_id(+)
                and asn1.loc_type = 'FMS';            
                
	loadNo    NUMBER;
	nsiSid    NUMBER;
	nsnAmd    VARCHAR2(20); 
    

	BEGIN
		loadNo := Amd_Utils.GetLoadNo('TRHI','AMD_DEMANDS');

		FOR rec IN demandCur LOOP

			nsnAmd := Amd_Utils.FormatNsn(rec.nsn,'AMD');

			INSERT INTO AMD_BSSM_SOURCE
			(
				requisition_no,
				requisition_date,
				quantity,
				loc_sid,
				nsn
			)
			VALUES
			(
				rec.tran_id,
				rec.created_datetime,
				rec.quantity,
				rec.loc_sid,
				nsnAmd
			);

			BEGIN
				nsiSid := Amd_Utils.GetNsiSid(pPart_no=>rec.part);

				INSERT INTO TMP_AMD_DEMANDS
				(
					doc_no,
					doc_date,
					nsi_sid,
					loc_sid,
					quantity,
					action_code,
					last_update_dt
				)
				VALUES
				(
					rec.tran_id,
					rec.created_datetime,
					nsiSid,
					rec.loc_sid,
					rec.quantity,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
				);

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;      -- nsiSid not found generates this, just ignore
--				when others then
--					amd_utils.InsertErrorMsg(loadNo,'AMD_DEMAND.LoadBascUkDemands',
--							'Exceptions: OTHERS','insert into tmp_amd_demands',null,sysdate,
--							pMsg=>substr(sqlerrm,1,2000));
			END;
		END LOOP;

	END;

	PROCEDURE LoadBascUkDemands IS
		CURSOR demandCur IS
			SELECT
				RTRIM(c.nsn) nsn,
				RTRIM(r.request_id) request_id,
				r.created_datetime,
				(NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) quantity,
				asn.loc_sid,
				RTRIM(r.prime) prime
			FROM
				REQ1 r,
				CAT1 c,
				(SELECT
					DECODE(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					DECODE(asn1.loc_type,'TMP',asn2.loc_id ,asn1.loc_id ) loc_id
				FROM
					AMD_SPARE_NETWORKS asn1,
					AMD_SPARE_NETWORKS asn2
				WHERE
					asn1.mob = asn2.loc_id(+)) asn
			WHERE
				r.prime = c.part
				AND r.nsn IS NOT NULL
				AND (r.request_id LIKE 'EY1746%'
                    or r.request_id LIKE 'EZ1746%')
				AND r.select_from_sc LIKE 'C17%'
				AND (NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) != 0
				AND SUBSTR(request_id,11,1) != 'S'
				AND r.status not in  ('X','C')
				AND SUBSTR(r.request_id,3,4) = substr(asn.loc_id,3,4)
			UNION
			SELECT
				RTRIM(c.nsn) nsn,
				RTRIM(r.request_id) request_id,
				r.created_datetime,
				(NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) quantity,
				asn.loc_sid,
				RTRIM(r.prime) prime
			FROM
				REQ1 r,
				CAT1 c,
				(SELECT
					DECODE(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					DECODE(asn1.loc_type,'TMP',asn2.loc_id,asn1.loc_id ) loc_id
				FROM
					AMD_SPARE_NETWORKS asn1,
					AMD_SPARE_NETWORKS asn2
				WHERE
					asn1.mob = asn2.loc_id(+)) asn
			WHERE
				r.prime = c.part
				AND r.nsn IS NOT NULL
				AND r.select_from_sc LIKE 'C17%'
				AND (r.request_id LIKE 'EY1213%'
                    OR r.request_id LIKE 'EB1213%')
				AND asn.loc_id = 'EY1746'
				AND (NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) != 0
				AND SUBSTR(request_id,11,1) != 'S'
				AND r.status not in ('X','C')
				UNION
			SELECT
				RTRIM(c.nsn) nsn,
				RTRIM(r.request_id) request_id,
				r.created_datetime,
				(NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) quantity,
				asn.loc_sid,
				RTRIM(r.prime) prime
			FROM
				REQ1 r,
				CAT1 c,
				(SELECT
					DECODE(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					DECODE(asn1.loc_type,'TMP',asn2.loc_id,asn1.loc_id ) loc_id
				FROM
					AMD_SPARE_NETWORKS asn1,
					AMD_SPARE_NETWORKS asn2
				WHERE
					asn1.mob = asn2.loc_id(+)) asn
			WHERE
				r.prime = c.part
				AND r.nsn IS NOT NULL
				AND r.select_from_sc LIKE 'C17%'
				AND r.request_id LIKE 'FB2065%'
				AND asn.loc_id = 'EY1746'
				AND (NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) != 0
				AND SUBSTR(request_id,11,1) != 'S'
				AND r.status not in  ('X','C')
				UNION
			 SELECT
				RTRIM(c.nsn) nsn,
				RTRIM(r.request_id) request_id,
				r.created_datetime,
				(NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) quantity,
				asn.loc_sid,
				RTRIM(r.prime) prime
			FROM
				REQ1 r,
				CAT1 c,
				(SELECT
					DECODE(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					DECODE(asn1.loc_type,'TMP',asn2.loc_id,asn1.loc_id ) loc_id
				FROM
					AMD_SPARE_NETWORKS asn1,
					AMD_SPARE_NETWORKS asn2
				WHERE
					asn1.mob = asn2.loc_id(+)) asn
			WHERE
				r.prime = c.part
				AND r.nsn IS NOT NULL
				AND r.select_from_sc LIKE 'C17%'
				AND r.request_id LIKE 'FB2029%'
				AND asn.loc_id = 'EY1746'
				AND (NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) != 0
				AND SUBSTR(request_id,11,1) != 'S'
				AND r.status not in ('X','C')
				UNION
			SELECT
				RTRIM(c.nsn) nsn,
				RTRIM(r.request_id) request_id,
				r.created_datetime,
				(NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) quantity,
				asn.loc_sid,
				RTRIM(r.prime) prime
			FROM
				REQ1 r,
				CAT1 c,
				(SELECT
					DECODE(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					DECODE(asn1.loc_type,'TMP',asn2.loc_id,asn1.loc_id ) loc_id
				FROM
					AMD_SPARE_NETWORKS asn1,
					AMD_SPARE_NETWORKS asn2
				WHERE
					asn1.mob = asn2.loc_id(+)) asn
			WHERE
				r.prime = c.part
				AND r.nsn IS NOT NULL
				AND r.select_from_sc LIKE 'C17%'
				AND r.request_id LIKE 'FB2039%'
				AND asn.loc_id = 'EY1746'
				AND (NVL(r.qty_issued ,0)+ NVL(r.qty_due,0) + NVL(r.qty_reserved,0)) != 0
				AND SUBSTR(request_id,11,1) != 'S'
				AND r.status not in ('X','C')
			ORDER BY
				1;
				
	/* CURSOR demandSACur IS
		   SELECT
				 RTRIM(o.order_no) order_no,
				 o.created_datetime,
				 (NVL(o.qty_due,0) + NVL(o.qty_completed,0)) quantity,
				 asn.loc_sid,
				 RTRIM(o.part) part_no
		  FROM
				 ORD1 o,
				 CAT1 c,
				 (SELECT
					DECODE(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					DECODE(asn1.loc_type,'TMP',asn2.loc_id ,asn1.loc_id ) loc_id
				 FROM
					AMD_SPARE_NETWORKS asn1,
					AMD_SPARE_NETWORKS asn2
				 WHERE
					asn1.mob = asn2.loc_id(+)) asn
          WHERE
				 (o.part) = (c.part)
				 AND o.sc LIKE 'C17%'
				 AND o.order_no LIKE 'SA%'
				 AND SUBSTR(o.sc ,8,6) != 'MODKLY'
				 AND asn.loc_id LIKE 'EY1746%'
				 AND o.order_type  = 'C'
				 AND o.status != 'C'
				 AND (NVL(o.qty_due,0) + NVL(o.qty_completed,0)) != 0
				 AND TO_CHAR(o.created_docdate,'mm/dd/yyyy') < '04/01/2005'; */

		loadNo    NUMBER;
		nsiSid    NUMBER;
		nsnAmd    VARCHAR2(20);
	BEGIN
		loadNo := Amd_Utils.GetLoadNo('REQ1','AMD_DEMANDS');

		FOR rec IN demandCur LOOP

			nsnAmd := Amd_Utils.FormatNsn(rec.nsn,'AMD');

			INSERT INTO AMD_BSSM_SOURCE
			(
				requisition_no,
				requisition_date,
				quantity,
				loc_sid,
				nsn
			)
			VALUES
			(
				rec.request_id,
				rec.created_datetime,
				rec.quantity,
				rec.loc_sid,
				nsnAmd
			);

			BEGIN
				nsiSid := Amd_Utils.GetNsiSid(pPart_no=>rec.prime);

				INSERT INTO TMP_AMD_DEMANDS
				(
					doc_no,
					doc_date,
					nsi_sid,
					loc_sid,
					quantity,
					action_code,
					last_update_dt
				)
				VALUES
				(
					rec.request_id,
					rec.created_datetime,
					nsiSid,
					rec.loc_sid,
					rec.quantity,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
				);

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;      -- nsiSid not found generates this, just ignore
--				when others then
--					amd_utils.InsertErrorMsg(loadNo,'AMD_DEMAND.LoadBascUkDemands',
--							'Exceptions: OTHERS','insert into tmp_amd_demands',null,sysdate,
--							pMsg=>substr(sqlerrm,1,2000));
			END;
		END LOOP;
      
      /*FOR rec IN demandSaCur LOOP
		   BEGIN
			 	nsiSid := Amd_Utils.GetNsiSid(pPart_no=>rec.part_no);
				 
				INSERT INTO TMP_AMD_DEMANDS
				 (
				  		doc_no,
						doc_date,
						nsi_sid,
						loc_sid,
						quantity,
						action_code,
						last_update_dt
				 )
            VALUES
				 (
				  	   rec.order_no,
					   rec.created_datetime,
					   nsiSid,
					   rec.loc_sid,
					   rec.quantity,
					   Amd_Defaults.INSERT_ACTION,
					   SYSDATE
				 );
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				  NULL;
		   END;
		END LOOP; */

	END;

	PROCEDURE amd_demand_a2a IS

	   CURSOR get_new_demands_cur IS
	   SELECT doc_no, doc_date, doc_date_defaulted, nsi_sid, loc_sid,
	          quantity, action_code, last_update_dt
	     FROM TMP_AMD_DEMANDS a
	    WHERE NOT EXISTS (SELECT 'x'
	                        FROM AMD_DEMANDS b
			       WHERE a.doc_no = b.doc_no
				 AND a.loc_sid = b.loc_sid);


	BEGIN
	   FOR get_new_demands_rec IN get_new_demands_cur LOOP
	   
   -- insert into amd_demands just the additions from tmp_amd_demands
	     INSERT INTO AMD_DEMANDS VALUES
		    (get_new_demands_rec.doc_no,
		     get_new_demands_rec.doc_date,
		     get_new_demands_rec.doc_date_defaulted,
		     get_new_demands_rec.nsi_sid,
		     get_new_demands_rec.loc_sid,
		     get_new_demands_rec.quantity,
		     get_new_demands_rec.action_code,
		     get_new_demands_rec.last_update_dt
	       );


	   END LOOP;

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      RAISE_APPLICATION_ERROR (-20001,'no data found amd_demand_a2a proc for loc_id, amd_spare_networks');
	   WHEN OTHERS THEN
	      RAISE_APPLICATION_ERROR (-20001,'OTHERS: amd_demand_a2a proc SQLERRM '||SQLERRM||' SQLCODE '||SQLCODE);
  END amd_demand_a2a;

  PROCEDURE prime_part_change (old_part_no AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE,
                               new_part_no AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE) AS

     CURSOR get_nsi_sid_cur (cv_prime_part_no	AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE)IS
     SELECT nsi_sid
       FROM AMD_NATIONAL_STOCK_ITEMS
      WHERE prime_part_no = cv_prime_part_no;

     CURSOR get_demands_cur (cv_nsi_sid   AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) IS
     SELECT a.doc_no, a.doc_date, a.doc_date_defaulted, a.nsi_sid, b.spo_location,  -- changed loc_id to spo_location . Thuy 2/16/06
	         a.quantity, a.action_code, a.last_update_dt
	    FROM AMD_DEMANDS a, AMD_SPARE_NETWORKS b
	   WHERE a.nsi_sid = cv_nsi_sid
	     AND a.loc_sid = b.loc_sid;

  BEGIN
--  This iteration is for all the 'D' using the old_part_no being passed
--  Then read them with the new_part_no being passed

  	  FOR get_nsi_sid_rec IN get_nsi_sid_cur (old_part_no) LOOP
  	    FOR get_demands_rec IN get_demands_cur (get_nsi_sid_rec.nsi_sid) LOOP
			
			null ;

         
		 END LOOP;
	  END LOOP;
  END;

    function getFiscalPeriod(aDate in date) return number is
        the_year number := to_number(to_char(aDate,'YYYY')) ;
        the_month number := to_number(to_char(aDate,'MM')) ;
    begin
        if the_month <= 9 then
            return to_number(the_year) ;
        else
            return to_number(the_year) + 1 ;
        end if ;                                
    end getFiscalPeriod ;

    function getCalendarDate(period in number) return date is
        cur_year number := to_number(to_char(sysdate,'YYYY')) ;
        cur_month number := to_number(to_char(sysdate,'MM')) ;
        calendar_date date := null; -- return null if the period has expired
    begin
        if period = cur_year then
            if cur_month <= 9 then
                calendar_date := to_date(to_char(cur_month) || '/01/' || to_char(cur_year),'MM/DD/YYYY') ;
            else
                null ; -- do nothing since october starts a new fiscal year.  So, period has expired if cur_month >= 10
            end if ;
        elsif period > cur_year then
            if cur_month < 10 then
                calendar_date := to_date('10/01/' || to_char(period - 1),'MM/DD/YYYY') ;
            else
                calendar_date := to_date(to_char(cur_month) || '/01/' || to_char(period - 1),'MM/DD/YYYY') ;
            end if ;                
       end if ;
       return calendar_date ;
    end getCalendarDate ;
    
	FUNCTION doDmndFrcstConsumablesDiff(
			 nsn	IN VARCHAR2,
			 sran       IN VARCHAR2,
			 period		     IN NUMBER,
			 demand_forecast IN NUMBER,
             duplicate in NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER is
             
             
        procedure updateRow is
        begin
            update amd_dmnd_frcst_consumables
            set demand_forecast = doDmndFrcstConsumablesDiff.demand_forecast,
            duplicate = doDmndFrcstConsumablesDiff.duplicate,
            action_code = doDmndFrcstConsumablesDiff.action_code,
            last_update_dt = sysdate
            where nsn = doDmndFrcstConsumablesDiff.nsn
            and sran = doDmndFrcstConsumablesDiff.sran
            and period = doDmndFrcstConsumablesDiff.period ;    
        end updateRow ;
        
        procedure insertRow is
        begin
            
            insert into amd_dmnd_frcst_consumables
            (nsn, sran, period, demand_forecast, duplicate, action_code )
            values (nsn, sran, period, demand_forecast, duplicate, action_code) ;
            
        exception 
            when standard.DUP_VAL_ON_INDEX then
                updateRow ;
        end insertRow ;
        
    begin
        if action_code = amd_defaults.INSERT_ACTION then
            insertRow ;
        elsif action_code = amd_defaults.UPDATE_ACTION then
            updateRow ;
        elsif action_code = amd_defaults.DELETE_ACTION then
            updateRow ;
		ELSE
			 errorMsg(sqlFunction => action_code, tableName => 'doDmndFrcstConsumables', pError_Location => 110,
                key1 => nsn,
                key2 => sran, 
                key3 => period) ;
			 raise badActionCode ;
        end if ;
        
       return 0 ;
    exception when others then
        errorMsg(sqlFunction => action_code, tableName => 'doDmndFrcstConsumables', pError_Location => 120,
                    key1 => nsn,
                    key2 => sran, 
                    key3 => period) ;
        raise ;
        
    end doDmndFrcstConsumablesDiff ;
    
    procedure genDuplicateForConsumables is
            
        type demandTab is table of tmp_amd_dmnd_frcst_consumables%rowtype 
        index by varchar2(23) ;
        
        demands demandTab ;
        cursor demandsNotSame(the_current_period number) is
        select
        case
            when to_date('10/01/' || to_char(period - 1),'MM/DD/YYYY') >= trunc(sysdate,'Month') then
                months_between(to_date('09/01/' || period,'MM/DD/YYYY'), to_date('10/01/' || to_char(period - 1),'MM/DD/YYYY') )         
            when sysdate <= to_date('09/01/' || period,'MM/DD/YYYY') then 
                months_between(to_date('09/01/' || period,'MM/DD/YYYY'), trunc(sysdate,'Month'))  
            else 0     
        end calc_duplicate,
        tmp.* from tmp_amd_dmnd_frcst_consumables tmp,
        (
        select nsn, sran, count(*) from (
        select nsn, sran, demand_forecast, count(period) from tmp_amd_dmnd_frcst_consumables
        where period >= the_current_period
        group by nsn, sran, demand_forecast
        ) group by nsn, sran
        having count(*) > 1
        ) x
        where tmp.nsn = x.nsn
        and tmp.sran = x.sran
        and tmp.period >= the_current_period
        --and tmp.nsn = '1560013299845'
        --and tmp.sran = 'FB4400'
        order by tmp.nsn, tmp.sran, tmp.period ;
        
        totDuplicates number := 0 ;
        nsn tmp_amd_dmnd_frcst_consumables.nsn%type ;
        sran tmp_amd_dmnd_frcst_consumables.SRAN%type ;
        demand_forecast tmp_amd_dmnd_frcst_consumables.demand_forecast%type ;
        period tmp_amd_dmnd_frcst_consumables.period%type ;
        dupValue number := 0 ;
        DUP_THRESHOLD constant number := 66 ;
        cur_period number := getFiscalPeriod(sysdate) ;
        
        procedure doUpdate(nsn in varchar2, sran in varchar2, period in number) is
        begin
            update tmp_amd_dmnd_frcst_consumables
            set duplicate = dupValue
            where nsn = doUpdate.nsn
            and sran = doUpdate.sran
            and period = doUpdate.period ; 
            if totDuplicates + dupValue > DUP_THRESHOLD then
                totDuplicates := DUP_THRESHOLD ;
            else                
                totDuplicates := totDuplicates + dupValue ;
            end if ;                                                                                              
        end doUpdate ; 
   
    begin
        for rec in demandsNotSame(cur_period) loop
            if nsn is null then
                nsn := rec.nsn ;
                sran := rec.sran ;
                demand_forecast := rec.demand_forecast ;
                period := rec.period ;
            end if ;
            if nsn || sran <> rec.nsn || rec.sran then
                if dupValue > 0 then
                    doUpdate(nsn,sran,period) ;
                end if ;                    
                totDuplicates := 0 ;
                dupValue := 0 ;
                nsn := rec.nsn ;
                sran := rec.sran ;
                period := rec.period ;
                demand_forecast := rec.demand_forecast ;
            end if ;
            if demand_forecast <> rec.demand_forecast then
                if dupValue > 0 then
                    doUpdate(nsn,sran,period) ;
                end if ;
                dupValue := 0 ;
                period := rec.period ;
                demand_forecast := rec.demand_forecast ;
            end if ;                            
            if totDuplicates + dupValue + rec.calc_duplicate + 1 > DUP_THRESHOLD then
                dupValue :=  DUP_THRESHOLD - totDuplicates ;
            else
                dupValue := dupValue + rec.calc_duplicate + 1 ;
            end if ;
        end loop ;
        if dupValue > 0 then
            doUpdate(nsn,sran,period) ;
        end if ;            
        
        update tmp_amd_dmnd_frcst_consumables a
        set duplicate = DUP_THRESHOLD
        where duplicate is null 
        and period = cur_period ;
              
        commit ;
    end genDuplicateForConsumables ;

        function getDebugYorN return varchar2 is
        begin
            if debug then
                return 'Y' ;
            else
                return 'N' ;
            end if ;            
        end getDebugYorN ;   
        
        procedure setDebug(switch in varchar2) is
        begin
            debug := upper(switch) in ('Y','T','YES','TRUE') ;
            if debug then
                dbms_output.ENABLE(100000) ;
            else
                dbms_output.DISABLE ;
            end if ;                    
        end setDebug ;


	procedure version is
	begin
		 writeMsg(pTableName => 'amd_demand', 
		 		pError_location => 10, pKey1 => 'amd_demand', pKey2 => '$Revision:   1.44  $') ;
	end version ;

	function getVersion return varchar2 is
    	begin
        	return '$Revision:   1.44  $' ;
    	end getVersion ;
	
END Amd_Demand;
/


DROP PUBLIC SYNONYM AMD_DEMAND;

CREATE PUBLIC SYNONYM AMD_DEMAND FOR AMD_OWNER.AMD_DEMAND;


GRANT EXECUTE ON AMD_OWNER.AMD_DEMAND TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_DEMAND TO AMD_WRITER_ROLE;

