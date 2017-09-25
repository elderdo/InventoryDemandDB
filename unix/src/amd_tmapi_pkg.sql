CREATE OR REPLACE package amd_tmapi_pkg as
	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  12/03/01		  ks			initial implementation
	   -------------------------------------------------------------------

	   -- when need extra help for sql queries for tmapi

	function GetPriority(pNsn amd_spare_parts.nsn%type, pPartNo amd_spare_parts.part_no%type) return number;
	pragma restrict_references(DEFAULT,WNDS) ;
end amd_tmapi_pkg;
/
CREATE OR REPLACE package body amd_tmapi_pkg as
	   -- largeunitcost used when unit cost is null to force to lowest priority
	   -- smallunitcost used to ensure primary part has highest priority
	LARGEUNITCOST constant number := 999999999;
	SMALLUNITCOST constant number := -1;
	function GetPriority(pNsn amd_spare_parts.nsn%type, pPartNo amd_spare_parts.part_no%type) return number is
			priority number := null;
			cursor nsnPriority_cur is
				select nsn, part_no, rownum
				from
					(
				 		select
							asp.nsn,
				  			asp.part_no,
							decode(ansi.prime_part_no, asp.part_no, SMALLUNITCOST,
								nvl(decode(asp.unit_cost, null, asp.unit_cost_defaulted, asp.unit_cost), LARGEUNITCOST)) as unitCost
						from
							amd_spare_parts asp, amd_national_stock_items ansi
				 		where
							asp.nsn = pNsn and
							asp.nsn = ansi.nsn
						order by unitCost desc
	 				);
			nsnPrec nsnPriority_cur%rowtype;

	begin
			if (not nsnPriority_cur%isOpen) then
			   open nsnPriority_cur;
			end if;
			loop
		 		fetch nsnPriority_cur into nsnPrec;
				exit when not nsnPriority_cur%FOUND;
				if (nsnPrec.part_no = pPartNo) then
				   priority := nsnPrec.rownum;
				   exit;
				end if;
			end loop;
			close nsnPriority_cur;
	 		return priority;
	exception
		when no_data_found then
			return null;
	end GetPriority;
end amd_tmapi_pkg;
/

