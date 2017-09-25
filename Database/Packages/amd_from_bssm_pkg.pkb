/* Formatted on 1/25/2017 2:51:49 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_FROM_BSSM_PKG
AS
   /*
    PVCS Keywords

      $Author:   Douglas S Elder
    $Revision:   1.14
        $Date:   25 Jan 2017
    $Workfile:   amd_from_bssm_pkg.pkb  $

     Rev 1.14    25 Jan 2017 reformatted code and 
                             added dbms_output for inserts Douglas Elder
  Implemented deadlock exception handler and added getVersion

     Rev 1.13   Sep 2, 2015   zf297a
  Implemented deadlock exception handler and added getVersion

     Rev 1.12   Jun 09 2006 11:20:30   zf297a
  Implemented version + used writeMsg for all loadAmd... public procedures

     Rev 1.11   Jun 09 2006 10:29:00   zf297a
  got rid of cannot convert message going to amd_load_details

     Rev 1.10   Dec 06 2005 09:42:40   zf297a
  Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS

     Rev 1.9   Aug 04 2005 14:35:44   zf297a
  Changed all queries using lock_sid to use a character string so it will search via the index.

     Rev 1.8   Jun 20 2005 15:11:50   c970183
  fixed update of criticality (it is a number in amd_national_stock_items)

     Rev 1.7   May 17 2005 10:08:20   c970183
  Updated InsertErrorMessage to new interface

     Rev 1.6   May 06 2005 07:31:18   c970183
  changed dla_warehouse_stcok to current_backorder fro amd_national_stock_items.  added PVCS keywords
   */



   ERRSOURCE             CONSTANT VARCHAR2 (20) := 'AmdFromBssmPkg';
   NOT_ACCEPTABLE_BSSM_PLTP_REC   EXCEPTION;


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
      Amd_Utils.writeMsg (pSourceName       => 'amd_from_bssm_pkg',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;

   PROCEDURE errorMsg (sqlFunction         IN VARCHAR2,
                       tableName           IN VARCHAR2,
                       errorLocation       IN NUMBER,
                       key1                IN VARCHAR2 := '',
                       key2                IN VARCHAR2 := '',
                       key3                IN VARCHAR2 := '',
                       key4                IN VARCHAR2 := '',
                       key5                IN VARCHAR2 := '',
                       keywordvaluepairs   IN VARCHAR2 := '')
   IS
   BEGIN
      ROLLBACK;
      amd_utils.inserterrormsg (
         pload_no        => amd_utils.getloadno (psourcename   => sqlfunction,
                                                 ptablename    => tablename),
         pdata_line_no   => errorlocation,
         pdata_line      => 'amd_from_bssm_pkg',
         pkey_1          => key1,
         pkey_2          => key2,
         pkey_3          => key3,
         pkey_4          => key4,
         pkey_5          =>    key5
                            || ' '
                            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS')
                            || ' '
                            || keywordvaluepairs,
         pcomments       =>    sqlfunction
                            || '/'
                            || tablename
                            || ' sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN;
   END errorMsg;

   FUNCTION ConvertCriticality (pCriticality bssm_parts.criticality%TYPE)
      RETURN VARCHAR2
   IS
      -- criticality is bssm is a number, criticality in amd is 1 char
      criticality   VARCHAR2 (1) := NULL;
   BEGIN
      -- from Tony Maingot of i2 - if criticality null, then consider as 'M'.
      -- however, will do this on outbound thru tmapi and leave as null in db.
      IF (pCriticality IS NULL)
      THEN
         criticality := NULL;
      ELSIF (pCriticality <= .33 AND pCriticality >= 0)
      THEN
         criticality := 'M';
      ELSIF (pCriticality <= .67)
      THEN
         criticality := 'D';
      ELSIF (pCriticality <= 1.0)
      THEN
         criticality := 'C';
      ELSE
         NULL;                                  -- if out of range return null
      END IF;

      RETURN criticality;
   END ConvertCriticality;

   FUNCTION ConvertItemType (pItemType bssm_parts.item_type%TYPE)
      RETURN amd_national_stock_items.item_type%TYPE
   IS
      itemType   VARCHAR2 (1) := NULL;
   /* -- email from laurie when asked for mapping of bssm to amd
     Sent: Thursday, October 25, 2001 2:38 PM
     In AMD today, T and P are Repairable, N is Consumable.  */

   BEGIN
      -- if not listed below, return as is
      IF (pItemType IS NULL)
      THEN
         itemType := NULL;
      ELSIF (pItemType IN ('P', 'T'))
      THEN
         itemType := 'R';
      ELSIF (pItemType = 'N')
      THEN
         itemType := 'C';
      ELSE
         itemType := pItemType;       -- cannot convert return what was passed
      END IF;

      RETURN itemType;
   END ConvertItemType;

   FUNCTION GetCurrentBssmNsn (pNsn bssm_parts.nsn%TYPE)
      RETURN bssm_parts.nsn%TYPE
   IS
      CURSOR bssmNsn_cur (
         pNsiSid    amd_nsns.nsi_sid%TYPE)
      IS
           SELECT bp.nsn
             FROM bssm_parts bp, amd_nsns an
            WHERE     bp.nsn = an.nsn
                  AND bp.lock_sid = '0'
                  AND an.nsi_sid = pNsiSid
         ORDER BY bp.nsn;

      rNsn_rec   bssmNsn_cur%ROWTYPE;
      nsiSid     amd_nsns.nsi_sid%TYPE;
   BEGIN
      -- nsn is likely to come from amd, this function will be updated when amd_nsns.creation_date
      -- usable, bssm_nsn_revisions data available, or not important as bob eberlein noted
      -- bssm_parts will contain current only.
      -- below just in case and to handle current data situation which has all versions
      -- of the "nsn", i.e. multiple bssm_parts lock_sid 0 records relate to one nsi_sid in amd.
      nsiSid := amd_utils.GetNsiSid (pNsn => pNsn);

      IF (NOT bssmNsn_cur%ISOPEN)
      THEN
         OPEN bssmNsn_cur (nsiSid);
      END IF;

      FETCH bssmNsn_cur INTO rNsn_rec;

      IF (bssmNsn_cur%NOTFOUND)
      THEN
         CLOSE bssmNsn_cur;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE bssmNsn_cur;

      RETURN rNsn_rec.nsn;
   END GetCurrentBssmNsn;

   FUNCTION GetLocSid (pLocId amd_spare_networks.loc_id%TYPE)
      RETURN amd_spare_networks.loc_sid%TYPE
   IS
      locId   amd_spare_networks.loc_id%TYPE := NULL;
   BEGIN
      IF (pLocId = BSSM_WAREHOUSE_SRAN)
      THEN
         locId := AMD_WAREHOUSE_LOCID;
      ELSE
         locId := pLocId;
      END IF;

      RETURN amd_utils.GetLocSid (locId);
   END GetLocSid;

   PROCEDURE LoadAmdBaseFromBssmRaw
   IS
      -- to get all of them
      CURSOR bssmBase_cur
      IS
         SELECT bp.*
           FROM bssm_base_parts bp, amd_nsns an
          WHERE bp.nsn = an.nsn AND bp.lock_sid = '0';

      /*
      (bp.repair_indicator is not null or
       bp.replacement_indicator is not null or
       );*/
      cnt   NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'amd_part_locs',
         pError_location   => 10,
         pKey1             => 'LoadAmdBaseFromBssmRaw',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR bssmBaseRec IN bssmBase_cur
      LOOP
         BEGIN
            UpdateAmdPartLocs (bssmBaseRec);
            cnt := cnt + 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction     => 'update',
                         tablename       => 'amd_part_locs',
                         errorLocation   => 10,
                         key1            => bssmBaseRec.nsn,
                         key2            => bssmBaseRec.sran);
               RAISE;
         END;
      END LOOP;

      writeMsg (
         pTableName        => 'amd_part_locs',
         pError_location   => 20,
         pKey1             => 'LoadAmdBaseFromBssmRaw',
         pKey2             => 'cnt=' || TO_CHAR (cnt),
         pKey3             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      COMMIT;
   END LoadAmdBaseFromBssmRaw;

   PROCEDURE LoadAmdBaseFromBssmRaw (pNsn     bssm_base_parts.nsn%TYPE,
                                     pSran    bssm_base_parts.sran%TYPE)
   IS
      bssmBaseRec   bssm_base_parts%ROWTYPE;

      -- current bssm can have not current parts in bssm_parts,
      vNsn          bssm_base_parts.nsn%TYPE;
   BEGIN
      -- nsn can come from any direction, from bssm or from amd
      -- still assuming bob eberlein in that his is only holding latest.
      vNsn := GetCurrentBssmNsn (pNsn);

      SELECT *
        INTO bssmBaseRec
        FROM bssm_base_parts
       WHERE nsn = vNsn AND sran = pSran AND lock_sid = '0';

      UpdateAmdPartLocs (bssmBaseRec);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'select',
                   tablename       => 'bssmBaseRec',
                   ErrorLocation   => 20,
                   key1            => vNsn,
                   key2            => pSran);
         RAISE;
   END LoadAmdBaseFromBssmRaw;

   PROCEDURE LoadAmdPartFromBssmRaw
   IS
      -- bssm_parts will only have latest part, now can
      -- go thru amd_nsns table.
      -- bob eberlein said only current part will be in bssm_parts
      -- so should not be a problem.  for foolproof, would go to
      -- bssm_nsn_revisions, but currently there is no data.
      /*
          cursor bssmParts_cur is
          select
              bp.*
           from
             bssm_parts bp,
             amd_national_stock_items ansi,
          amd_nsns an
          where
             bp.lock_sid = 0   and
          bp.nsn = an.nsn  and
          bp.nsn = GetCurrentBssmNsn(an.nsn) and
          an.nsi_sid = ansi.nsi_sid; */
      CURSOR bssmParts_cur
      IS
         SELECT bp.*
           FROM bssm_parts bp, amd_national_stock_items ansi, amd_nsns an
          WHERE     bp.lock_sid = '0'
                AND bp.nsn = an.nsn
                AND an.nsi_sid = ansi.nsi_sid;

      cnt   NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'amd_national_stock_items',
         pError_location   => 30,
         pKey1             => 'LoadAmdPartFromBssmRaw',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR bssmPartRec IN bssmParts_cur
      LOOP
         BEGIN
            UpdateAmdNsi (bssmPartRec);
            cnt := cnt + 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction     => 'update',
                         tablename       => 'amd_national_stock_items',
                         errorLocation   => 30,
                         key1            => bssmPartRec.nsn);
               RAISE;
         END;
      END LOOP;

      writeMsg (
         pTableName        => 'amd_national_stock_items',
         pError_location   => 40,
         pKey1             => 'LoadAmdPartFromBssmRaw',
         pKey2             => 'cnt=' || TO_CHAR (cnt),
         pKey3             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      COMMIT;
   END LoadAmdPartFromBssmRaw;


   PROCEDURE LoadAmdPartFromBssmRaw (pNsn bssm_parts.nsn%TYPE)
   IS
      bssmPartRec   bssm_parts%ROWTYPE;

      -- current bssm can have not current parts in bssm_parts,
      vNsn          bssm_parts.nsn%TYPE;
   BEGIN
      -- nsn can come from any direction, from bssm or from amd
      -- still assuming bob eberlein in that his is only holding latest.
      vNsn := GetCurrentBssmNsn (pNsn);

      SELECT *
        INTO bssmPartRec
        FROM bssm_parts
       WHERE nsn = vNsn AND lock_sid = '0';

      UpdateAmdNsi (bssmPartRec);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END LoadAmdPartFromBssmRaw;


   PROCEDURE LoadAmdPartLocTimePeriods
   IS
      CURSOR partLoc_cur
      IS
         SELECT apl.nsi_sid, apl.loc_sid, bpltp.*
           FROM bssm_part_loc_time_periods bpltp,
                amd_nsns an,
                amd_part_locs apl,
                amd_spare_networks asn
          WHERE     bpltp.nsn = an.nsn
                AND an.nsi_sid = apl.nsi_sid
                AND apl.loc_sid = asn.loc_sid
                AND asn.loc_id =
                       DECODE (bpltp.sran,
                               BSSM_WAREHOUSE_SRAN, AMD_WAREHOUSE_LOCID,
                               bpltp.sran);

      cnt   NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'amd_part_loc_time_periods',
         pError_location   => 50,
         pKey1             => 'LoadAmdPartLocTimePeriods',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR partLocRec IN partLoc_cur
      LOOP
         BEGIN
            -- bssm_part_loc_time_periods allows nullable fields
            -- amd_part_loc_time_periods has no fields nullable

            IF (   partLocRec.time_period_end IS NULL
                OR partLocRec.reorder_point IS NULL
                OR partLocRec.reorder_quantity IS NULL)
            THEN
               RAISE NOT_ACCEPTABLE_BSSM_PLTP_REC;
            END IF;

            IF (partLocRec.last_update_date IS NULL)
            THEN
               partLocRec.last_update_date := SYSDATE;
            END IF;

            INSERT INTO amd_part_loc_time_periods (nsi_sid,
                                                   loc_sid,
                                                   time_period_start,
                                                   time_period_end,
                                                   reorder_point,
                                                   reorder_quantity,
                                                   se_target,
                                                   action_code,
                                                   last_update_dt)
                 VALUES (partLocRec.nsi_sid,
                         partLocRec.loc_sid,
                         partLocRec.time_period_start,
                         partLocRec.time_period_end,
                         partLocRec.reorder_point,
                         partLocRec.reorder_quantity,
                         partLocRec.se_target,
                         amd_defaults.INSERT_ACTION,
                         partLocRec.last_update_date);

            cnt := cnt + 1;
         EXCEPTION
            WHEN NOT_ACCEPTABLE_BSSM_PLTP_REC
            THEN
               -- missing info which is not nullable for amd counterpart
               NULL;
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction     => 'insert',
                         tablename       => 'amd_part_loc_time_periods',
                         errorLocation   => 40,
                         key1            => partLocRec.nsn,
                         key2            => partLocRec.nsi_sid,
                         key3            => partLocRec.loc_sid);
               RAISE;
         END;
      END LOOP;

      DBMS_OUTPUT.put_line (
         'LoadAmdPartLocTimePeriods: rows inserted ' || cnt);
      writeMsg (
         pTableName        => 'amd_part_loc_time_periods',
         pError_location   => 60,
         pKey1             => 'LoadAmdPartLocTimePeriods',
         pKey2             => 'cnt=' || TO_CHAR (cnt),
         pKey3             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      COMMIT;
   END LoadAmdPartLocTimePeriods;


   PROCEDURE UpdateAmdNsi (pBssmPartsRec bssm_parts%ROWTYPE)
   IS
      nsiSid   amd_national_stock_items.nsi_sid%TYPE;

      PROCEDURE validateData
      IS
         item      amd_national_stock_items%ROWTYPE;
         line_no   NUMBER := 0;
      BEGIN
         line_no := line_no + 1;
         item.add_increment := pBssmPartsRec.add_increment;
         line_no := line_no + 1;
         item.amc_base_stock := pBssmPartsRec.amc_base_stock;
         line_no := line_no + 1;
         item.amc_days_experience := pBssmPartsRec.amc_days_experience;
         line_no := line_no + 1;
         item.amc_demand := pBssmPartsRec.amc_demand;
         line_no := line_no + 1;
         item.capability_requirement := pBssmPartsRec.capability_requirement;
         line_no := line_no + 1;
         item.condemn_avg := pBssmPartsRec.condemn;
         line_no := line_no + 1;
         item.criticality := pBssmPartsRec.criticality;
         line_no := line_no + 1;
         item.demand_variance := pBssmPartsRec.demand_variance;
         line_no := line_no + 1;
         item.dla_demand := pBssmPartsRec.dla_demand;
         line_no := line_no + 1;
         item.current_backorder := pBssmPartsRec.current_backorder;
         line_no := line_no + 1;
         item.min_purchase_quantity := pBssmPartsRec.min_purchase_quantity;
         line_no := line_no + 1;
         item.nrts_avg := pBssmPartsRec.nrts;
         line_no := line_no + 1;
         item.rts_avg := pBssmPartsRec.rts;
         line_no := line_no + 1;
         item.ru_ind := pBssmPartsRec.ru_ind;
         line_no := line_no + 1;
         item.time_to_repair_on_base_avg := pBssmPartsRec.on_base_turnaround;
         line_no := line_no + 1;
         item.user_comment := pBssmPartsRec.user_comment;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction     => 'validate',
                      tablename       => 'amd_national_stock_items',
                      errorLocation   => 50,
                      key1            => TO_CHAR (line_no));
            RAISE;
      END validateData;
   BEGIN
      -- will throw exception if not found
      validateData;
      nsiSid := amd_utils.GetNsiSid (pNsn => pBssmPartsRec.nsn);

      UPDATE amd_national_stock_items
         SET add_increment = pBssmPartsRec.add_increment,
             amc_base_stock = pBssmPartsRec.amc_base_stock,
             amc_days_experience = pBssmPartsRec.amc_days_experience,
             amc_demand = pBssmPartsRec.amc_demand,
             capability_requirement = pBssmPartsRec.capability_requirement,
             condemn_avg = pBssmPartsRec.condemn,
             criticality = pBssmPartsRec.criticality,
             demand_variance = pBssmPartsRec.demand_variance,
             dla_demand = pBssmPartsRec.dla_demand,
             current_backorder = pBssmPartsRec.current_backorder,
             -- fedc_cost = pBssmPartsRec.fedc_cost,
             --     now mic pulled from amd_l67_tmp directly
             -- mic_code_lowest = pBssmPartsRec.mic_code,
             min_purchase_quantity = pBssmPartsRec.min_purchase_quantity,
             nrts_avg = pBssmPartsRec.nrts,
             rts_avg = pBssmPartsRec.rts,
             ru_ind = pBssmPartsRec.ru_ind,
             time_to_repair_on_base_avg = pBssmPartsRec.on_base_turnaround,
             user_comment = pBssmPartsRec.user_comment,
             last_update_dt = SYSDATE
       WHERE nsi_sid = nsiSid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- cannot find nsiSid
         NULL;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tablename       => 'amd_national_stock_items',
                   errorLocation   => 60,
                   key1            => nsiSid);
         RAISE;
   END UpdateAmdNsi;


   PROCEDURE UpdateAmdPartLocs (pBssmBaseRec bssm_base_parts%ROWTYPE)
   IS
      nsiSid              amd_national_stock_items.nsi_sid%TYPE;
      locSid              amd_spare_networks.loc_sid%TYPE;
      executed            BOOLEAN := FALSE;
      cnt                 NUMBER := 0;
      DEADLOCK   CONSTANT NUMBER := -60;
   -- handle deadlock exceptions and try to get the update
   -- completed. if more than 6 attempts occur for the
   -- same update abort
   BEGIN
      -- nsi_sid will throw exception if not found
      nsiSid := amd_utils.GetNsiSid (pNsn => pBssmBaseRec.nsn);
      locSid := GetLocSid (pBssmBaseRec.sran);

      IF (locSid IS NOT NULL)
      THEN
         LOOP
            cnt := cnt + 1;

            BEGIN
               UPDATE amd_part_locs
                  SET repair_level_code = pBssmBaseRec.repair_indicator,
                      removal_ind = pbssmbaserec.replacement_indicator,
                      --          will come from ramp
                      -- rsp_on_hand       = pBssmBaseRec.rsp_on_hand,
                      -- rsp_objective      = pBssmBaseRec.rsp_objective,
                      order_cost = pBssmBaseRec.order_cost,
                      holding_cost = pBssmBaseRec.holding_cost,
                      backorder_fixed_cost = pBssmBaseRec.backorder_fixed_cost,
                      backorder_variable_cost =
                         pBssmBaseRec.backorder_variable_cost,
                      last_update_dt = SYSDATE
                WHERE nsi_sid = nsiSid AND loc_sid = locSid;

               executed := TRUE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  IF SQLCODE = DEADLOCK
                  THEN
                     sleep (20);
                  ELSE
                     RAISE;
                  END IF;
            END;

            EXIT WHEN executed OR cnt >= 6;
         END LOOP;

         IF NOT executed
         THEN
            raise_application_error (
               -20001,
                  'UpdateAmdPartLocs: deadlock for nsi_sid='
               || nsiSid
               || ' loc_sid='
               || locSid);
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- cannot find nsiSid
         NULL;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tablename       => 'amd_part_locs',
                   errorLocation   => 70,
                   key1            => nsiSid,
                   key2            => locSid);
         RAISE;
   END UpdateAmdPartLocs;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_from_bssm_pkg',
                pError_location   => 80,
                pKey1             => 'amd_from_bssm_pkg',
                pKey2             => '$Revision:   1.14  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.14 $';
   END getVersion;
END AMD_FROM_BSSM_PKG;
/