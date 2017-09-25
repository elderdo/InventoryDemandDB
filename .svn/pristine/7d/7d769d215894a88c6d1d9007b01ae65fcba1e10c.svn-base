CREATE OR REPLACE PACKAGE BODY C17PGM.SPO_X_IMP_MOD_PKG AS
/******************************************************************************
   NAME:       SPO_X_IMP_MOD_PKG
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/8/2008   Don Wang         1. Created this package body.
******************************************************************************/

  PROCEDURE ExpandDemandForecast(BatchNum IN NUMBER, currentPeriod IN DATE,
                                 duplicateCount IN NUMBER) IS
    previousLoc C17PGM.LP_DEMAND_FORECAST.LOCATION%TYPE;
    previousPart C17PGM.LP_DEMAND_FORECAST.PART%TYPE;
    previousDemandForecast C17PGM.LP_DEMAND_FORECAST.DEMAND_FORECAST_TYPE%TYPE;
    tempPeriod DATE;
    
    CURSOR curBatch IS
        SELECT * FROM C17PGM.LP_DEMAND_FORECAST
        WHERE BATCH=BatchNum ORDER BY LOCATION, PART, PERIOD;

    CURSOR curPERIODS IS
        SELECT begin_date
          FROM SPOC17V2.period
         WHERE BEGIN_DATE >= currentPeriod
      ORDER BY begin_Date ASC;

    -- new interface sequence numbers are not generated to save time and
    -- because new sequence numbers don't make much sense here

    BEGIN
    FOR rec in curBatch LOOP
        -- if part/loc not initialized, or that current part/loc doesn't match the 
        -- previous one then just insert the max number of future rows
        IF previousLoc IS NULL OR previousPart IS NULL OR previousDemandForecast IS NULL OR
        previousLoc != rec.LOCATION OR previousPart != rec.PART OR
        previousDemandForecast != rec.DEMAND_FORECAST_TYPE
        THEN
            OPEN curPERIODS;
            FOR cnt in 1..duplicateCount LOOP
                
                FETCH curPERIODS INTO tempPeriod;
                EXIT WHEN curPERIODS%NOTFOUND; 
                
                INSERT INTO SPOC17V2.X_IMP_FX_LP_DEMAND_FORECAST(LOCATION,
                PART, DEMAND_FORECAST_TYPE, PERIOD, QUANTITY, BATCH, ACTION,
                EXCEPTION, INTERFACE_SEQUENCE, TIMESTAMP) VALUES(rec.LOCATION,
                rec.PART, rec.DEMAND_FORECAST_TYPE, tempPeriod,
                rec.QUANTITY, rec.BATCH, rec.ACTION, rec.EXCEPTION,
                rec.INTERFACE_SEQUENCE, SYSDATE);   
            END LOOP;
            CLOSE curPERIODS;
        ELSE
            -- if same part/loc, update any period equal to later with this
            -- record's new quantity
            UPDATE SPOC17V2.X_IMP_FX_LP_DEMAND_FORECAST 
            SET QUANTITY=rec.QUANTITY, ACTION=rec.ACTION, EXCEPTION=rec.EXCEPTION           
            WHERE PERIOD >= rec.PERIOD AND LOCATION=rec.LOCATION AND
            PART=rec.PART;
        END IF;
            
        previousLoc := rec.LOCATION;
        previousPart := rec.PART;
        previousDemandForecast := rec.DEMAND_FORECAST_TYPE;
    END LOOP;
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    
    COMMIT;
END ExpandDemandForecast;

END SPO_X_IMP_MOD_PKG; 
/

