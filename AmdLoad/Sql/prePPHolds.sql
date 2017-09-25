/*
	$Author:   zf297a  $
      $Revision:   1.1  $
	  $Date:   19 Sep 2008 08:29:28  $
      $Workfile:   prePPHolds.sql  $
	   $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\prePPHolds.sql.-arc  $
/*   
/*      Rev 1.1   19 Sep 2008 08:29:28   zf297a
/*   AMD 3.2

**/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec c17pgm.SPO_PP_CUSTOMIZE_PKG.SaveHolds;

quit
