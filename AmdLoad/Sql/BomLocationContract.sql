/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   10 Apr 2009 12:18:46  $
    $Workfile:   BomLocationContract.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\BomLocationContract.sql.-arc  $
/*   
/*      Rev 1.0   10 Apr 2009 12:18:46   zf297a
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
		select distinct batch from spoc17v2.x_imp_bom_location_contract 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_bom_location_contract 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_bom_location_contract') ;


quit

