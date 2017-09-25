CREATE OR REPLACE PACKAGE amd_org_deployment_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.2  $
     $Date:   Jun 09 2006 12:38:10  $
    $Workfile:   amd_org_deployment_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_org_deployment_pkg.pks-arc  $
/*   
/*      Rev 1.2   Jun 09 2006 12:38:10   zf297a
/*   added interface version
/*   
/*      Rev 1.1   Dec 01 2005 09:39:04   zf297a
/*   added pvcs keywords
*/
  PROCEDURE load_org_deployment;
  
  -- added 6/9/2006 by dse
  procedure version ;
  
END amd_org_deployment_pkg;
/
