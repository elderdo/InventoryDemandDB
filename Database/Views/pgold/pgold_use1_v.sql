DROP VIEW AMD_OWNER.PGOLD_USE1_V;

/* Formatted on 7/9/2012 4:25:32 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_USE1_V
(
   USERID,
   USER_NAME,
   EMPLOYEE_NO,
   EMPLOYEE_STATUS,
   PHONE,
   IMS_DESIGNATOR_CODE
)
AS
   SELECT TRIM (userid),
          TRIM (user_name),
          TRIM (employee_no),
          employee_status,
          TRIM (phone),
          TRIM (ims_designator_code)
     FROM use1@amd_pgoldlb_link
    WHERE employee_no IS NOT NULL AND employee_status != 'I';


DROP PUBLIC SYNONYM PGOLD_USE1_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_USE1_V FOR AMD_OWNER.PGOLD_USE1_V;


GRANT SELECT ON AMD_OWNER.PGOLD_USE1_V TO AMD_READER_ROLE;
