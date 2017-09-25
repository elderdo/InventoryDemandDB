CREATE OR REPLACE package body amd_best_spares_input_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Nov 30 2005 12:20:50  $
    $Workfile:   AMD_BEST_SPARES_INPUT_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_BEST_SPARES_INPUT_PKG.pkb-arc  $
/*   
/*      Rev 1.1   Nov 30 2005 12:20:50   zf297a
/*   added PVCS keywords
*/	
	procedure getBliss
	is
		cursor bliss is
			select
				replaced.nsn || '	' ||
				replaced.PRIME_PART_NO || '	' ||
				REPLACED_BY.nsn || '	' || replaced_by.PRIME_PART_NO as info
			from
				AMD_RELATED_NSI_PAIRS arnp,
				amd_national_stock_items replaced,
				amd_national_stock_items replaced_by
			where
				arnp.REPLACED_BY_NSI_SID = replaced_by.NSI_SID and
				arnp.REPLACED_NSI_SID = replaced.NSI_SID and
				replaced_by.LATEST_CONFIG = 'Y';
	begin
			dbms_output.put_line('OLD_NSN	OLD_PN	NEW_NSN	NEW_PN');
			for blissRec in bliss
			loop
				dbms_output.put_line(blissRec.info);
			end loop;
	end getBliss;

	procedure getAsCapablePercent(pDate date DEFAULT sysdate) is
		cursor asCap is
			select
				time_period_start,
				nsn || '	' ||
				loc_id || '	' ||
				to_char(add_months(time_period_start, -2), 'MM/DD/YYYY') || '	' ||
				to_char(time_period_end, 'MM/DD/YYYY') || '	' ||
				to_char(as_capable_percent, 999.99) as info
			from
				amd_nsi_loc_distribs anld,
				amd_spare_networks asn,
				amd_national_stock_items ansi
			where
				anld.nsi_sid = ansi.nsi_sid and
				asn.loc_sid = anld.loc_sid and
				time_period_start > pDate;
	begin
			dbms_output.put_line('NSN	SRAN	START_DATE	END_DATE	PERCENT_AS_CAPABLE');
			for asCapRec in asCap
			loop
				if (to_char(asCapRec.time_period_start, 'MON') in ('MAR', 'JUN', 'SEP', 'DEC')) then
					dbms_output.put_line(asCapRec.info);
				end if;
			end loop;
	end getAsCapablePercent;

	procedure getUpgradeable is
		cursor upg is
			select
				replaced.nsn || '	' || replaced_by.nsn as info
			from
				amd_related_nsi_pairs arnp,
				amd_national_stock_items replaced,
				amd_national_stock_items replaced_by
			where arnp.REPLACED_NSI_SID = replaced.NSI_SID and
				arnp.REPLACED_BY_NSI_SID = replaced_by.NSI_SID and
				arnp.UPGRADEABLE = 'Y';
	begin
			dbms_output.put_line('OLD_NSN	NEW_NSN');
			for upgRec in upg
			loop
				dbms_output.put_line(upgRec.info);
			end loop;
	end getUpgradeable;
end amd_best_spares_input_pkg;
/
