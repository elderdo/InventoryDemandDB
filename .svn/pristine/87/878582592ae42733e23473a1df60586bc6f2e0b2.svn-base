SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_PEOPLE_ALL_V;

/* Formatted on 2008/06/03 10:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_people_all_v (emp_id,
                                                         bems_id,
                                                         dob,
                                                         first_name,
                                                         last_name,
                                                         component,
                                                         bus_unit,
                                                         division,
                                                         sub_div,
                                                         deptno,
                                                         shift,
                                                         emp_status,
                                                         contract_vendor_code,
                                                         admin_no,
                                                         admin_name,
                                                         last_update_date,
                                                         hrdeptid,
                                                         LOCATION,
                                                         flsa_status,
                                                         mgr_id,
                                                         hr_mgr_last_name,
                                                         hr_mgr_first_name,
                                                         acctg_bus_unit_nm,
                                                         acct_dept_nm,
                                                         FLOOR,
                                                         mail_code,
                                                         room_nmbr,
                                                         bldg,
                                                         stable_email,
                                                         last_org_lvl_z,
                                                         reports_to_hrdept_id,
                                                         work_phone,
                                                         dept_nmw,
                                                         payoffice_cdm,
                                                         acctg_loc_cdm,
                                                         la_mgr_id_bems,
                                                         la_mgr_last_name,
                                                         la_mgr_first_name,
                                                         mgmt_jobcode,
                                                         ps_supervisor_bems,
                                                         jobcode,
                                                         job_title_nmw,
                                                         lead_flgm,
                                                         lv_eff_dtw,
                                                         union_cd,
                                                         union_seniority_dt,
                                                         direct,
                                                         bems_idn,
                                                         standard_id,
                                                         mgr_idn,
                                                         la_mgr_id_bemsn,
                                                         ps_supervisor_bemsn
                                                        )
AS
   SELECT a.emp_id, a.bems_id, a.dob, a.first_name, a.last_name, a.component,
          a.bus_unit, a.division, a.sub_div, a.deptno, a.shift, a.emp_status,
          a.contract_vendor_code, a.admin_no, a.admin_name,
          a.last_update_date, a.hrdeptid, a.LOCATION, a.flsa_status, a.mgr_id,
          a.hr_mgr_last_name, a.hr_mgr_first_name, a.acctg_bus_unit_nm,
          a.acct_dept_nm, a.FLOOR, a.mail_code, a.room_nmbr, a.bldg,
          b.email_addr, a.last_org_lvl_z, a.reports_to_hrdept_id,
          a.work_phone, a.dept_nmw, a.payoffice_cdm, a.acctg_loc_cdm,
          a.la_mgr_id_bems, a.la_mgr_last_name, a.la_mgr_first_name,
          a.mgmt_jobcode, a.ps_supervisor_bems, a.jobcode, a.job_title_nmw,
          a.lead_flgm, a.lv_eff_dtw, a.union_cd, a.union_seniority_dt,
          a.direct, a.bems_idn, a.standard_id, a.mgr_idn, a.la_mgr_id_bemsn,
          a.ps_supervisor_bemsn
     FROM pdbsr_owner.pdbsr_people_all_mv a,
          pdbsr_owner.pdbsr_epdw_ns_people_mv b
    WHERE b.bems_idn = TO_NUMBER (a.bems_id);


DROP PUBLIC SYNONYM AMD_PEOPLE_ALL_V;

CREATE PUBLIC SYNONYM AMD_PEOPLE_ALL_V FOR AMD_OWNER.AMD_PEOPLE_ALL_V;


GRANT SELECT ON AMD_OWNER.AMD_PEOPLE_ALL_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.AMD_PEOPLE_ALL_V TO AMD_WRITER_ROLE;


