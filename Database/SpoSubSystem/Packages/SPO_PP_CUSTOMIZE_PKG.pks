CREATE OR REPLACE PACKAGE C17PGM.SPO_PP_CUSTOMIZE_PKG AS
/******************************************************************************
   NAME:       SPO_HOLD_RELEASE_PKG
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        8/18/2008             1. Created this package.
******************************************************************************/

  PROCEDURE SaveHolds;
  PROCEDURE UpdateHolds;
  PROCEDURE DeleteHolds;
  PROCEDURE DeleteExcessAlerts;

END SPO_PP_CUSTOMIZE_PKG; 
/

