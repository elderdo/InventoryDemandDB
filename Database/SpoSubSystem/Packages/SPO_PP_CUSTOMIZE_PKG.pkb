CREATE OR REPLACE PACKAGE BODY C17PGM.SPO_PP_CUSTOMIZE_PKG AS
/******************************************************************************
   NAME:       SPO_PP_CUSTOMIZE_PKG
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        8/18/2008   Don Wang         1. Created this package body.
******************************************************************************/

    PROCEDURE SaveHolds IS
        BEGIN
   
        -- cannot truncate here due to permissions issue
        DELETE FROM c17pgm.QUEUED_REQUEST_SNAPSHOT;
        -- takes a snapshot of the current information in QUEUED_REQUEST
        INSERT INTO c17pgm.QUEUED_REQUEST_SNAPSHOT
        SELECT PART, SOURCE_LOCATION, DESTINATION_LOCATION, DGI_LOCATION, DGI_PART,
        REQUEST_DATE, DUE_DATE, REQUEST_TYPE, REQUEST_STATUS, QUANTITY, QR.TIMESTAMP,
        SPO_USER, EXCEPTION_RULE, QUEUE_STATUS, RELEASE_DATE, SYSDATE FROM
        SPOC17V2.PROPOSED_REQUEST PR INNER JOIN SPOC17V2.QUEUED_REQUEST QR ON
        PR.ID=QR.PROPOSED_REQUEST WHERE RELEASE_DATE IS NOT NULL; 

        -- resets all hold information to nothing, this must happen before
        -- post processing and UpdateHolds needs to run after to restore the holds
        UPDATE SPOC17V2.QUEUED_REQUEST SET RELEASE_DATE=NULL;
   
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            RAISE;
    END SaveHolds;


  PROCEDURE UpdateHolds IS
        proposedID NUMBER;
        CURSOR c_Snapshot IS SELECT * FROM c17pgm.QUEUED_REQUEST_SNAPSHOT;
   BEGIN

        proposedID := 0;
   FOR rec in c_Snapshot LOOP
        BEGIN
            -- match entry in snapshot with the new recommendations in PROPOSED_REQUEST
            -- only update if quantity has not changed.
            SELECT QR.PROPOSED_REQUEST INTO proposedID
            FROM SPOC17V2.QUEUED_REQUEST QR INNER JOIN
            SPOC17V2.PROPOSED_REQUEST PR ON QR.PROPOSED_REQUEST = PR.ID
            WHERE QR.EXCEPTION_RULE=EXCEPTION_RULE AND PR.PART=rec.PART
            AND PR.SOURCE_LOCATION=rec.SOURCE_LOCATION AND PR.DESTINATION_LOCATION=
            rec.DESTINATION_LOCATION AND QUANTITY=rec.QUANTITY;
            
            -- restore the RELEASE_DATE information from snapshot table
            UPDATE SPOC17V2.QUEUED_REQUEST SET RELEASE_DATE=rec.RELEASE_DATE
            WHERE PROPOSED_REQUEST=proposedID;    
            
            EXCEPTION WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN OTHERS THEN
                RAISE;    
        END;
        
    END LOOP;
 
    -- archive the current snapshot data into history table
    INSERT INTO c17pgm.QUEUED_REQUEST_ARCHIVE 
    SELECT * FROM c17pgm.QUEUED_REQUEST_SNAPSHOT;
    COMMIT;

END UpdateHolds;


-- cleans out any data in the archive older than 30 days
PROCEDURE DeleteHolds IS
  
    BEGIN
   
    DELETE FROM c17pgm.QUEUED_REQUEST_ARCHIVE WHERE SNAPSHOT_TIMESTAMP < SYSDATE-30;
    COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
        RAISE;
END DeleteHolds;

-- deletes Excess to Plan alerts on the location FD2090
PROCEDURE DeleteExcessAlerts IS

    FD2090ID NUMBER;
    EXCEPTIONID NUMBER;
 
    BEGIN
        FD2090ID := 0;
        EXCEPTIONID := 0;
        -- only check for consumable items
        SELECT ID INTO FD2090ID FROM SPOC17V2.LOCATION WHERE NAME='FD2090';
        SELECT ID INTO EXCEPTIONID FROM SPOC17V2.EXCEPTION_RULE WHERE 
        NAME='EXCESS_TO_PLAN';

        DELETE FROM SPOC17V2.ALERT_DATA WHERE QUEUED_ALERT IN 
        (SELECT QA.ID FROM SPOC17V2.QUEUED_ALERT QA INNER JOIN SPOC17V2.PART PA
        ON QA.PART=PA.ID WHERE LOCATION=FD2090ID AND
        EXCEPTION_RULE=EXCEPTIONID AND IS_REPARABLE='F');

        DELETE FROM SPOC17V2.QUEUED_ALERT QA WHERE ID IN
        (SELECT QA.ID FROM SPOC17V2.QUEUED_ALERT QA INNER JOIN SPOC17V2.PART PA
        ON QA.PART=PA.ID WHERE LOCATION=FD2090ID AND
        EXCEPTION_RULE=EXCEPTIONID AND IS_REPARABLE='F');

        COMMIT;        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            RAISE;
END DeleteExcessAlerts;

END SPO_PP_CUSTOMIZE_PKG; 
/

