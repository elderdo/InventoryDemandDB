/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   06 Jun 2008 21:43:12  $
    $Workfile:   LpBackorder.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpBackorder.sql.-arc  $
/*   
/*      Rev 1.0   06 Jun 2008 21:43:12   zf297a
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
		select distinct batch from spoc17v2.x_imp_lp_backorder 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_lp_backorder 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_lp_backorder') ;


quit





