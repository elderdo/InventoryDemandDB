CREATE OR REPLACE PACKAGE BODY SPOC17V2.PKG_ESCMSPO AS

  PROCEDURE TRUNCATE_TABLE (TABLE1 IN VARCHAR)
  IS
  /******************************************************************************
   NAME:       TRANCATE_TABLE 
   PURPOSE:    TRANATE TABLE GIVEN 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/10/2006  Aaron Shiley     1. Created this procedure.

   NOTES:

******************************************************************************/
  BEGIN
  
  EXECUTE IMMEDIATE('TRUNCATE TABLE ' || TABLE1 || ' REUSE STORAGE');

  EXCEPTION
    WHEN OTHERS THEN
   RAISE;  
  END TRUNCATE_TABLE;
  
  
  
  PROCEDURE fx_lp_move 
  IS
   /******************************************************************************
    NAME:       fx_lp_move 
    PURPOSE:    To keep more the forecast demands to the demand table by period.
 
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        03/10/2006  Aaron Shiley     1. Created this procedure.
 
    NOTES:
 
 ******************************************************************************/
   
     period       DATE; --current period. 
     pid          NUMBER; -- period id.
     
  BEGIN
    SELECT ID INTO pid FROM V_CURRENT_PERIOD;
  
    SELECT BEGIN_DATE INTO period FROM V_CURRENT_PERIOD;

     BEGIN 
  -- if it is the first of the month...
       IF TO_CHAR(period, 'MM/DD/YYYY') = TO_CHAR(SYSDATE, 'MM/DD/YYYY')  THEN
         BEGIN
           PKG_ESCMSPO.TRUNCATE_TABLE('LP_DEMAND_FORECAST');
         EXCEPTION
           WHEN OTHERS THEN
             RAISE;
         END;
       END IF;
 
       MERGE INTO LP_DEMAND_FORECAST LPDF
         USING(SELECT * 
                 FROM FX_LP_DEMAND_FORECAST 
                WHERE PERIOD = pid) FXLPDF
         ON(LPDF.PART = FXLPDF.PART AND
            LPDF.PERIOD = FXLPDF.PERIOD AND 
            LPDF.LOCATION = FXLPDF.LOCATION AND  
            LPDF.DEMAND_FORECAST_TYPE = FXLPDF.DEMAND_FORECAST_TYPE)
         WHEN MATCHED THEN 
           UPDATE SET LPDF.QUANTITY = FXLPDF.QUANTITY, LPDF.last_modified = SYSDATE
         WHEN NOT MATCHED THEN
           INSERT (LPDF.PART, LPDF.LOCATION, LPDF.PERIOD, LPDF.DEMAND_FORECAST_TYPE, LPDF.QUANTITY, LPDF.last_modified)
           VALUES (FXLPDF.PART, FXLPDF.LOCATION, FXLPDF.PERIOD, FXLPDF.DEMAND_FORECAST_TYPE, FXLPDF.QUANTITY, FXLPDF.last_modified);
    
       DELETE fx_lp_demand_forecast 
        WHERE period <= pid;
     EXCEPTION
       WHEN others THEN
         RAISE;
     END;
  EXCEPTION
    WHEN others THEN
      RAISE;
  END fx_lp_move;


  PROCEDURE GRANT_PERMS_TO_USER (USERid IN VARCHAR, WHAT_IF IN VARCHAR)
  IS
  /******************************************************************************
   NAME:       Aaron Shiley 
   PURPOSE:    Create role if doesn't already exist, grant standard permissions 
   to role and grant role to user 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/25/2008  Aaron Shiley     1. Created this procedure.
   1.1        02/12/2008  Aaron Shiley     2. Modified case to grant delete on queued_request and proposed_reqeust.

   NOTES:

******************************************************************************/
  CURSOR objects_cur IS
  SELECT object_name, object_type
    FROM user_objects 
   WHERE OBJECT_TYPE IN ( 'TABLE', 'VIEW', 'SEQUENCE', 'PROCEDURE', 'PACKAGE','FUNCTION')
   ORDER BY OBJECT_TYPE;  
   
  RetVal    NUMBER;
  sCursor   INT;
  sqlstr    VARCHAR2(300);
  role_name VARCHAR2(50);
  USER_NAME VARCHAR2(50);

  BEGIN
  
    USER_NAME := UPPER(USERid);
    role_name := USER_NAME || '_ROLE';
    
    --IS USER_NAME A VALID USER? 
    BEGIN
      SELECT USERNAME INTO USER_NAME FROM all_users WHERE username = USER_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error (-20001, 'User name does not exist: '||USER_NAME);
      WHEN OTHERS THEN 
        RAISE;
    END;
    
    
    --IS THIS A CORE INSTNACE (ie, UKTLCSV2, vpvstl) OR A SUPLEMENTARY/WHAT_IF INSTANCE?
    IF (WHAT_IF<>'T') THEN
      --HAS THE ROLE BEEN CREATED?  IF NOT THEN CREATE IT! 
      BEGIN
        select Granted_role INTO role_name from user_ROLE_PRIVS where Granted_role = role_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXECUTE IMMEDIATE('CREATE ROLE '|| USER_NAME ||'_ROLE'); 
      END;
    END IF;  

    --CREATE LIST OF GRANTS, AND GRANT 
    FOR object_rec IN objects_cur LOOP
      BEGIN    
        CASE 
          WHEN (object_rec.object_type = 'TABLE' AND object_rec.object_name like 'X_%') OR 
                object_rec.object_name IN ('PROPOSED_REQUEST','QUEUED_REQUEST', 'CONFIRMED_REQUEST', 'CONFIRMED_REQUEST_LINE')
            THEN sqlstr := 'GRANT SELECT, INSERT, UPDATE, DELETE ON '|| object_rec.object_name || ' TO '||role_name;
          WHEN object_rec.object_type = 'TABLE' 
            THEN sqlstr := 'GRANT SELECT ON '|| object_rec.object_name || ' TO '||role_name;
          WHEN object_rec.object_type = 'VIEW' 
            THEN sqlstr := 'GRANT SELECT ON '|| object_rec.object_name || ' TO '||role_name;
          WHEN object_rec.object_type = 'SEQUENCE' 
            THEN sqlstr := 'GRANT SELECT ON '|| object_rec.object_name || ' TO '||role_name;
          WHEN object_rec.object_type = 'PROCEDURE' 
            THEN sqlstr := 'GRANT EXECUTE ON '|| object_rec.object_name || ' TO '||role_name;
          WHEN object_rec.object_type = 'PACKAGE' AND object_rec.object_name <> 'PKG_ESCMSPO'
            THEN sqlstr := 'GRANT EXECUTE ON '|| object_rec.object_name || ' TO '||role_name;
          WHEN object_rec.object_type = 'FUNCTION' 
            THEN sqlstr := 'GRANT EXECUTE ON '|| object_rec.object_name || ' TO '||role_name;
          ELSE
            IF object_rec.object_name <> 'PKG_ESCMSPO' THEN
              raise_application_error (-20003, 'object_type not in case: '||object_rec.object_type);
            END IF;
        END CASE;   
        dbms_output.put_line(object_rec.object_type || ' '||object_rec.object_name||'~'||sqlstr);
           
        EXECUTE IMMEDIATE (sqlstr);
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE <> -911 then
            raise_application_error (-20001, 'SQLerrm='||sqlerrm||'~ ROLE NAME='||role_name ||'~ obejct name='||object_rec.object_name||'~ obejct type='||object_rec.object_type||'~ sql string='||sqlstr);
          ELSE
            dbms_output.put_line('Something should not be here... '||sqlstr);
          END IF;
      END;
      
    END LOOP;
    
    IF (WHAT_IF<>'T') THEN
      EXECUTE IMMEDIATE ('GRANT '||ROLE_NAME||' TO '||USER_NAME);
    END IF;
    
  END GRANT_PERMS_TO_USER;
  
  
  
  
  PROCEDURE GRANT_PERMS_TO_USER (USERid IN VARCHAR)
  /******************************************************************************
   NAME:       Aaron Shiley 
   PURPOSE:    Create role if doesn't already exist, grant standard permissions 
   to role and grant role to user 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/28/2008  Aaron Shiley     1. Created this procedure.

   NOTES:

  ******************************************************************************/
    IS
    BEGIN 
      GRANT_PERMS_TO_USER (USERid,'F');
    END GRANT_PERMS_TO_USER;

END PKG_ESCMSPO;
/
