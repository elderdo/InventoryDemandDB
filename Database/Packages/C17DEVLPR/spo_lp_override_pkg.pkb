CREATE OR REPLACE PACKAGE body C17DEVLPR.spo_lp_override_pkg AS
 /*
      $Author:   c970984  $
    $Revision:   1.1  $
        $Date:   Dec 11 2007 16:46:02  $
    $Workfile:   spo_lp_override_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\C17DEVLPR\spo_lp_override_pkg.pkb.-arc  $
/*   
/*      Rev 1.1   Dec 11 2007 16:46:02   c970984
/*   12/07
/*   
/*   
/*      Rev 1.0   27 Sep 2007 17:27:12   C970984
/*   Initial revision.
*/   
    
    procedure writeMsg(
                pTableName IN SPO_LOAD_STATUS.TABLE_NAME%TYPE,
                pError_location IN SPO_LOAD_DETAILS.DATA_LINE_NO%TYPE,
                pKey1 IN VARCHAR2 := '',
                pKey2 IN VARCHAR2 := '',
                pKey3 IN VARCHAR2 := '',
                pKey4 in varchar2 := '',
                pData IN VARCHAR2 := '',
                pComments IN VARCHAR2 := '')  IS
    BEGIN
        Spo_Utils.writeMsg (
                pSourceName => 'spo_lp_override_pkg',    
                pTableName  => pTableName,
                pError_location => pError_location,
                pKey1 => pKey1,
                pKey2 => pKey2,
                pKey3 => pKey3,
                pKey4 => pKey4,
                pData    => pData,
                pComments => pComments);
    exception when others then
        -- trying to rollback or commit from trigger
        if sqlcode = 4092 then
            raise_application_error(-20010,
                substr('spo_lp_override_pkg ' 
                    || sqlcode || ' '
                    || pError_Location || ' ' 
                    || pTableName || ' ' 
                    || pKey1 || ' ' 
                    || pKey2 || ' ' 
                    || pKey3 || ' ' 
                    || pKey4 || ' '
                    || pData, 1,2000)) ;
        else
            raise ;
        end if ;
    end writeMsg ;
    
    PROCEDURE ErrorMsg(
        pSqlfunction IN SPO_LOAD_STATUS.SOURCE%TYPE,
        pTableName IN SPO_LOAD_STATUS.TABLE_NAME%TYPE,
        pError_location SPO_LOAD_DETAILS.DATA_LINE_NO%TYPE,
        pKey1 IN SPO_LOAD_DETAILS.KEY_1%TYPE := '',
        pKey2 IN SPO_LOAD_DETAILS.KEY_2%TYPE := '',
        pKey3 IN SPO_LOAD_DETAILS.KEY_3%TYPE := '',
        pKey4 IN SPO_LOAD_DETAILS.KEY_4%TYPE := '',
        pComments IN VARCHAR2 := '') IS
     
        key5 SPO_LOAD_DETAILS.KEY_5%TYPE := pComments ;
        error_location number ;
        load_no number ;
     
    BEGIN
      ROLLBACK;
      IF key5 = '' THEN
         key5 := pSqlFunction || '/' || pTableName ;
      ELSE
       key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
      END IF ;
      
      if pError_location is null then
        error_location := -9998 ;
      else
          if spo_utils.isNumber(pError_location) then
               error_location := pError_location ;
          else
               error_location := -9999 ;
          end if ;
     end if ;
          
      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important
      begin
        load_no := spo_utils.getLoadNo(pSourceName => substr(pSqlfunction,1,20), pTableName  => SUBSTR(pTableName,1,20)) ;
      exception when others then
        load_no := -1 ;  -- this should not happen
      end ;
      
      Spo_Utils.InsertErrorMsg (
        pLoad_no => load_no,
        pData_line_no => error_location,
        pData_line    => 'spo_lp_override_pkg',
        pKey_1 => SUBSTR(pKey1,1,50),
        pKey_2 => SUBSTR(pKey2,1,50),
        pKey_3 => SUBSTR(pKey3,1,50),
        pKey_4 => SUBSTR(pKey4,1,50),
        pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
             ' ' || substr(key5,1,50),
        pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
        COMMIT;
      
    EXCEPTION WHEN OTHERS THEN
      if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
      if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
      if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
      if pKey1 is not null then dbms_output.put_line('key1=' || pKey1) ; end if ;
      if pkey2 is not null then dbms_output.put_line('key2=' || pKey2) ; end if ;
      if pKey3 is not null then dbms_output.put_line('key3=' || pKey3) ; end if ;
      if pKey4 is not null then dbms_output.put_line('key4=' || pKey4) ; end if ;
      if pComments is not null then dbms_output.put_line('pComments=' || pComments) ; end if ;
       raise_application_error(-20030,
            substr('spo_lp_override_pkg ' 
                || sqlcode || ' '
                || pError_location || ' '
                || pSqlFunction || ' ' 
                || pTableName || ' ' 
                || pKey1 || ' ' 
                || pKey2 || ' ' 
                || pKey3 || ' ' 
                || pKey4 || ' '
                || pComments,1, 2000)) ;
	END ErrorMsg;
    
    function doLpOverrideDiff(part in varchar2, 
                              location in varchar2, 
                              override_type in varchar2,
                              override_user in varchar2, 
                              quantity in number, 
                              override_reason in varchar2, 
                              begin_date in date, 
                              end_date in date, 
                              action in varchar2) return number is
                              
        batch_job_number SPO_BATCH_JOBS.BATCH_JOB_NUMBER%TYPE DEFAULT NULL;
    
    begin

        if location is not null and part is not null and override_type is not null then
            if UPPER(action) in ('INS', 'UPD', 'DEL') then
                batch_job_number := SPO_BATCH_PKG.getActiveJob(system_id=>SPO_BATCH_PKG.ASSET_MANAGEMENT_DESKTOP);
            
                IF batch_job_number IS NOT NULL THEN
                    insert into /*+ append */ SPOV22ICSV2.X_IMP_LP_OVERRIDE
                    (location, part, override_type, quantity, override_reason, override_user, begin_date, end_date, batch, action, interface_sequence)
                    values(doLpOverrideDiff.location, doLpOverrideDiff.part, doLpOverrideDiff.override_type, doLpOverrideDiff.quantity, doLpOverrideDiff.override_reason, doLpOverrideDiff.override_user, doLpOverrideDiff.begin_date, doLpOverrideDiff.end_date, batch_job_number, UPPER(action), SPOV22ICSV2.interface_sequence.nextval);
                    --commit;
                END IF;
            end if ;
           
        end if;        

        return 0 ;
    exception when others then
        errorMsg(pSqlfunction       => 'diff',pTableName  => TARGET_TABLE,
            pError_location => 220, 
            pKey1 => 'part_no=' || part,
            pKey2 => 'spo_location=' || location,
            pKey3 => 'override_type=' || override_type,
            pKey4 => 'override_user=' || override_user ) ;

        raise ;            
    end doLpOverrideDiff;
    
    procedure initialize is
    begin
        --mta_truncate_table('X_IMP_LP_OVERRIDE','reuse storage') ; --PLS-00201: identifier 'MTA_TRUNCATE_TABLE' must be declared
        --EXECUTE IMMEDIATE 'TRUNCATE TABLE SPOV22ICSV2.' || TARGET_TABLE || '  REUSE STORAGE'; 
        commit ;
    end initialize ;
    
     
    procedure version IS
    begin
        writeMsg(pTableName => 'spo_lp_override_pkg', 
            pError_location => 250, pKey1 => 'spo_lp_override_pkg', pKey2 => '$Revision:   1.1  $') ;
        dbms_output.put_line('spo_lp_override_pkg: $Revision:   1.1  $') ;
    end version ;


end spo_lp_override_pkg ;
/