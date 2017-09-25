/*
      $Author:   zf297a  $
    $Revision:   1.5  $
        $Date:   31 Oct 2014
    $Workfile:   loadCat1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadCat1.sql.-arc  $
/*   
/*      Rev 1.5   31 Oct 2014   zf297a added nin
/*      Rev 1.4   20 Nov 2012   zf297a
/*      added checks for non-printable characters in the part_no
/*      replaced non-printable characters in nomenclature with null strings
/*      pretty printed the cat1 select
/*
/*      Rev 1.3   20 Feb 2009 09:12:44   zf297a
/*   Added link variable
/*   
/*      Rev 1.2   26 Nov 2008 00:34:16   zf297a
/*   Added edits of um_show_code and um_cap_code to make sure they are no longer than 2 characters
/*   
/*      Rev 1.1   17 Jul 2008 11:26:18   zf297a
/*   Skip parts with leading or trailing blanks.
/*   
/*      Rev 1.0   20 May 2008 14:30:48   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('cat1','reuse storage');

define link=&1


insert into cat1
(
	part,nsn,noun,prime,um_show_code,um_issue_code,um_turn_code,
	um_disp_code,um_cap_code,um_mil_code,asset_req_on_receipt,
	record_changed1_yn,record_changed2_yn,record_changed3_yn,
	record_changed4_yn,record_changed5_yn,record_changed6_yn,
	record_changed7_yn,record_changed8_yn,manuf_cage,ims_designator_code,
	source_code,serial_mandatory_b,smrc,isgp_group_no,
	abbr_part,errc,user_ref4,hazardous_material_code,
	user_ref7,mils_auto_process_b,remarks,ave_cap_lead_time,user_ref2,nin
)
SELECT TRIM (part),
       TRIM (nsn),
       REGEXP_REPLACE (TRIM (noun), '[^[:print:]]', ''),
       REGEXP_REPLACE (TRIM (prime), '[^[:print:]]', ''),
       CASE
          WHEN LENGTH (TRIM (um_show_code)) > 2
          THEN
             SUBSTR (TRIM (um_show_code), 1, 2)
          ELSE
             TRIM (um_show_code)
       END
          um_show_code,
       TRIM (um_issue_code),
       TRIM (um_turn_code),
       TRIM (um_disp_code),
       CASE
          WHEN LENGTH (TRIM (um_cap_code)) > 2
          THEN
             SUBSTR (TRIM (um_cap_code), 1, 2)
          ELSE
             TRIM (um_cap_code)
       END
          um_cap_code,
       TRIM (um_mil_code),
       asset_req_on_receipt,
       record_changed1_yn,
       record_changed2_yn,
       record_changed3_yn,
       record_changed4_yn,
       record_changed5_yn,
       record_changed6_yn,
       record_changed7_yn,
       record_changed8_yn,
       TRIM (manuf_cage),
       TRIM (ims_designator_code),
       TRIM (source_code),
       TRIM (serial_mandatory_b),
       TRIM (smrc),
       TRIM (isgp_group_no),
       TRIM (abbr_part),
       TRIM (errc),
       TRIM (user_ref4),
       TRIM (hazardous_material_code),
       TRIM (user_ref7),
       mils_auto_process_b,
       TRIM (remarks),
       TRIM (ave_cap_lead_time),
       TRIM (user_ref2),
       TRIM (nin)
  FROM cat1@&&link
 WHERE     source_code = amd_defaults.getSourceCode
       AND part NOT LIKE '% '
       AND part NOT LIKE ' %'
       AND REGEXP_INSTR (part, '[^[:print:]]') = 0 ;

exit 

