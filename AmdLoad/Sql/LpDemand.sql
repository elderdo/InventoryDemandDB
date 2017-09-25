/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   29 Jan 2010 14:04  $
    $Workfile:   LpDemand.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpDemand.sql.-arc  $
/*   
/*      Rev 1.0   19 Sep 2008 08:51:30   zf297a
/*   Initial revision.
/*   
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
		select distinct batch from spoc17v2.lp_demand 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.lp_demand 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_lp_demand') ;


quit




