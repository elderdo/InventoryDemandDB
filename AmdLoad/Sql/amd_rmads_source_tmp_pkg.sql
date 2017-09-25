--
-- SCCSID: amd_rmads_source_tmp_pkg.sql  1.1  Modified: 11/26/01 10:03:29
--
-- Date      By            History
-- 11/26/01  Chung Lu      Initial Implementation
--

CREATE OR REPLACE package amd_rmads_source_tmp_pkg as

	procedure LoadRmadsIntoAnsi;

end amd_rmads_source_tmp_pkg;
/

CREATE OR REPLACE package body amd_rmads_source_tmp_pkg as

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
