CREATE OR REPLACE PROCEDURE C17DEVLPR.UpdateHolds IS
proposedID NUMBER;
qty NUMBER;
CURSOR c_Snapshot IS SELECT * FROM C17DEVLPR.QUEUED_REQUEST_SNAPSHOT;
/******************************************************************************
   NAME:       UpdateHolds
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        7/28/2008   Don Wang        1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     UpdateHolds
      Sysdate:         7/28/2008
      Date and Time:   7/28/2008, 3:03:32 PM, and 7/28/2008 3:03:32 PM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN

   proposedID := 0;
   FOR rec in c_Snapshot LOOP
        BEGIN
            
            SELECT QR.PROPOSED_REQUEST INTO proposedID
            FROM SPOC17V2.QUEUED_REQUEST QR INNER JOIN
            SPOC17V2.PROPOSED_REQUEST PR ON QR.PROPOSED_REQUEST = PR.ID
            WHERE QR.EXCEPTION_RULE=EXCEPTION_RULE AND PR.PART=rec.PART
            AND PR.SOURCE_LOCATION=rec.SOURCE_LOCATION AND PR.DESTINATION_LOCATION=
            rec.DESTINATION_LOCATION AND QUANTITY=rec.QUANTITY;
            
            -- only update if there is no release_date information yet
            -- and quantity is exactly equal (this is checked above)
            UPDATE SPOC17V2.QUEUED_REQUEST SET RELEASE_DATE=rec.RELEASE_DATE
            WHERE PROPOSED_REQUEST=proposedID;  
        
    
          
            
            EXCEPTION WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN OTHERS THEN
            -- Consider logging the error and then re-raise
                RAISE;    
        END;
        
    END LOOP;
 
    -- archive the current snapshot data into history table
    INSERT INTO C17DEVLPR.QUEUED_REQUEST_ARCHIVE 
    SELECT * FROM C17DEVLPR.QUEUED_REQUEST_SNAPSHOT;
    COMMIT;

END UpdateHolds; 
/

