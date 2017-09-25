CREATE OR REPLACE PACKAGE amd_load_x as
/*
       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   Dec 01 2005 09:33:24  $
     $Workfile:   AMD_LOAD_X.pks  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOAD_X.pks.-arc  $
/*   
/*      Rev 1.0   Dec 01 2005 09:33:24   zf297a
/*   Initial revision.
*/
	--
	-- SCCSID: amd_load.sql  1.20  Modified: 03/05/03 13:25:37
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 09/28/01 FF     Initial implementation
	-- 10/22/01 FF     Removed references to venc, venn from LoadGold().
	-- 10/23/01 FF     Changed exception in LoadTempNsns() and passed GOLD
	--                 smr_code if nothing else.
	-- 10/30/01 FF     Fixed getPrime() to look at all records for a '17P','17B'
	--                 match.
	-- 11/02/01 FF     Fixed logic in LoadTempNsns() to include GetPrime() and
	--                 associate logic.
	-- 11/12/01 FF     Fixed LoadGold() to use the part as prime for ANY NSL
	--                 that gets an nsn from BSSM other than of the form NSL#.
	-- 11/15/01 FF     Mod LoadGold() and LoadMain() to let equiv parts get
	--                 values from prime for item_type,order_quantity,
	--                 planner_code and smr_code.
	-- 11/19/01 FF     Mod LoadTempNsns to ignore the last 2 char's of the nsn
	--                 if they are not numeric.
	-- 11/21/01 FF     Removed references to gold_mfgr_cage.
	-- 11/29/01 FF     Fixed LoadTempNsns() and added lock_sid=0 condition
	--                 to cursor in LoadTempNsns().
	-- 12/10/01 FF     Fixed cursor in LoadTempNsns() to link with
	--                 amd_spare_parts.
	-- 12/21/01 FF     Added acquisition_advice_code.
	-- 01/28/02 FF     Added "FROM" column as temp nsns to LoadTempNsns().
	-- 02/19/02 FF     Added logic for manuf_cage to GetPrime().
	-- 02/25/02 FF     Fixed GetPrime() priority logic.
	-- 03/05/02 FF     Added logic to unit_cost code to look at po's with 9
	--                 characters only.
	-- 03/18/02 FF     The noun field is no longer truncated.
	-- 04/03/02 FF     Populated mic in tmp_amd_spare_parts.
	-- 06/04/02 FF     Removed debug record limiter.
	-- 06/14/02 FF     Changed references to PSMS to use synonyms.
	-- 07/05/02 FF     Changed references to PSMV to use synonyms.
	-- 10/14/02 FF     Mod'ed loadGold() to blindly assign the part as a prime
	--                 only if sequenceTheNsl() returned an nsn of type NSL.
	-- 11/05/02 FF     Get unit_cost from gold.prc1 instead of tmp_main. This
	--                 is now done in loadGold() instead of loadMain().
	-- 02/21/03 FF     Added performLogicalDelete() to allow NSL's to get
	--                 their own sid.
	--

	procedure LoadGold;
	procedure LoadPsms;
	procedure LoadMain;
	procedure LoadTempNsns;

end amd_load_x;
/
