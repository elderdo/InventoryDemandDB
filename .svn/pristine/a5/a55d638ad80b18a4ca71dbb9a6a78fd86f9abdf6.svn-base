CREATE OR REPLACE PROCEDURE C17DEVLPR.DeleteHolds IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       DeleteHolds
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        7/29/2008    Don Wang       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     DeleteHolds
      Sysdate:         7/29/2008
      Date and Time:   7/29/2008, 11:14:49 AM, and 7/29/2008 11:14:49 AM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   DELETE FROM C17DEVLPR.QUEUED_REQUEST_ARCHIVE WHERE SNAPSHOT_TIMESTAMP < SYSDATE-30;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END DeleteHolds; 
/

