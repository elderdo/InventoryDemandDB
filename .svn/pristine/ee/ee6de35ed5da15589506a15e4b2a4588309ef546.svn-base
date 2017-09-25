/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   24 Nov 2008 12:10:10  $
    $Workfile:   LpAttribute.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpAttribute.sql.-arc  $
/*   
/*      Rev 1.0   24 Nov 2008 12:10:10   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

delete from 
spoc17v2.interface_batch where batch in (
	select distinct batch from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_lp_attribute 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_lp_attribute 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_lp_attribute') ;


quit






