/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   12 Sep 2008 14:07:12  $
    $Workfile:   PartCausalType.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\PartCausalType.sql.-arc  $
/*   
/*      Rev 1.0   12 Sep 2008 14:07:12   zf297a
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
		select distinct batch from spoc17v2.x_imp_part_causal_type 
	) 
) ;

delete from spoc17v2.x_imp_interface_batch 
	where batch in (
		select distinct batch from spoc17v2.x_imp_part_causal_type 
	) ; 

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.x_imp_part_causal_type') ;


quit

