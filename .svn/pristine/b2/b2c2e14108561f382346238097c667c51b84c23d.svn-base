CREATE OR REPLACE PACKAGE amd_asCapableFlying_pkg
as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
     $Date:   Dec 01 2005 09:53:36  $
    $Workfile:   amd_asCapableFlying_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_asCapableFlying_pkg.pks-arc  $
/*   
/*      Rev 1.1   Dec 01 2005 09:53:36   zf297a
/*   added pvcs keywords
*/
  --
	-- SCCSID: amd_ascapableflying_pkg.sql  1.2  Modified: 08/28/02 16:07:40
	--
	-- Date      By            History
	-- --------  ------------  -------------------------------------------
	-- 06/18/02  kcs		   Initial Implementation
	-- 08/16/02	 kcs		   add function isChild. used in updatedistribfornewac
	--							to only process parents or items with no kids.
	--							i.e. do not process children.
	-- 08/22/02	 kcs		   change updateDistribfornewac to process those
	--							ac not accounted for by new column in amd aircrats

	AIRFORCEONLY constant varchar2(2) := 'P%';
	UKONLY constant varchar2(2) := 'U%';
    type r_timePd is record(
            timePeriodStart date,
            timePeriodEnd date
    );

    procedure adjustForRetrofit(pDate date DEFAULT sysdate);
    procedure updatePercentages;
   	procedure updateDistribForNewAc(pDate date DEFAULT sysdate);



  	function isPartOnTail(pNsiSid amd_national_stock_items.nsi_sid%type, pTailNo amd_ltd_fleet_size_member.tail_no%type) return boolean;
	function getNumAcPerLocTimePd_all(pTimePeriodStart date, pTimePeriodEnd date, pAircraftOwner varchar2 default AIRFORCEONLY ) return number;
	function getNumAcPerLocTimePd(pTimePeriodStart date, pTimePeriodEnd date, pLocSid amd_spare_networks.loc_sid%type, pAircraftOwner varchar2 default AIRFORCEONLY)	return number;
	function getTimePdStartAndEnd(pDate date) return r_timePd;


end amd_asCapableFlying_pkg;
/
