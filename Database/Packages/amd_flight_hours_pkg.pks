CREATE OR REPLACE PACKAGE amd_flight_hours_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Jul 27 2005 12:08:58  $
    $Workfile:   amd_flight_hours_pkg.pks  $
         $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\amd_flight_hours_pkg.pks-arc  $
/*   
/*      Rev 1.0   Jul 27 2005 12:08:58   zf297a
/*   Initial revision.
*/
  PROCEDURE amd_base_history;
  PROCEDURE amd_base_forecast;
END amd_flight_hours_pkg;
/
