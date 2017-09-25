CREATE OR REPLACE PACKAGE C17PGM.SPO_X_IMP_MOD_PKG AS
/******************************************************************************
   NAME:       SPO_X_IMP_MOD_PKG
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/8/2008             1. Created this package.
******************************************************************************/

  PROCEDURE ExpandDemandForecast(BatchNum IN NUMBER, currentPeriod IN DATE,
                                 duplicateCount IN NUMBER);

END SPO_X_IMP_MOD_PKG; 
/

