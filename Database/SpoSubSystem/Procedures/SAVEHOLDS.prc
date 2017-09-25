CREATE OR REPLACE PROCEDURE C17DEVLPR.SaveHolds IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       SaveHolds
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        7/28/2008   Don Wang        1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SaveHolds
      Sysdate:         7/28/2008
      Date and Time:   7/28/2008, 2:10:56 PM, and 7/28/2008 2:10:56 PM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
    -- Assumes the table is already saved earlier during the last UpdateHold
    -- cannot truncate here due to permissions issue
   DELETE FROM C17DEVLPR.QUEUED_REQUEST_SNAPSHOT;
   INSERT INTO C17DEVLPR.QUEUED_REQUEST_SNAPSHOT
   SELECT PART, SOURCE_LOCATION, DESTINATION_LOCATION, DGI_LOCATION, DGI_PART,
   REQUEST_DATE, DUE_DATE, REQUEST_TYPE, REQUEST_STATUS, QUANTITY, QR.TIMESTAMP,
   SPO_USER, EXCEPTION_RULE, QUEUE_STATUS, RELEASE_DATE, SYSDATE FROM
   SPOC17V2.PROPOSED_REQUEST PR INNER JOIN SPOC17V2.QUEUED_REQUEST QR ON
   PR.ID=QR.PROPOSED_REQUEST WHERE RELEASE_DATE IS NOT NULL; 

    -- resets all hold information to nothing
   UPDATE SPOC17V2.QUEUED_REQUEST SET RELEASE_DATE=NULL;
   
   COMMIT;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END SaveHolds; 
/

