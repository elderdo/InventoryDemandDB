/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   02 Mar 2009 08:28:40  $
    $Workfile:   LpLeadTime.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpLeadTime.sql.-arc  $
/*   
/*      Rev 1.0   02 Mar 2009 08:28:40   zf297a
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
		select distinct batch from spoc17v2.x_imp_lp_lead_time 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_lp_lead_time 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_lp_lead_time') ;


quit




