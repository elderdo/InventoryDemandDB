/* Formatted on 5/16/2017 3:28:20 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_FACTORS_PKG
AS
   /*
        $Author:   zf297a  $
      $Revision:   1.18
          $Date:   16 May 2017
      $Workfile:   AMD_PART_FACTORS_PKG.pkb  $

            Rev 1.18 16 May 2017 DSE to maintain compatibility with the old Java code that calls
                                 deleteRow with the longer parameter list overload the deleteRow
                                 function.                                                 
            
            Rev 1.17 25 Jan 2017 DSE reformatted code

            Rev 1.16 added exception handlers for select's that should return one item only
            and fixed getRepairIndicator to use only the current nsn vs the temporary nsn ( nsn_type = 'C' )

            Rev 1.15 fixed deleteRow - only needed primary key for amd_part_factors and only needed to
            update action_code and last_update_dt

            Rev 1.14 removed truncation of tmp_a2a table
  /*
  /*      Rev 1.13   02 Jul 2009 13:10:40   zf297a
  /*   Moved mtd_rec to spec to make it public
  /*
  /*      Rev 1.12   24 Feb 2009 13:46:26   zf297a
  /*   Removed a2a code
  /*
  /*      Rev 1.11   13 Jan 2009 15:30:36   zf297a
  /*   Implement setDebug, getDebug, and getVersion.
  /*   Use the maint_task_distrib_exception to handle conditions where the nrts + rts + condemnation_rate is not equal to 1.
  /*   Add debugMsg, a procedure for errorMsg, and writeMsg.
  /*   Log cnts to amd_load_details when loading tmp_amd_part_factors.
  /*
  /*      Rev 1.10   07 Nov 2007 16:35:30   zf297a
  /*   Use bulk collect for all cursors.
  /*
  /*      Rev 1.9   16 Oct 2007 17:16:00   zf297a
  /*   Fixed literal being written out by the version procedure
  /*
  /*      Rev 1.8   12 Sep 2007 15:37:10   zf297a
  /*   Removed commits from for loops.
  /*
  /*      Rev 1.7   Nov 28 2006 14:54:58   zf297a
  /*   fixed insertTmpA2A_PF - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_part_factors.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_part_factors.
  /*
  /*      Rev 1.6   Jun 09 2006 12:03:06   zf297a
  /*   implemented interface version
  /*
  /*      Rev 1.5   Mar 03 2006 12:38:32   zf297a
  /*   removed amd_location_part_leadtime_pkg.getBatchRunStart and replaced it with amd_batch_pkg.getLastStartTime, which will always return the start time of the last job regardless of whether it has completed or not.  This allows the procedures that select a2a data to be run even if the batch job has completed.  Only the data that has changed since the batch job started will be sent.  This should only be a small amount of data.
  /*
  /*      Rev 1.4   Jan 03 2006 13:03:18   zf297a
  /*   Added date range to procedure loadA2AByDate
  /*
  /*      Rev 1.3   Jan 03 2006 08:07:42   zf297a
  /*   Added procedure loadA2AByDate
  /*
  /*      Rev 1.2   Dec 16 2005 08:49:30   zf297a
  /*   Added truncate of tmp_a2a_part_factors table when tmp_amd_part_factors is loaded.
  /*
  /*      Rev 1.1   Dec 06 2005 10:30:26   zf297a
  /*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
  /*
  /*      Rev 1.0   Oct 31 2005 08:04:54   zf297a
  /*   Initial revision.
  */



   PKGNAME                   CONSTANT VARCHAR2 (30) := 'AMD_PART_FACTORS_PKG';
   FORWARD_SUPPLY_LOCATION   CONSTANT VARCHAR2 (3) := 'FSL';
   MAIN_OPERATING_BASE       CONSTANT VARCHAR2 (3) := 'MOB';
   debug                              BOOLEAN := FALSE;


   TYPE partFactorsRec IS RECORD
   (
      part_no    amd_spare_parts.spo_prime_part_no%TYPE,
      nsn        amd_national_stock_items.nsn%TYPE,
      loc_sid    amd_spare_networks.loc_sid%TYPE,
      loc_type   amd_spare_networks.loc_type%TYPE,
      loc_id     amd_spare_networks.loc_id%TYPE,
      rts        NUMBER,
      nrts       NUMBER,
      condemn    NUMBER
   );

   TYPE partFactorsTab IS TABLE OF partFactorsRec;

   partFactorsRecs                    partFactorsTab;


   FUNCTION ErrorMsg (
      pSourceName       IN amd_load_status.SOURCE%TYPE,
      pTableName        IN amd_load_status.TABLE_NAME%TYPE,
      pError_location   IN amd_load_details.DATA_LINE_NO%TYPE,
      pReturn_code      IN NUMBER,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
      RETURN NUMBER
   IS
   BEGIN
      ROLLBACK; -- rollback may not be complete if running with mDebug set to true
      amd_utils.InsertErrorMsg (
         pLoad_no        => amd_utils.GetLoadNo (pSourceName   => pSourceName,
                                                 pTableName    => pTableName),
         pData_line_no   => pError_location,
         pData_line      => pData,
         pKey_1          => SUBSTR (pKey1, 1, 50),
         pKey_2          => SUBSTR (pKey2, 1, 50),
         pKey_3          => pKey3,
         pKey_4          => TO_CHAR (pReturn_code),
         pKey_5          => TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS'),
         pComments       =>    'sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ') '
                            || pComments);
      COMMIT;
      RETURN pReturn_code;
   END;


   PROCEDURE ErrorMsg (
      pSqlfunction         IN AMD_LOAD_STATUS.SOURCE%TYPE := 'errorMsg',
      pTableName           IN AMD_LOAD_STATUS.TABLE_NAME%TYPE := 'noname',
      pError_location         AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE := -100,
      pKey_1               IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
      pKey_2               IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
      pKey_3               IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
      pKey_4               IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
      pKeywordValuePairs   IN VARCHAR2 := '')
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      key5          AMD_LOAD_DETAILS.KEY_5%TYPE
                       := SUBSTR (pKeywordValuePairs, 1, 50);
      saveSqlCode   NUMBER := SQLCODE;
   BEGIN
      IF key5 = '' OR key5 IS NULL
      THEN
         key5 := pSqlFunction || '/' || pTableName;
      ELSE
         IF key5 IS NOT NULL
         THEN
            IF   LENGTH (key5)
               + LENGTH ('' || pSqlFunction || '/' || pTablename) < 50
            THEN
               key5 := key5 || ' ' || pSqlFunction || '/' || pTableName;
            END IF;
         END IF;
      END IF;

      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important

      DBMS_OUTPUT.put_line ('insertError@' || pError_location);

      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (
                              pSourceName   => SUBSTR (pSqlfunction, 1, 20),
                              pTableName    => SUBSTR (pTableName, 1, 20)),
         pData_line_no   => pError_location,
         pData_line      => 'amd_part_factors_pkg.',
         pKey_1          => SUBSTR (pKey_1, 1, 50),
         pKey_2          => SUBSTR (pKey_2, 1, 50),
         pKey_3          => SUBSTR (pKey_3, 1, 50),
         pKey_4          => SUBSTR (pKey_4, 1, 50),
         pKey_5          => SUBSTR (key5, 1, 50),
         pComments       => SUBSTR (
                                 'sqlcode('
                              || saveSQLCODE
                              || ') sqlerrm('
                              || SQLERRM
                              || ')',
                              1,
                              2000));

      IF SQLCODE <> -4092
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.enable (10000);
         DBMS_OUTPUT.put_line ('sql error=' || SQLCODE || ' ' || SQLERRM);

         IF pSqlFunction IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pSqlFunction=' || pSqlfunction);
         END IF;

         IF pTableName IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pTableName=' || pTableName);
         END IF;

         IF pError_location IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pError_location=' || pError_location);
         END IF;

         IF pKey_1 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key1=' || pKey_1);
         END IF;

         IF pkey_2 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key2=' || pKey_2);
         END IF;

         IF pKey_3 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key3=' || pKey_3);
         END IF;

         IF pKey_4 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key4=' || pKey_4);
         END IF;

         IF pKeywordValuePairs IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line (
               'pKeywordValuePairs=' || pKeywordValuePairs);
         END IF;

         IF SQLCODE <> -4092
         THEN
            raise_application_error (
               -20030,
               SUBSTR (
                     'amd_part_factors_pkg '
                  || SQLCODE
                  || ' '
                  || pError_location
                  || ' '
                  || pSqlFunction
                  || ' '
                  || pTableName
                  || ' '
                  || pKey_1
                  || ' '
                  || pKey_2
                  || ' '
                  || pKey_3
                  || ' '
                  || pKey_4
                  || ' '
                  || pKeywordValuePairs,
                  1,
                  2000));
         END IF;
   END ErrorMsg;

   PROCEDURE debugMsg (msg               IN AMD_LOAD_DETAILS.DATA_LINE%TYPE,
                       pError_Location   IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF debug
      THEN
         Amd_Utils.debugMsg (pMsg        => msg,
                             pPackage    => 'amd_part_factors_pkg',
                             pLocation   => pError_location);
         COMMIT;                                -- make sure the trace is kept
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -14551 OR SQLCODE = -14552
         THEN
            NULL;    -- cannot do a commit inside a query, so ignore the error
         ELSE
            RAISE;
         END IF;
   END debugMsg;

   PROCEDURE writeMsg (
      pTableName        IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
      pError_location   IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pKey4             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
   IS
   BEGIN
      Amd_Utils.writeMsg (pSourceName       => 'amd_part_factors_pkg',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   EXCEPTION
      WHEN OTHERS
      THEN
         --  ignoretrying to rollback or commit from trigger
         IF SQLCODE <> -4092
         THEN
            raise_application_error (
               -20010,
               SUBSTR (
                     'amd_part_factors_pkg '
                  || SQLCODE
                  || ' '
                  || pError_Location
                  || ' '
                  || pTableName
                  || ' '
                  || pKey1
                  || ' '
                  || pKey2
                  || ' '
                  || pKey3
                  || ' '
                  || pKey4
                  || ' '
                  || pData,
                  1,
                  2000));
         END IF;
   END writeMsg;


   FUNCTION defaultMtdToDataSys (pLocId amd_spare_networks.LOC_ID%TYPE)
      RETURN mtd_rec
   IS
      retRec   mtd_rec;
   BEGIN
      retRec.rts := 0;
      retRec.nrts := 0;
      retRec.condemn := 0;

      IF (pLocId = amd_defaults.AMD_WAREHOUSE_LOCID)
      THEN
         retRec.condemn := DEFAULT_WHSE_COND;
         retRec.rts := 1 - retRec.condemn;
      ELSE
         retRec.nrts := 1;
      END IF;

      IF retRec.rts + retRec.nrts + retRec.condemn <> 1
      THEN
         debugMsg (
            msg               =>    retRec.nrts
                                 || ','
                                 || retRec.rts
                                 || ', '
                                 || retRec.condemn
                                 || ' ='
                                 || (retRec.rts + retRec.nrts + retRec.condemn),
            pError_location   => 10);
         RAISE maint_task_distrib_exception;
      END IF;

      RETURN retRec;
   EXCEPTION
      WHEN maint_task_distrib_exception
      THEN
         ErrorMsg (
            pSqlfunction      => 'defaultMtd',
            pTableName        => 'tmp_amd_part_factors',
            pError_location   => 20,
            pKey_1            => pLocId,
            pKey_2            => retRec.nrts,
            pKey_3            => retRec.rts,
            pKey_4            =>    retRec.condemn
                                 || ' ='
                                 || (retRec.rts + retRec.nrts + retRec.condemn));
         RAISE;
   END defaultMtdToDataSys;

   FUNCTION GetCriticalityFromSubs (
      pSpoPrimePartNo    amd_spare_parts.spo_prime_part_no%TYPE)
      RETURN amd_national_stock_items.CRITICALITY%TYPE
   IS
      TYPE criticalityCleanedRec IS RECORD
      (
         criticality_cleaned   amd_national_stock_items.CRITICALITY_CLEANED%TYPE,
         criticality           amd_national_stock_items.CRITICALITY%TYPE
      );

      TYPE criticalityCleanedTab IS TABLE OF criticalityCleanedRec;

      criticalityCleanedRecs   criticalityCleanedTab;

      CURSOR criticalityCur
      IS
         SELECT criticality_cleaned, criticality
           FROM amd_spare_parts parts, amd_national_stock_items items
          WHERE     is_spo_part = 'Y'
                AND parts.spo_prime_part_no = pSpoPrimePartNo
                AND parts.part_no != parts.spo_prime_part_no
                AND items.prime_part_no = parts.spo_prime_part_no
                AND items.action_code != Amd_Defaults.DELETE_ACTION;

      retCrit                  amd_national_stock_items.CRITICALITY%TYPE
                                  := NULL;
      SubHasCritOfOne          BOOLEAN := FALSE;
   BEGIN
      OPEN criticalityCur;

      FETCH criticalityCur BULK COLLECT INTO criticalityCleanedRecs;

      CLOSE criticalityCur;

      IF criticalityCleanedRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN criticalityCleanedRecs.FIRST ..
                     criticalityCleanedRecs.LAST
         LOOP
            IF (amd_preferred_pkg.GetPreferredValue (
                   criticalityCleanedRecs (indx).criticality_cleaned,
                   criticalityCleanedRecs (indx).criticality) = 1)
            THEN
               SubHasCritOfOne := TRUE;
            END IF;
         END LOOP;
      END IF;

      IF (SubHasCritOfOne)
      THEN
         RETURN 1;
      ELSE
         RETURN NULL;
      END IF;
   END;

   FUNCTION CorrectCriticality (
      pCrit    amd_national_stock_items.CRITICALITY%TYPE)
      RETURN amd_national_stock_items.CRITICALITY%TYPE
   IS
   BEGIN
      IF (pCrit IS NULL)
      THEN
         RETURN NULL;
      ELSIF (pCrit <= 0)
      THEN
         RETURN 0;
      ELSIF (pCrit > 0 AND pCrit <= .1)
      THEN
         RETURN .1;
      ELSIF (pCrit > .1 AND pCrit <= .5)
      THEN
         RETURN .5;
      ELSIF (pCrit > .5)
      THEN
         RETURN 1;
      END IF;
   END;

   FUNCTION DetermineCriticality (
      pCrit      amd_national_stock_items.CRITICALITY%TYPE,
      pPartNo    amd_spare_parts.part_no%TYPE)
      RETURN amd_national_stock_items.CRITICALITY%TYPE
   IS
      retCrit   amd_national_stock_items.CRITICALITY%TYPE := NULL;
   BEGIN
      IF (pCrit IS NULL)
      THEN
         retCrit := GetCriticalityFromSubs (pPartNo);

         IF (retCrit IS NOT NULL)
         THEN
            RETURN correctCriticality (retCrit);
         ELSIF (amd_location_part_leadtime_pkg.IsPartRepairable (pPartNo) =
                   'Y')
         THEN
            RETURN CRITICALITY_REPAIRABLE_DEFAULT;
         ELSE
            RETURN CRITICALITY_CONSUMABLE_DEFAULT;
         END IF;
      ELSE
         RETURN correctCriticality (pCrit);
      END IF;
   END;



   FUNCTION DetermineCriticality (
      pCrit      amd_national_stock_items.CRITICALITY%TYPE,
      pNsiSid    amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.CRITICALITY%TYPE
   IS
      primePartNo   amd_national_stock_items.prime_part_no%TYPE := NULL;
   BEGIN
      IF (pCrit IS NULL)
      THEN
         SELECT prime_part_no
           INTO primePartNo
           FROM amd_national_stock_items
          WHERE     action_code != Amd_Defaults.DELETE_ACTION
                AND nsi_sid = pNsiSid;

         RETURN DetermineCriticality (pCrit, primePartNo);
      ELSE
         RETURN pCrit;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   /* current spec says to send a default nrts, rts, cond to vub, vcd, basc,
      others - mob, fsl, ctlatl, uk will use #'s from best spares.
      Below will have to be maintained */
   FUNCTION isAutoDefaulted (pLocRow amd_spare_networks%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF (    pLocRow.loc_id NOT IN
                 (Amd_Defaults.AMD_WAREHOUSE_LOCID,
                  Amd_Defaults.AMD_UK_LOC_ID)
          AND pLocRow.loc_type NOT IN
                 (FORWARD_SUPPLY_LOCATION, MAIN_OPERATING_BASE))
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN TRUE;
   END isAutoDefaulted;

   FUNCTION autoDefaultMtd
      RETURN mtd_rec
   IS
      retMtdRec   mtd_rec;
   BEGIN
      retMtdRec.nrts := 1;
      retMtdRec.rts := 0;
      retMtdRec.condemn := 0;
      RETURN retMtdRec;
   END autoDefaultMtd;

   FUNCTION ConvertMtdToDataSys (pLocId              amd_spare_networks.LOC_ID%TYPE,
                                 pCapabilityLevel    VARCHAR2,
                                 pRepairInd          VARCHAR2,
                                 pNrts               NUMBER,
                                 pRts                NUMBER,
                                 pCondemn            NUMBER)
      RETURN mtd_rec
   IS
      retRec   mtd_rec;
      tot      NUMBER;
   BEGIN
      retRec.rts := ROUND (NVL (pRts, 0), DP);
      retRec.nrts := ROUND (NVL (pNrts, 0), DP);
      retRec.condemn := 1 - (retRec.rts + retRec.nrts);

      tot := retRec.rts + retRec.nrts + retRec.condemn;

      IF (tot = 0 OR retRec.rts < 0 OR retRec.nrts < 0 OR retRec.condemn < 0)
      THEN
         RETURN defaultMtdToDataSys (pLocId);
      END IF;

      /* make the sum equal 1 */
      IF (tot != 1)
      THEN
         retRec.rts := ROUND (retRec.rts / tot, DP);
         retRec.nrts := ROUND (retRec.nrts / tot, DP);
         retRec.condemn := 1 - (retRec.rts + retRec.nrts);
      END IF;

      IF (pLocId = amd_defaults.AMD_WAREHOUSE_LOCID)
      THEN
         IF (retRec.rts = 1)
         THEN
            retRec.condemn := 0;
         ELSE
            retRec.condemn := ROUND (retRec.condemn / (1 - retRec.rts), DP);
         END IF;

         retRec.nrts := 0;
      /* not warehouse */
      ELSIF (    NVL (pCapabilityLevel, 'notO') = '0'
             AND NVL (pRepairInd, 'Y') = 'Y')
      THEN
         retRec.nrts := 1 - retRec.rts;
         retRec.condemn := 0;
      ELSE
         retRec.nrts := 1;
         retRec.condemn := 0;
         retRec.rts := 0;
      END IF;

      IF retRec.nrts + retRec.condemn + retRec.rts <> 1
      THEN
         debugMsg (
            msg               =>    retRec.nrts
                                 || ', '
                                 || retRec.rts
                                 || ', '
                                 || retRec.condemn
                                 || ' ='
                                 || (retRec.rts + retRec.nrts + retRec.condemn),
            pError_location   => 30);

         debugMsg (
            msg               =>    retRec.nrts / tot
                                 || ', '
                                 || retRec.rts / tot
                                 || ', '
                                 || retRec.condemn / tot,
            pError_location   => 40);

         retRec.rts := ROUND (retRec.rts / tot, DP);
         retRec.nrts := ROUND (retRec.nrts / tot, DP);
         retRec.condemn := 1 - (retRec.rts + retRec.nrts);

         debugMsg (
            msg               =>    retRec.nrts
                                 || ', '
                                 || retRec.rts
                                 || ', '
                                 || retRec.condemn
                                 || ' ='
                                 || (retRec.rts + retRec.nrts + retRec.condemn),
            pError_location   => 50);

         IF retRec.nrts + retRec.condemn + retRec.rts <> 1
         THEN
            RAISE maint_task_distrib_exception;
         END IF;
      END IF;

      RETURN retRec;
   EXCEPTION
      WHEN maint_task_distrib_exception
      THEN
         ErrorMsg (
            pSqlfunction         => 'convertMtd',
            pTableName           => 'tmp_amd_part_factors',
            pError_location      => 60,
            pKey_1               => pLocId,
            pKey_2               => retRec.nrts,
            pKey_3               => retRec.rts,
            pKey_4               =>    retRec.condemn
                                    || ' ='
                                    || (retRec.rts + retRec.nrts + retRec.condemn),
            pKeywordValuePairs   =>    pNrts
                                    || ', '
                                    || pRts
                                    || ', '
                                    || pCondemn
                                    || ', '
                                    || pCapabilityLevel
                                    || ', '
                                    || pRepairInd);
         RAISE;
   END ConvertMtdToDataSys;



   PROCEDURE UpdateAmdPartFactors (
      pPartNo          amd_part_factors.part_no%TYPE,
      pLocSid          amd_part_factors.loc_sid%TYPE,
      pPassUpRate      amd_part_factors.pass_up_rate%TYPE,
      pRts             amd_part_factors.rts%TYPE,
      pCmdmdRate       amd_part_factors.cmdmd_rate%TYPE,
      pActionCode      amd_part_factors.action_code%TYPE,
      pLastUpdateDt    amd_part_factors.last_update_dt%TYPE)
   IS
   BEGIN
      UPDATE amd_part_factors
         SET pass_up_rate = pPassUpRate,
             rts = pRts,
             cmdmd_rate = pCmdmdRate,
             action_code = pActionCode,
             last_update_dt = pLastUpdateDt
       WHERE part_no = pPartNo AND loc_sid = pLocSid;
   END UpdateAmdPartFactors;

   PROCEDURE UpdateTmpAmdPartFactors (
      pPartNo          amd_part_factors.part_no%TYPE,
      pLocSid          amd_part_factors.loc_sid%TYPE,
      pPassUpRate      amd_part_factors.pass_up_rate%TYPE,
      pRts             amd_part_factors.rts%TYPE,
      pCmdmdRate       amd_part_factors.cmdmd_rate%TYPE,
      pActionCode      amd_part_factors.action_code%TYPE,
      pLastUpdateDt    amd_part_factors.last_update_dt%TYPE)
   IS
   BEGIN
      UPDATE tmp_amd_part_factors
         SET pass_up_rate = pPassUpRate,
             rts = pRts,
             cmdmd_rate = pCmdmdRate,
             action_code = pActionCode,
             last_update_dt = pLastUpdateDt
       WHERE part_no = pPartNo AND loc_sid = pLocSid;
   END UpdateTmpAmdPartFactors;

   PROCEDURE InsertAmdPartFactors (
      pPartNo          amd_part_factors.part_no%TYPE,
      pLocSid          amd_spare_networks.loc_sid%TYPE,
      pPassUpRate      amd_part_factors.pass_up_rate%TYPE,
      pRts             amd_part_factors.rts%TYPE,
      pCmdmdRate       amd_part_factors.cmdmd_rate%TYPE,
      pActionCode      amd_part_factors.action_code%TYPE,
      pLastUpdateDt    amd_part_factors.last_update_dt%TYPE)
   IS
   BEGIN
      INSERT INTO amd_part_factors (part_no,
                                    loc_sid,
                                    pass_up_rate,
                                    rts,
                                    cmdmd_rate,
                                    action_code,
                                    last_update_dt)
           VALUES (pPartNo,
                   pLocSid,
                   pPassUpRate,
                   pRts,
                   pCmdmdRate,
                   pActionCode,
                   pLastUpdateDt);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UpdateAmdPartFactors (pPartNo,
                               pLocSid,
                               pPassUpRate,
                               pRts,
                               pCmdmdRate,
                               pActionCode,
                               pLastUpdateDt);
   END InsertAmdPartFactors;

   PROCEDURE InsertTmpAmdPartFactors (
      pPartNo          amd_part_factors.part_no%TYPE,
      pLocSid          amd_part_factors.loc_sid%TYPE,
      pPassUpRate      amd_part_factors.pass_up_rate%TYPE,
      pRts             amd_part_factors.rts%TYPE,
      pCmdmdRate       amd_part_factors.cmdmd_rate%TYPE,
      pActionCode      amd_part_factors.action_code%TYPE,
      pLastUpdateDt    amd_part_factors.last_update_dt%TYPE)
   IS
      returnCode   NUMBER;
   BEGIN
      INSERT INTO tmp_amd_part_factors (part_no,
                                        loc_sid,
                                        pass_up_rate,
                                        rts,
                                        cmdmd_rate,
                                        action_code,
                                        last_update_dt)
           VALUES (pPartNo,
                   pLocSid,
                   pPassUpRate,
                   pRts,
                   pCmdmdRate,
                   pActionCode,
                   pLastUpdateDt);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UpdateTmpAmdPartFactors (pPartNo,
                                  pLocSid,
                                  pPassUpRate,
                                  pRts,
                                  pCmdmdRate,
                                  pActionCode,
                                  pLastUpdateDt);
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (
               pSourceName       => 'InsertTmpAmdPartFactors',
               pTableName        => 'tmp_amd_part_factors',
               pError_location   => 70,
               pReturn_code      => 99,
               pKey1             => pPartNo,
               pKey2             => pLocSid,
               pKey3             => TO_CHAR (pPassUpRate),
               pData             =>    'pRts='
                                    || pRts
                                    || ' pCmdmdRate='
                                    || pCmdmdRate,
               pComments         => PKGNAME);
         RAISE;
   END InsertTmpAmdPartFactors;

   FUNCTION InsertRow (
      pPartNo                amd_part_factors.part_no%TYPE,
      pLocSid                amd_part_factors.loc_sid%TYPE,
      pPassUpRate            amd_part_factors.pass_up_rate%TYPE,
      pRts                   amd_part_factors.rts%TYPE,
      pCmdmdRate             amd_part_factors.cmdmd_rate%TYPE,
      pCriticality           amd_national_stock_items.criticality%TYPE,
      pCriticalityChanged    amd_national_stock_items.criticality_changed%TYPE,
      pCriticalityCleaned    amd_national_stock_items.criticality_cleaned%TYPE)
      RETURN NUMBER
   IS
      locationInfo   amd_spare_networks%ROWTYPE;
      mtdRec         mtd_rec := NULL;
      crit           amd_national_stock_items.criticality%TYPE := NULL;
      returnCode     NUMBER;
   BEGIN
      BEGIN
         InsertAmdPartFactors (pPartNo,
                               pLocSid,
                               pPassUpRate,
                               pRts,
                               pCmdmdRate,
                               Amd_Defaults.INSERT_ACTION,
                               SYSDATE);
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (pSourceName       => 'InsertRow.InsertAmdPartFactors',
                         pTableName        => 'amd_part_factors',
                         pError_location   => 80,
                         pReturn_code      => 99,
                         pKey1             => pPartNo,
                         pKey2             => pLocSid,
                         pKey3             => '',
                         pData             => '',
                         pComments         => PKGNAME);
            RAISE;
      END;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END InsertRow;

   FUNCTION UpdateRow (
      pPartNo                amd_part_factors.part_no%TYPE,
      pLocSid                amd_part_factors.loc_sid%TYPE,
      pPassUpRate            amd_part_factors.pass_up_rate%TYPE,
      pRts                   amd_part_factors.rts%TYPE,
      pCmdmdRate             amd_part_factors.cmdmd_rate%TYPE,
      pCriticality           amd_national_stock_items.criticality%TYPE,
      pCriticalityChanged    amd_national_stock_items.criticality_changed%TYPE,
      pCriticalityCleaned    amd_national_stock_items.criticality_cleaned%TYPE)
      RETURN NUMBER
   IS
      locationInfo   amd_spare_networks%ROWTYPE;
      mtdRec         mtd_rec := NULL;
      returnCode     NUMBER;
      crit           amd_national_stock_items.criticality%TYPE;
   BEGIN
      BEGIN
         UpdateAmdPartFactors (pPartNo,
                               pLocSid,
                               pPassUpRate,
                               pRts,
                               pCmdmdRate,
                               Amd_Defaults.UPDATE_ACTION,
                               SYSDATE);
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (pSourceName       => 'UpdateRow.UpdateAmdPartFactors',
                         pTableName        => 'tmp_amd_part_factors',
                         pError_location   => 90,
                         pReturn_code      => 99,
                         pKey1             => pPartNo,
                         pKey2             => pLocSid,
                         pKey3             => '',
                         pData             => '',
                         pComments         => PKGNAME);
            RAISE;
      END;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END UpdateRow;

   FUNCTION DeleteRow (pPartNo    amd_part_factors.part_no%TYPE,
                       pLocSid    amd_part_factors.loc_sid%TYPE)
      RETURN NUMBER
   IS
      locationInfo   amd_spare_networks%ROWTYPE;
      mtdRec         mtd_rec := NULL;
      crit           amd_national_stock_items.criticality%TYPE := NULL;
      returnCode     NUMBER;
   BEGIN
      BEGIN
         UPDATE amd_part_factors
            SET action_code = amd_defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE part_no = pPartNo AND loc_sid = pLocSid;
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (pSourceName       => 'DeleteRow.UpdateAmdPartFactors',
                         pTableName        => 'amd_part_factors',
                         pError_location   => 100,
                         pReturn_code      => 99,
                         pKey1             => pPartNo,
                         pKey2             => pLocSid,
                         pKey3             => '',
                         pData             => '',
                         pComments         => PKGNAME);
            RAISE;
      END;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END DeleteRow;

   FUNCTION DeleteRow (
      pPartNo                amd_part_factors.part_no%TYPE,
      pLocSid                amd_part_factors.loc_sid%TYPE,
      pPassUpRate            amd_part_factors.pass_up_rate%TYPE,
      pRts                   amd_part_factors.rts%TYPE,
      pCmdmdRate             amd_part_factors.cmdmd_rate%TYPE,
      pCriticality           amd_national_stock_items.criticality%TYPE,
      pCriticalityChanged    amd_national_stock_items.criticality_changed%TYPE,
      pCriticalityCleaned    amd_national_stock_items.criticality_cleaned%TYPE)
      RETURN NUMBER
   IS
      locationInfo   amd_spare_networks%ROWTYPE;
      mtdRec         mtd_rec := NULL;
      crit           amd_national_stock_items.criticality%TYPE := NULL;
      returnCode     NUMBER;
   BEGIN
      RETURN deleteRow (pPartNo, pLocSid);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END DeleteRow;


   /*
        ----------------------------------------------
        Load related procedures
        ----------------------------------------------
   */



   FUNCTION GetRepairIndicator (pNsn        bssm_base_parts.nsn%TYPE,
                                pSran       bssm_base_parts.sran%TYPE,
                                pLockSid    bssm_locks.LOCK_SID%TYPE)
      RETURN VARCHAR2
   IS
      retRI   bssm_base_parts.repair_indicator%TYPE;
   BEGIN
      IF ( (pNsn IS NULL) OR (pSran IS NULL))
      THEN
         RETURN NULL;
      END IF;

      SELECT repair_indicator
        INTO retRI
        FROM bssm_base_parts bbp, amd_nsns an
       WHERE     bbp.lock_sid = pLockSid
             AND an.nsn = bbp.nsn
             AND an.nsn_type = 'C' -- use the current nsn vs the temporary nsn
             AND an.nsi_sid = (SELECT nsi_sid
                                 FROM amd_nsns
                                WHERE nsn = pNsn)
             AND bbp.sran = pSran;

      RETURN retRI;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'GetRepairIndicator',
                   pTableName        => 'bssm_base_parts',
                   pError_location   => 110,
                   pKey_1            => pNsn,
                   pKey_2            => pSran,
                   pKey_3            => pLockSid);
         RAISE;
   END GetRepairIndicator;

   FUNCTION GetCapabilityLevel (pLocId amd_spare_networks.loc_id%TYPE)
      RETURN bssm_bases.capabilty_level%TYPE
   IS
      retCap   bssm_bases.capabilty_level%TYPE := NULL;
   BEGIN
      SELECT capabilty_level
        INTO retCap
        FROM bssm_bases
       WHERE     sran =
                    DECODE (
                       pLocId,
                       Amd_Defaults.AMD_WAREHOUSE_LOCID, Amd_Defaults.BSSM_WAREHOUSE_SRAN,
                       pLocId)
             AND lock_sid = '0';

      RETURN retCap;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'GetCapabilityLevel',
                   pTableName        => 'bssm_bases',
                   pError_location   => 120,
                   pKey_1            => pLocId);
         RAISE;
   END GetCapabilityLevel;

   FUNCTION LoadTmpAmdPartFactorsByLocType (
      pLocType   IN amd_spare_networks.loc_type%TYPE)
      RETURN NUMBER
   IS
      -- no mapping of amd loc_id to bssm sran for this one, use ByLocId if needed

      CURSOR partFactors_cur
      IS
         SELECT spo_prime_part_no,
                ansi.nsn,
                loc_sid,
                loc_type,
                loc_id,
                amd_preferred_pkg.GetPreferredValue (rts_avg_cleaned,
                                                     rts_avg,
                                                     rts_avg_defaulted)
                   rts,
                amd_preferred_pkg.GetPreferredValue (nrts_avg_cleaned,
                                                     nrts_avg,
                                                     nrts_avg_defaulted)
                   nrts,
                amd_preferred_pkg.GetPreferredValue (condemn_avg_cleaned,
                                                     condemn_avg,
                                                     condemn_avg_defaulted)
                   condemn
           FROM amd_national_stock_items ansi,
                amd_spare_parts parts,
                amd_spare_networks asn
          WHERE     is_spo_part = 'Y'
                AND parts.part_no = parts.spo_prime_part_no
                AND parts.spo_prime_part_no = ansi.prime_part_no
                AND ansi.action_code != Amd_Defaults.DELETE_ACTION
                AND asn.action_code != Amd_Defaults.DELETE_ACTION
                AND asn.loc_type = pLocType;

      mtdRec         mtd_rec;
      locationInfo   amd_spare_networks%ROWTYPE;
      returnCode     NUMBER := 0;
      cnt            NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_part_factors',
         pError_location   => 130,
         pKey1             => 'loadTmpAmdPartFactorsByLocType',
         pKey3             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      COMMIT;

      OPEN partFactors_cur;

      FETCH partFactors_cur BULK COLLECT INTO partFactorsRecs;

      CLOSE partFactors_cur;

      IF partFactorsRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN partFactorsRecs.FIRST .. partFactorsRecs.LAST
         LOOP
            BEGIN
               locationInfo.loc_type := partFactorsRecs (indx).loc_type;
               locationInfo.loc_id := partFactorsRecs (indx).loc_id;
               mtdRec := NULL;

               IF IsAutoDefaulted (locationInfo)
               THEN
                  mtdRec := AutoDefaultMtd;
               ELSE
                 <<convertMtd>>
                  BEGIN
                     mtdRec :=
                        convertMtdToDataSys (
                           locationInfo.loc_id,
                           GetCapabilityLevel (partFactorsRecs (indx).loc_id),
                           amd_preferred_pkg.GetPreferredValue (
                              GetRepairIndicator (
                                 partFactorsRecs (indx).nsn,
                                 partFactorsRecs (indx).loc_id,
                                 '2'),
                              GetRepairIndicator (
                                 partFactorsRecs (indx).nsn,
                                 partFactorsRecs (indx).loc_id,
                                 '0')),
                           partFactorsRecs (indx).nrts,
                           partFactorsRecs (indx).rts,
                           partFactorsRecs (indx).condemn);
                  EXCEPTION
                     WHEN maint_task_distrib_exception
                     THEN
                        ErrorMsg (
                           pSqlfunction      => 'select',
                           pTableName        => 'tmp_amd_part_factors',
                           pError_location   => 140,
                           pKey_1            => locationInfo.loc_id,
                           pKey_2            => partFactorsRecs (indx).nrts,
                           pKey_3            => partFactorsRecs (indx).rts,
                           pKey_4            =>    partFactorsRecs (indx).condemn
                                                || ' ='
                                                || (  partFactorsRecs (indx).rts
                                                    + partFactorsRecs (indx).nrts
                                                    + partFactorsRecs (indx).condemn));
                        RAISE;
                     WHEN OTHERS
                     THEN
                        ErrorMsg (
                           pSqlfunction      => 'select',
                           pTableName        => 'tmp_amd_part_factors',
                           pError_location   => 150,
                           pKey_1            => locationInfo.loc_id,
                           pKey_2            => partFactorsRecs (indx).nrts,
                           pKey_3            => partFactorsRecs (indx).rts,
                           pKey_4            =>    partFactorsRecs (indx).condemn
                                                || ' ='
                                                || (  partFactorsRecs (indx).rts
                                                    + partFactorsRecs (indx).nrts
                                                    + partFactorsRecs (indx).condemn));
                        RAISE;
                  END convertMtd;
               END IF;

               InsertTmpAmdPartFactors (partFactorsRecs (indx).part_no,
                                        partFactorsRecs (indx).loc_sid,
                                        mtdRec.nrts,
                                        mtdRec.rts,
                                        mtdRec.condemn,
                                        Amd_Defaults.INSERT_ACTION,
                                        SYSDATE);
               cnt := cnt + 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  returnCode :=
                     ErrorMsg (
                        pSourceName       => 'LoadTmpAmdPartFactorsByLocType',
                        pTableName        => 'tmp_amd_part_factors',
                        pError_location   => 160,
                        pReturn_code      => 99,
                        pKey1             =>    'locType:'
                                             || partFactorsRecs (indx).loc_type,
                        pKey2             =>    'partNo:'
                                             || partFactorsRecs (indx).part_no,
                        pKey3             =>    'locSid:'
                                             || partFactorsRecs (indx).loc_sid,
                        pData             =>    'cnt='
                                             || cnt
                                             || ' indx='
                                             || indx
                                             || ' partFactorsRecs.LAST='
                                             || partFactorsRecs.LAST,
                        pComments         => PKGNAME);
                  RAISE;
            END;
         END LOOP;

         COMMIT;
      END IF;

      writeMsg (
         pTableName        => 'tmp_amd_part_factors',
         pError_location   => 170,
         pKey1             => 'loadTmpAmdPartFactorsByLocType',
         pKey2             => 'cnt=' || cnt,
         pKey3             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      RETURN cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'select',
                   pTableName        => 'tmp_amd_part_factors',
                   pError_location   => 180,
                   pKey_1            => pLocType);
         RAISE;
   END LoadTmpAmdPartFactorsByLocType;


   FUNCTION LoadTmpAmdPartFactors (
      pAmdLocId   IN amd_spare_networks.loc_id%TYPE,
      pBssmSran   IN bssm_base_parts.sran%TYPE)
      RETURN NUMBER
   IS
      CURSOR partFactors_cur
      IS
         SELECT spo_prime_part_no,
                ansi.nsn,
                loc_sid,
                loc_type,
                loc_id,
                amd_preferred_pkg.GetPreferredValue (rts_avg_cleaned,
                                                     rts_avg,
                                                     rts_avg_defaulted)
                   rts,
                amd_preferred_pkg.GetPreferredValue (nrts_avg_cleaned,
                                                     nrts_avg,
                                                     nrts_avg_defaulted)
                   nrts,
                amd_preferred_pkg.GetPreferredValue (condemn_avg_cleaned,
                                                     condemn_avg,
                                                     condemn_avg_defaulted)
                   condemn
           FROM amd_national_stock_items ansi,
                amd_spare_parts parts,
                amd_spare_networks asn
          WHERE     parts.is_spo_part = 'Y'
                AND parts.part_no = parts.spo_prime_part_no
                AND parts.spo_prime_part_no = ansi.prime_part_no
                AND ansi.action_code != Amd_Defaults.DELETE_ACTION
                AND asn.action_code != Amd_Defaults.DELETE_ACTION
                AND asn.loc_id = pAmdLocId;

      cnt            NUMBER := 0;
      mtdRec         mtd_rec;
      locationInfo   amd_spare_networks%ROWTYPE;
      returnCode     NUMBER;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_part_factors',
         pError_location   => 190,
         pKey1             => 'loadTmpAmdPartFactors',
         pKey3             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      OPEN partFactors_cur;

      FETCH partFactors_cur BULK COLLECT INTO partFactorsRecs;

      CLOSE partFactors_cur;

      IF partFactorsRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN partFactorsRecs.FIRST .. partFactorsRecs.LAST
         LOOP
            BEGIN
               locationInfo.loc_type := partFactorsRecs (indx).loc_type;
               locationInfo.loc_id := partFactorsRecs (indx).loc_id;
               mtdRec := NULL;

               IF IsAutoDefaulted (locationInfo)
               THEN
                  mtdRec := AutoDefaultMtd;
               ELSE
                 <<convertMtd>>
                  BEGIN
                     mtdRec :=
                        convertMtdToDataSys (
                           locationInfo.loc_id,
                           GetCapabilityLevel (partFactorsRecs (indx).loc_id),
                           amd_preferred_pkg.GetPreferredValue (
                              GetRepairIndicator (
                                 partFactorsRecs (indx).nsn,
                                 partFactorsRecs (indx).loc_id,
                                 '2'),
                              GetRepairIndicator (
                                 partFactorsRecs (indx).nsn,
                                 partFactorsRecs (indx).loc_id,
                                 '0')),
                           partFactorsRecs (indx).nrts,
                           partFactorsRecs (indx).rts,
                           partFactorsRecs (indx).condemn);
                  EXCEPTION
                     WHEN maint_task_distrib_exception
                     THEN
                        ErrorMsg (
                           pSqlfunction      => 'select',
                           pTableName        => 'tmp_amd_part_factors',
                           pError_location   => 200,
                           pKey_1            => locationInfo.loc_id,
                           pKey_2            => partFactorsRecs (indx).nrts,
                           pKey_3            => partFactorsRecs (indx).rts,
                           pKey_4            =>    partFactorsRecs (indx).condemn
                                                || ' ='
                                                || (  partFactorsRecs (indx).rts
                                                    + partFactorsRecs (indx).nrts
                                                    + partFactorsRecs (indx).condemn));
                        RAISE;
                  END convertMtd;
               END IF;

               InsertTmpAmdPartFactors (partFactorsRecs (indx).part_no,
                                        partFactorsRecs (indx).loc_sid,
                                        mtdRec.nrts,
                                        mtdRec.rts,
                                        mtdRec.condemn,
                                        Amd_Defaults.INSERT_ACTION,
                                        SYSDATE);
               cnt := cnt + 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  returnCode :=
                     ErrorMsg (
                        pSourceName       => 'LoadTmpAmdPartFactors',
                        pTableName        => 'tmp_amd_part_factors',
                        pError_location   => 210,
                        pReturn_code      => 99,
                        pKey1             =>    'locType:'
                                             || partFactorsRecs (indx).loc_type,
                        pKey2             =>    'partNo:'
                                             || partFactorsRecs (indx).part_no,
                        pKey3             =>    'locSid:'
                                             || partFactorsRecs (indx).loc_sid,
                        pData             => '',
                        pComments         => PKGNAME);
                  RAISE;
            END;
         END LOOP;

         COMMIT;
      END IF;

      writeMsg (
         pTableName        => 'tmp_amd_part_factors',
         pError_location   => 220,
         pKey1             => 'loadTmpAmdPartFactors',
         pKey2             => 'cnt=' || cnt,
         pKey3             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      RETURN cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'select',
                   pTableName        => 'tmp_amd_part_factors',
                   pError_location   => 230,
                   pKey_1            => pAmdLocId,
                   pKey_2            => pBssmSran);
         RAISE;
   END LoadTmpAmdPartFactors;



   FUNCTION LoadTmpAmdPartFactors (
      pAmdLocId   IN amd_spare_networks.loc_id%TYPE)
      RETURN NUMBER
   IS
   BEGIN
      RETURN LoadTmpAmdPartFactors (pAmdLocId, pAmdLocId);
   END;


   PROCEDURE LoadTmpAmdPartFactors
   IS
      NO_BSSM_SRAN   VARCHAR2 (6) := NULL;
      cnt            NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_part_factors',
         pError_location   => 240,
         pKey1             => 'loadTmpAmdPartFactors',
         pKey3             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      mta_truncate_table ('tmp_amd_part_factors', 'reuse storage');


      -- mob and fsls
      cnt := LoadTmpAmdPartFactorsByLocType (MAIN_OPERATING_BASE);
      cnt := cnt + LoadTmpAmdPartFactorsByLocType (FORWARD_SUPPLY_LOCATION);
      -- whse - bssm 'W'', amd 'CTLATL'
      cnt :=
           cnt
         + LoadTmpAmdPartFactors (amd_defaults.AMD_WAREHOUSE_LOCID,
                                  amd_defaults.BSSM_WAREHOUSE_SRAN);
      cnt := cnt + LoadTmpAmdPartFactors (amd_defaults.AMD_UK_LOC_ID);
      cnt := cnt + LoadTmpAmdPartFactors (amd_defaults.AMD_BASC_LOC_ID);

      writeMsg (
         pTableName        => 'tmp_amd_part_factors',
         pError_location   => 250,
         pKey1             => 'loadTmpAmdPartFactors',
         pKey2             => 'cnt=' || TO_CHAR (cnt),
         pKey3             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'loadTmpAmdPartFactors',
                   pTableName        => 'tmp_amd_part_factors',
                   pError_location   => 260);
         RAISE;
   END LoadTmpAmdPartFactors;


   PROCEDURE LoadInitial
   IS
      returnCode   NUMBER;
      doAllA2A     BOOLEAN := TRUE;
   BEGIN
      mta_truncate_table ('amd_part_factors', 'reuse storage');
      COMMIT;
      LoadTmpAmdPartFactors;

      INSERT INTO amd_part_factors
         SELECT * FROM tmp_amd_part_factors;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (pSourceName       => 'LoadInitial',
                      pTableName        => 'tmp_amd_part_factors',
                      pError_location   => 270,
                      pReturn_code      => 99,
                      pKey1             => '',
                      pKey2             => '',
                      pKey3             => '',
                      pData             => '',
                      pComments         => PKGNAME || ': LoadInitial');
         RAISE;
   END;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_part_factors_pkg',
                pError_location   => 280,
                pKey1             => 'amd_part_factors_pkg',
                pKey2             => '$Revision:   1.17  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.17  $';
   END getVersion;


   PROCEDURE setDebug (VALUE IN VARCHAR2)
   IS
   BEGIN
      debug :=
         UPPER (VALUE) IN ('T',
                           'TRUE',
                           'Y',
                           'YES');
   END setDebug;

   FUNCTION getDebug
      RETURN VARCHAR2
   IS
   BEGIN
      IF debug
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getDebug;
END AMD_PART_FACTORS_PKG;
/