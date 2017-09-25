/*
	$Author: zf297a
	$Revision: 1.2 
	$Date: 2 June 2009 18:09
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec c17pgm.SPO_PP_CUSTOMIZE_PKG.UpdateHolds;
exec c17pgm.SPO_PP_CUSTOMIZE_PKG.DeleteHolds;

quit
