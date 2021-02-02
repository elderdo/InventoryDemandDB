/* Formatted on 8/15/2019 11:40:02 AM (QP5 v5.294) */
WHENEVER OSERROR  EXIT FAILURE
WHENEVER SQLERROR EXIT FAILURE

SET ECHO ON
SET FEEDBACK ON


exec amd_owner.mta_truncate_table('amd_rbl_xcb','reuse storage') ;

INSERT INTO amd_rbl_xcb
   SELECT * FROM v_RBL_XCB_ITEM_DATA;

COMMIT;

QUIT
