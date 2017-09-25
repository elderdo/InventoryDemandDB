CREATE OR REPLACE PACKAGE AMD_OWNER.A2a_consumables_Pkg AS
    
/*
      $Author:   zf297a  $
    $Revision:   1.7  $
        $Date:   13 Oct 2008 09:17:22  $
    $Workfile:   A2A_CONSUMABLES_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_CONSUMABLES_PKG.pks.-arc  $
/*   
/*      Rev 1.7   13 Oct 2008 09:17:22   zf297a
/*   Added setDebug interface
/*   
/*      Rev 1.6   28 Aug 2008 15:33:34   zf297a
/*   Added interface getVersion
/*   
/*      Rev 1.5   12 Aug 2008 08:05:58   zf297a
/*   Added new interface isPartValidYorN with additional arguments: part_no,  smr_code, nsn, planner_code, and mtbdr.
/*   
/*      Rev 1.4   19 Sep 2007 16:53:54   zf297a
/*   Added new public interface isPartValid.
/*   
/*      Rev 1.3   16 Aug 2007 14:25:48   zf297a
/*   Added interface for procedure version.
/*   
/*      Rev 1.2   01 Jun 2007 11:30:08   zf297a
/*   put showReason in spec so that it can easily be turned on for all routines and removed it from all interfaces.
/*   Added new interface insertPartInfo with action code and all data that is needed to perform the action.
/*   
/*      Rev 1.1   30 May 2007 09:06:00   zf297a
/*   Added interface for isPlannerCodeValid and isPlannerCodeValidYorN
/*   
/*      Rev 1.0   29 May 2007 12:53:24   zf297a
/*   Initial revision.
*/    

    showReason boolean := false ;

    -- added 8/7/2008 by dse
    function isPartValidYorN(part_no in varchar2,    
        smr_code     in    amd_national_stock_items.smr_code%type,
        nsn          in    amd_spare_parts.nsn%type,
        planner_code in    amd_national_stock_items.planner_code%type,
        mtbdr        in    amd_national_stock_items.MTBDR%type ) return varchar2 ;

    function isPartValid(part_no in varchar2) return boolean ;
    function isPartValidYorN(part_no in varchar2) return varchar2 ;
    -- added 9/19/2007 by dse
    function isPartValid(part_no in varchar2,    
        smr_code     in    amd_national_stock_items.smr_code%type,
        nsn          in    amd_spare_parts.nsn%type,
        planner_code in    amd_national_stock_items.planner_code%type,
        mtbdr        in    amd_national_stock_items.MTBDR%type ) return boolean ;
        
    procedure insertPartInfo(part_no in varchar2, action_code in varchar2) ;
    
	procedure insertPartInfo(action_code in varchar2, part_no in varchar2, nomenclature in varchar2,
           mfgr in varchar2,  unit_issue in varchar2, smr_code in varchar2, nsn in varchar2, planner_code in varchar2,
	       third_party_flag in varchar2, mtbdr in number, price in number) ;
    
    function isPlannerCodeValid(plannerCode in amd_national_stock_items.planner_code%type) return boolean ;
    function isPlannerCodeValidYorN(plannerCode in amd_national_stock_items.planner_code%type) return varchar2 ;
    
    function getIndenture(smr_code_preferred in amd_national_stock_items.smr_code%type) return tmp_a2a_part_info.indenture%type ;
    
    procedure version ;
    function getVersion return varchar2 ; -- added 8/28/2008 by dse
    procedure setDebug(switch in varchar2) ; -- added 10/11/2008 by dse
    
end a2a_consumables_pkg ;
/
