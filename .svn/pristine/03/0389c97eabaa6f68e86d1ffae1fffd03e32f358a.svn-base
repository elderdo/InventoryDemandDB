/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   31 Mar 2009 16:35:40  $
    $Workfile:   NetworkPart.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\NetworkPart.sql.-arc  $
/*   
/*      Rev 1.0   31 Mar 2009 16:35:40   zf297a
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
		select distinct batch from spoc17v2.x_imp_network_part 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_network_part 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_network_part') ;


quit

