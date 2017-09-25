CREATE OR REPLACE PACKAGE BODY "AMD_RMADS_SOURCE_TMP_PKG"   as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
     $Date:   Dec 01 2005 09:46:34  $
    $Workfile:   amd_rmads_source_tmp_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_rmads_source_tmp_pkg.pkb-arc  $
/*   
/*      Rev 1.1   Dec 01 2005 09:46:34   zf297a
/*   Add pvcs keywords
*/

	procedure LoadRmadsIntoAnsi is
	begin
		update amd_national_stock_items set
			mtbdr =
				(select mtbdr
				from amd_rmads_source_tmp
				where part_no = amd_national_stock_items.prime_part_no),
			qpei_weighted =
				(select qpei_weighted
				from amd_rmads_source_tmp
				where part_no = amd_national_stock_items.prime_part_no);
	end LoadRmadsIntoAnsi;

end amd_rmads_source_tmp_pkg;
/
