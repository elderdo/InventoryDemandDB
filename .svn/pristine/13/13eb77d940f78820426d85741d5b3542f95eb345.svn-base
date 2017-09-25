CREATE OR REPLACE PACKAGE C17DEVLPR.spo_lp_override_pkg AS
 /*
      $Author:   c970984  $
    $Revision:   1.1  $
        $Date:   Dec 11 2007 16:46:04  $
    $Workfile:   spo_lp_override_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\C17DEVLPR\spo_lp_override_pkg.pks.-arc  $
/*   
/*      Rev 1.1   Dec 11 2007 16:46:04   c970984
/*   12/07
/*   
/*      Rev 1.0   Oct 02 2007 11:14:28   c970984
/*   Initial revision.
/*   
/*   
/*      Rev 1.0   27 Sep 2007 17:27:12   C970984
/*   Initial revision.
*/
    
    TARGET_TABLE constant varchar2(40) := 'X_IMP_LP_OVERRIDE';
    

    function doLpOverrideDiff(part in varchar2, 
                              location in varchar2, 
                              override_type in varchar2,
                              override_user in varchar2, 
                              quantity in number, 
                              override_reason in varchar2, 
                              begin_date in date, 
                              end_date in date, 
                              action in varchar2) return number ;
    
    procedure initialize ;
    
    procedure version ;

   
end spo_lp_override_pkg ;
/