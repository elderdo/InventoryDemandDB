DROP PACKAGE BODY AMD_OWNER.AMD_SPARE_NETWORKS_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Spare_Networks_Pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.7  $
        $Date:   Aug 23 2015
    $Workfile:   amd_spare_networks_pkg.pkb  $
    
/*      Rev 1.7   Aug 23 2015 fixed GROUP BY clause - used sran
/*      Rev 1.6   Jun 12 2015 use ramp.sran and item.loc_id

/*      Rev 1.5   fEB 23 2015 use amd_defaults.getStartLocId whereever substr(sc,8 was used
/*      Rev 1.4   Jun 09 2006 12:21:34   zf297a
/*   implemented version
/*   
/*      Rev 1.3   Mar 20 2006 11:38:58   c402417
/*   Removed the SUM going to AMD_SPARE_NETWORKS.
/*   
/*      Rev 1.2   Dec 01 2005 10:08:32   zf297a
/*   added errorMsg and better exception handling.
/*   
/*      Rev 1.1   Nov 30 2005 09:28:58   zf297a
/*   Comments:  Changed the default values 'Virtual UAB' to 'VIRTUAL UAB', and 'Virtual COD' to 'VIRTUAL COD'. 
*/

    procedure writeMsg(
                pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
                pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
                pKey1 IN VARCHAR2 := '',
                pKey2 IN VARCHAR2 := '',
                pKey3 IN VARCHAR2 := '',
                pKey4 in varchar2 := '',
                pData IN VARCHAR2 := '',
                pComments IN VARCHAR2 := '')  IS
    BEGIN
        Amd_Utils.writeMsg (
                pSourceName => 'amd_spare_networks_pkg',    
                pTableName  => pTableName,
                pError_location => pError_location,
                pKey1 => pKey1,
                pKey2 => pKey2,
                pKey3 => pKey3,
                pKey4 => pKey4,
                pData    => pData,
                pComments => pComments);
    end writeMsg ;
    
 PROCEDURE ErrorMsg(
     pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
     pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
     pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
     pKey_1 IN AMD_LOAD_DETAILS.KEY_1%TYPE,
      pKey_2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
     pKey_3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
     pKey_4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
     pKey_5 IN AMD_LOAD_DETAILS.KEY_5%TYPE := '',
     pKeywordValuePairs IN VARCHAR2 := '') IS
  result NUMBER ;
 BEGIN
  Amd_Utils.InsertErrorMsg (
    pLoad_no => Amd_Utils.GetLoadNo(
      pSourceName => SUBSTR(pSqlfunction,1,20),
      pTableName  => SUBSTR(pTableName,1,20)),
    pData_line_no => pError_location,
    pData_line    => 'amd_spare_networkds_pkg',
    pKey_1 => SUBSTR(pKey_1,1,50),
    pKey_2 => SUBSTR(pKey_2,1,50),
    pKey_3 => SUBSTR(pKey_3,1,50),
    pKey_4 => SUBSTR(pKey_4,1,50),
    pKey_5 => SUBSTR(TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
         ' ' || pkey_5,1,50),
    pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
  COMMIT;
 EXCEPTION WHEN OTHERS THEN
     COMMIT ;
 END ErrorMsg;

  PROCEDURE auto_load_spare_networks IS

  --    This program will automatically get new sites from the RAMP and ITEM
  --      table within gold and load them into the AMD_SPARE_NETWORKS table.
  --
  --    Condition for RAMP table data to be selected and then inserted into 
  --      AMD_SPARE_NETORKS:
  --    position 1-3 of SC (field in RAMP) = 'C17' AND
  --      position 8-9 of SC = 'FB' AND
  --    position 14 of SC = 'G' AND
  --      sum of (serviceable_balance + difm_balance + hpmsk_balance + 
  --             spram_balance + wrm_balance > 0)
  --
  --    Condition for ITEM able data to be selected and then inserted into 
  --      AMD_SPARE_NETORKS:
  --      position 1-3 of SC = 'C17' AND
  --      position 8-10 of SC = 'CTL' or 'COD' AND
  --      position 8-13 of SC != 'CODLGB' AND
  --      position 14 of SC = 'G'
  
  lv_gold_table            VARCHAR2(15);
  lv_action            VARCHAR2(1) := Amd_Defaults.INSERT_ACTION;
    
  BEGIN
  lv_gold_table := 'RAMP';
  -- From RAMP gold table
    <<ramp_gold_table>>
      BEGIN 
        INSERT INTO AMD_SPARE_NETWORKS
          (loc_id,location_name,loc_type,action_code, spo_location, last_update_dt)
        SELECT DISTINCT(sran),sran,'UAB',lv_action,'VIRTUAL UAB', SYSDATE
          FROM RAMP a
         WHERE SUBSTR(sc,1,3) = 'C17'
           AND SUBSTR(sran,1,2) = 'FB'
           AND SUBSTR(sc,14,1) = 'G'
           AND NOT EXISTS (SELECT 'x'
                             FROM AMD_SPARE_NETWORKS b
                            WHERE b.loc_id = a.sran)
          GROUP BY sran ; 
        --HAVING SUM(NVL(serviceable_balance,0)+NVL(difm_balance,0)+NVL(hpmsk_balance,0)+
          --     NVL(spram_balance,0)+NVL(wrm_balance,0)) > 0;  /* Removed per spec provided by Laurie C. - 03/02/06 ThuyP. */
    EXCEPTION
        WHEN standard.NO_DATA_FOUND THEN
             NULL ; -- ignore because all locations are already in AMD_SPARE_NETWORKS!!!
        WHEN OTHERS THEN
            errormsg( psqlfunction => 'insert', ptablename => 'amd_spare_networks', perror_location => 10,
                pkey_1 =>'VIRTUAL UAB') ;
            RAISE ;             
    END ramp_gold_table ;

  lv_gold_table := 'ITEM';
  -- From ITEM gold table
  <<item_gold_table>>
  BEGIN 
    INSERT INTO AMD_SPARE_NETWORKS 
      (loc_id,location_name, loc_type,action_code,spo_location, last_update_dt)
    SELECT DISTINCT(loc_id),loc_id,
           DECODE(SUBSTR(loc_id,1,3),'CTL','CWH',SUBSTR(loc_id,1,3)),lv_action,
           DECODE(SUBSTR(loc_id,1,3),'CTL','FD2090','VIRTUAL COD'), SYSDATE
      FROM ITEM a
     WHERE SUBSTR(sc,1,3) = 'C17'
       AND (SUBSTR(loc_id,1,3) = 'CTL' OR SUBSTR(loc_id,1,3) = 'COD')
       AND loc_id != 'CODLGB'
       AND SUBSTR(sc,14,1) = 'G'
       AND NOT EXISTS (SELECT 'x'
                         FROM AMD_SPARE_NETWORKS b
                        WHERE b.loc_id = a.loc_id);
                                               
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL; -- just ignore because all locations are already in AMD_SPARE_NETWORKS!!!
    WHEN OTHERS THEN
            errormsg( psqlfunction => 'insert', ptablename => 'amd_spare_networks', perror_location => 20,
                pkey_1 => 'VIRTUAL COD') ;
            RAISE ;             
   END item_gold_table ;
  END auto_load_spare_networks;

    procedure version is
    begin
         writeMsg(pTableName => 'amd_spare_networks_pkg', 
                 pError_location => 30, pKey1 => 'amd_spare_networks_pkg', pKey2 => '$Revision:   1.7  $') ;
    end version ;

END Amd_Spare_Networks_Pkg;
/


DROP PUBLIC SYNONYM AMD_SPARE_NETWORKS_PKG;

CREATE PUBLIC SYNONYM AMD_SPARE_NETWORKS_PKG FOR AMD_OWNER.AMD_SPARE_NETWORKS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_NETWORKS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_NETWORKS_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_NETWORKS_PKG TO BSRM_LOADER;
