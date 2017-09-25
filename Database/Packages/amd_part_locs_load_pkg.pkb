/* Formatted on 1/25/2017 2:28:18 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_LOCS_LOAD_PKG
IS
    /*

       $Author:   Douglas S Elder
     $Revision:   1.14
         $Date:   25 Jan 2017
     $Workfile:   amd_part_locs_load_pkg.pkb  $

      Rev 1.14    25 Jan 2017 reformatted code and added dbms_output for rows inserted

      Rev 1.13    13 Feb 2012 used common routine and new amd_repair_cost_detail to calc avg cost  to repair off base zf297a

     Rev 1.12     07 Dec 2011 Made the ccn_prefix query more flexible by using the length of the ccn_prefix in the substr of the existential subquery and added function getVersion

      Rev 1.11   07 Nov 2007 23:59:08   zf297a
   Use bulk collect and bulk insert for major cursors.

      Rev 1.10   12 Sep 2007 15:39:36   zf297a
   Removed commits from for loops.

      Rev 1.9   15 May 2007 09:33:30   zf297a
   Eliminated writing "unique constraint" errors to amd_load_details when the procedure does not stop.  Added using mod to check for commit points.  Used enhanced writeMsg and errorMsg to write messages and errors to amd_load_details.  Added recording of "start" and "end" times to amd_load_details.

      Rev 1.8   Jun 09 2006 12:12:20   zf297a
   implemented version

      Rev 1.7   Dec 06 2005 10:33:56   zf297a
   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS

      Rev 1.4.1.1   Jun 13 2005 09:19:06   c970183
   Added PVCS keywords

*/



   /*
    --  Date      By   History
       --  ----    --   -------
       --  10/10/01      ks  initial implementation
       --  12/11/01      dse  Added named param for amd_preferred_pkg.GetUnitCost(.....
       --  8/14/02    ks            change fsl query to be more efficient.
    --  6/01/05    ks  changes to support AMD 1.7.1 - change to RSP_ON_HAND, RSP_OBJECTIVE
    --     mod to queries for bssm, eg. lock_sid use '0' instead of 0
   */
   ERRSOURCE   CONSTANT VARCHAR2 (20) := 'amdpartlocsloadpkg';
   dups                 NUMBER := 0;

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
      Amd_Utils.writeMsg (pSourceName       => 'amd_part_locs_load_pkg',
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
         -- trying to rollback or commit from trigger
         IF SQLCODE = 4092
         THEN
            raise_application_error (
               -20010,
               SUBSTR (
                     'amd_part_locs_load_pkg '
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
         ELSE
            RAISE;
         END IF;
   END writeMsg;

   PROCEDURE ErrorMsg (
      pSqlfunction      IN AMD_LOAD_STATUS.SOURCE%TYPE,
      pTableName        IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
      pError_location      AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
      pKey1             IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
      pKey2             IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
      pKey3             IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
      pKey4             IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
      pComments         IN VARCHAR2 := '')
   IS
      key5             AMD_LOAD_DETAILS.KEY_5%TYPE := pComments;
      error_location   NUMBER;
   BEGIN
      ROLLBACK;

      IF key5 = ''
      THEN
         key5 := pSqlFunction || '/' || pTableName;
      ELSE
         key5 := key5 || ' ' || pSqlFunction || '/' || pTableName;
      END IF;

      IF amd_utils.isNumber (pError_location)
      THEN
         error_location := pError_location;
      ELSE
         error_location := -9999;
      END IF;

      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important
      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (
                              pSourceName   => SUBSTR (pSqlfunction, 1, 20),
                              pTableName    => SUBSTR (pTableName, 1, 20)),
         pData_line_no   => error_location,
         pData_line      => 'amd_part_locs_load_pkg',
         pKey_1          => SUBSTR (pKey1, 1, 50),
         pKey_2          => SUBSTR (pKey2, 1, 50),
         pKey_3          => SUBSTR (pKey3, 1, 50),
         pKey_4          => SUBSTR (pKey4, 1, 50),
         pKey_5          =>    TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS')
                            || ' '
                            || SUBSTR (key5, 1, 50),
         pComments       => SUBSTR (
                                 'sqlcode('
                              || SQLCODE
                              || ') sqlerrm('
                              || SQLERRM
                              || ')',
                              1,
                              2000));
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
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

         IF pKey1 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key1=' || pKey1);
         END IF;

         IF pkey2 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key2=' || pKey2);
         END IF;

         IF pKey3 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key3=' || pKey3);
         END IF;

         IF pKey4 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key4=' || pKey4);
         END IF;

         IF pComments IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pComments=' || pComments);
         END IF;

         raise_application_error (
            -20030,
            SUBSTR (
                  'amd_part_locs_load_pkg '
               || SQLCODE
               || ' '
               || pError_location
               || ' '
               || pSqlFunction
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
               || pComments,
               1,
               2000));
   END ErrorMsg;

   FUNCTION GetAmdNsiRec (pNsiSid amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items%ROWTYPE
   IS
      amdNsiRec   amd_national_stock_items%ROWTYPE := NULL;
   BEGIN
      SELECT *
        INTO amdNsiRec
        FROM amd_national_stock_items
       WHERE nsi_sid = pNsiSid;

      RETURN amdNsiRec;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN amdNsiRec;
   END GetAmdNsiRec;

   /* function GetOffBaseRepairCost, logic same as previous load version */
   FUNCTION GetOffBaseRepairCost (pPartNo CHAR)
      RETURN amd_part_locs.cost_to_repair%TYPE
   IS
      nsiSid   amd_national_stock_items.nsi_sid%TYPE := NULL;
   --
   --    Use only PART   number because POI1 does not have Cage Code.
   --
   BEGIN
      SELECT nsi_sid
        INTO nsiSid
        FROM amd_national_stock_items items, amd_spare_parts parts
       WHERE     parts.part_no = pPartNo
             AND parts.nsn = items.nsn
             AND parts.action_code <> 'D'
             AND items.action_code <> 'D';

      RETURN AMD_OWNER.GETCOSTTOREPAIROFFBASE (nsiSid);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END GetOffBaseRepairCost;

   /* function get_off_base_tat, logic same as previous load version
      removed offbasediag time from previous version */
   FUNCTION GetOffBaseTurnAround (pPartno CHAR)
      RETURN amd_part_locs.time_to_repair%TYPE
   IS
      -- goldpart      char(50);
      offBaseTurnAroundTime   amd_part_locs.time_to_repair%TYPE;
   BEGIN
        SELECT AVG (completed_docdate - created_docdate)
          INTO offBaseTurnAroundTime
          FROM ord1
         WHERE     part = pPartNo
               AND NVL (action_taken, '*') IN ('A',
                                               'B',
                                               'E',
                                               'G',
                                               '*')
               AND order_type = 'J'
               AND completed_docdate IS NOT NULL
      GROUP BY part;

      RETURN offBaseTurnAroundTime;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END GetOffBaseTurnAround;

   FUNCTION GetOnBaseRepairCost (pPartno VARCHAR2)
      RETURN NUMBER
   IS
      --
      -- on base repair cost is to be calculated using data
      -- from tmp_lccost table.
      -- this table will be loaded on a monthly basis from rmads and the result
      -- are stored in amd_on_base_repair_costs.
      --
      -- formular:
      --
      -- on base repair cost = average mhr * average dollars($20)
      --
      -- where average mhr is calculated by add up the manhours for each ajcn,
      --  and then divide by the   number of total ajcn for the part.
      --
      --  average dollars is default to $20 per hour at this time.
      --
      --  note: if no part found, default the on base repair cost to $40.00
      --
      onBaseRepairCost   NUMBER;
   BEGIN
      BEGIN
         SELECT on_base_repair_cost
           INTO onBaseRepairCost
           FROM amd_on_base_repair_costs
          WHERE part_no = pPartno;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN NULL;
      END;

      RETURN onBaseRepairCost;
   END GetOnBaseRepairCost;

   /* kcs change to ramp%ROWTYPE from rampData_rec */
   FUNCTION GetRampData (pNsn       ramp.nsn%TYPE,
                         pLocSid    amd_spare_networks.loc_sid%TYPE)
      RETURN ramp%ROWTYPE
   IS
      /* rampData rampData_rec := null; */
      rampData   ramp%ROWTYPE := NULL;
      locId      amd_spare_networks.loc_id%TYPE;
   BEGIN
      locId := amd_utils.GetLocId (pLocSid);

      IF (locId IS NULL)
      THEN
         RETURN rampData;
      ELSE
         RETURN GetRampData (pNsn, locId);
      END IF;
   END GetRampData;

   /* kcs change to ramp%ROWTYPE from rampData_rec */
   FUNCTION GetRampData (pNsn      ramp.nsn%TYPE,
                         pLocId    amd_spare_networks.loc_id%TYPE)
      RETURN ramp%ROWTYPE
   IS
      CURSOR rampData_cur (pNsn      ramp.nsn%TYPE,
                           pLocId    amd_spare_networks.loc_id%TYPE)
      IS
         SELECT *
           FROM ramp
          WHERE current_stock_number = pNsn AND SUBSTR (sc, 8, 6) = pLocId;

      nsn        ramp.current_stock_number%TYPE;
      rampData   rampData_cur%ROWTYPE := NULL;
   -- though currently ramp does not return more than one record, design
   -- of ramp table allows. current_stock_number is not part of key.
   -- use explicit cursor just in case.

   BEGIN
      nsn := amd_utils.FormatNsn (pNsn, 'GOLD');

      IF (NOT rampData_cur%ISOPEN)
      THEN
         OPEN rampData_cur (nsn, pLocId);
      END IF;

      FETCH rampData_cur INTO rampData;

      CLOSE rampData_cur;

      RETURN rampData;
   END GetRampData;

   --
   -- Select all MOB's from AMD then
   -- remove MOB's from BSSM that have 'N''s
   -- and add FSL's from BSSM that have 'Y''s

   -- lifted from current version, modified to go to
   -- amd_national_stock_items table and add 'OFFBASE' parts.
   -- to minimize recoding, made cursor since amd_part_locs needs nsi and not nsn.

   -- Bob Eberlein's note says that bssm will only carry the current part in
   -- bssm_parts (i.e. not all versions of nsn like nsl, ncz, nsn).
   -- implies won't need to determine which one is "live" in his system
   -- and negates the potential for 3 "nsns" in bssm_parts relating to one nsi_sid.
   -- just pull nsi_sid by amd_nsns, in case bssm_parts one step behind (load
   -- currently less frequent than amd load).

   PROCEDURE LoadAmdPartLocations
   IS
      amdNsiRec             amd_national_stock_items%ROWTYPE := NULL;
      amdPartLocsRec        amd_part_locs%ROWTYPE := NULL;

      TYPE amdPartLocsTab IS TABLE OF amd_part_locs%ROWTYPE;

      amdPartLocsRecs       amdPartLocsTab := amdPartLocsTab ();

      unitCost              amd_spare_parts.unit_cost%TYPE := NULL;
      locId                 amd_spare_networks.loc_id%TYPE := NULL;
      partBaseCleanRec      amd_cleaned_from_bssm_pkg.partBaseFields := NULL;
      /* kcs rampData rampData_rec; */
      rampData              ramp%ROWTYPE;
      countRecs             NUMBER := 0;

      TYPE partLocsMobRec IS RECORD
      (
         nsi_sid   amd_national_stock_items.nsi_sid%TYPE,
         loc_sid   amd_spare_networks.loc_sid%TYPE
      );

      TYPE partLocsMobTab IS TABLE OF partLocsMobRec;

      partLocsMobRecs       partLocsMobTab;

      CURSOR partLocsMobList_cur
      IS
           --
           -- MOB SELECTION LOGIC
           --
           --
           -- Select all MOB's from AMD
           --
           -- the order by is to speed up processing of records.
           -- some info is not location dependent currently and therefore
           -- does not have to be re-retrieved.  saves 80% time for 97k+ records.
           -- based on substr if smr null or < 3 chars will be not part of 1st select,
           -- though mdd would.  confirmed with laurie for now, consistent with previous load.
           SELECT *
             FROM (SELECT ansi.nsi_sid, asn.loc_sid
                     FROM amd_national_stock_items ansi, amd_spare_networks asn
                    WHERE     asn.loc_type = 'MOB'
                          AND SUBSTR (amd_preferred_pkg.GetSmrCode (ansi.nsn),
                                      3,
                                      1) != 'D'
                          AND ansi.action_code IN ('A', 'C')
                          AND asn.action_code IN ('A', 'C')
                   --
                   -- MOB EXCLUSION LOGIC
                   --
                   MINUS
                   ( (SELECT                                        -- bbp.nsn
                            an.nsi_sid, asn.loc_sid
                        FROM bssm_base_parts bbp,
                             amd_spare_networks asn,
                             amd_nsns an
                       WHERE     lock_sid = '0'
                             AND bbp.nsn = an.nsn
                             AND bbp.sran = asn.loc_id
                             AND asn.loc_type = 'MOB'
                             AND bbp.replacement_indicator = 'N'
                             AND asn.action_code IN ('A', 'C')
                      MINUS
                      SELECT                                       -- bbp.nsn,
                            an.nsi_sid, asn.loc_sid
                        FROM bssm_base_parts bbp,
                             amd_spare_networks asn,
                             amd_nsns an
                       WHERE     lock_sid = '2'
                             AND bbp.nsn = an.nsn
                             AND bbp.sran = asn.loc_id
                             AND asn.loc_type = 'MOB'
                             AND asn.action_code IN ('A', 'C')
                             AND bbp.replacement_indicator = 'Y')
                    UNION
                    SELECT                                         -- bbp.nsn,
                          an.nsi_sid, asn.loc_sid
                      FROM bssm_base_parts bbp,
                           amd_spare_networks asn,
                           amd_nsns an
                     WHERE     lock_sid = '2'
                           AND bbp.nsn = an.nsn
                           AND bbp.sran = asn.loc_id
                           AND asn.loc_type = 'MOB'
                           AND bbp.replacement_indicator = 'N'
                           AND asn.action_code IN ('A', 'C')))
         ORDER BY nsi_sid;

      --
      -- FSL SELECTION LOGIC
      --b1
      --
      -- Select valid combo's using capability logic and valid in
      -- locks 0 and 2
      --
      CURSOR partLocsFslList_cur
      IS
           SELECT *
             FROM ( (SELECT                                         -- bp.nsn,
                           an.nsi_sid, asn.loc_sid
                       FROM bssm_parts bp,
                            bssm_bases bb,
                            amd_spare_networks asn,
                            amd_national_stock_items ansi,
                            amd_nsns an
                      WHERE     bp.capability_requirement > 0
                            AND bp.lock_sid = '0'
                            AND bb.lock_sid = '0'
                            AND SIGN (
                                   (  bp.capability_requirement
                                    - bb.capabilty_level)) != -1
                            AND bb.sran = asn.loc_id
                            AND asn.loc_type = 'FSL'
                            -- and bp.nsn              = ansi.nsn
                            AND bp.nsn = an.nsn
                            AND an.nsi_sid = ansi.nsi_sid
                            AND ansi.action_code IN ('A', 'C')
                            AND asn.action_code IN ('A', 'C')
                     UNION
                     SELECT                                        -- bbp.nsn,
                           ansi.nsi_sid, asn.loc_sid
                       FROM bssm_base_parts bbp,
                            amd_spare_networks asn,
                            amd_national_stock_items ansi,
                            amd_nsns an
                      WHERE     lock_sid IN ('0', '2')
                            AND bbp.sran = asn.loc_id
                            AND asn.loc_type = 'FSL'
                            AND asn.action_code IN ('A', 'C')
                            AND ansi.action_code IN ('A', 'C')
                            AND bbp.replacement_indicator = 'Y'
                            AND bbp.nsn = an.nsn
                            AND an.nsi_sid = ansi.nsi_sid)
                   --
                   -- Subtract invalid combo's in locks 2 and 0
                   --
                   MINUS
                   (SELECT                                         -- bbp.nsn,
                          an.nsi_sid, asn.loc_sid
                      FROM bssm_base_parts bbp,
                           amd_spare_networks asn,
                           amd_nsns an
                     WHERE     lock_sid = '2'
                           AND bbp.sran = asn.loc_id
                           AND asn.loc_type = 'FSL'
                           AND bbp.replacement_indicator = 'N'
                           AND bbp.nsn = an.nsn
                           AND asn.action_code IN ('A', 'C')
                    UNION
                    SELECT                                          -- bbp.nsn
                          an.nsi_sid, asn.loc_sid
                      FROM bssm_base_parts bbp,
                           amd_spare_networks asn,
                           amd_nsns an
                     WHERE     lock_sid = '0'
                           AND bbp.sran = asn.loc_id
                           AND asn.loc_type = 'FSL'
                           AND bbp.nsn = an.nsn
                           AND asn.action_code IN ('A', 'C')
                           AND bbp.replacement_indicator = 'N'
                           AND NOT EXISTS
                                  (SELECT 'x'
                                     FROM bssm_base_parts bbp2
                                    WHERE     lock_sid = '2'
                                          AND bbp2.sran = bbp.sran
                                          AND bbp2.nsn = bbp.nsn
                                          AND bbp2.replacement_indicator = 'Y')))
         ORDER BY nsi_sid;

      TYPE partLocsOffBaseRec IS RECORD
      (
         nsi_sid         amd_national_stock_items.nsi_sid%TYPE,
         prime_part_no   amd_national_stock_items.prime_part_no%TYPE,
         loc_sid         amd_spare_networks.loc_sid%TYPE
      );

      TYPE partLocsOffBaseTab IS TABLE OF partLocsOffBaseRec;

      partLocsOffBaseRecs   partLocsOffBaseTab;

      CURSOR partLocsOffBaseList_cur
      IS
         SELECT ansi.nsi_sid, ansi.prime_part_no, asn.loc_sid
           FROM amd_national_stock_items ansi, amd_spare_networks asn
          WHERE     asn.loc_id = OFFBASE_LOCID
                AND ansi.action_code IN ('A', 'C')
                AND asn.action_code IN ('A', 'C');

      /* changed to insert statement --
      cursor partLocsWareHouse_cur is
           select
            ansi.nsi_sid,
            asn.loc_sid
        from
            amd_national_stock_items ansi,
            amd_spare_networks asn
        where
            asn.loc_id = amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID and
            ansi.action_code in ('A', 'C') and
            asn.action_code in ('A', 'C');
      */
      -- end cursor definitions


      PROCEDURE InsertIntoAmdPartLocs (pRec amd_part_locs%ROWTYPE)
      IS
      BEGIN
         INSERT INTO amd_part_locs (nsi_sid,
                                    loc_sid,
                                    awt,
                                    awt_defaulted,
                                    cost_to_repair,
                                    cost_to_repair_defaulted,
                                    mic,
                                    mic_defaulted,
                                    removal_ind,
                                    removal_ind_defaulted,
                                    removal_ind_cleaned,
                                    repair_level_code,
                                    repair_level_code_defaulted,
                                    repair_level_code_cleaned,
                                    time_to_repair,
                                    time_to_repair_defaulted,
                                    tactical,
                                    action_code,
                                    last_update_dt,
                                    rsp_on_hand,
                                    rsp_objective,
                                    order_cost,
                                    holding_cost,
                                    backorder_fixed_cost,
                                    backorder_variable_cost)
              VALUES (pRec.nsi_sid,
                      pRec.loc_sid,
                      pRec.awt,
                      pRec.awt_defaulted,
                      pRec.cost_to_repair,
                      pRec.cost_to_repair_defaulted,
                      pRec.mic,
                      pRec.mic_defaulted,
                      pRec.removal_ind,
                      pRec.removal_ind_defaulted,
                      pRec.removal_ind_cleaned,
                      pRec.repair_level_code,
                      pRec.repair_level_code_defaulted,
                      pRec.repair_level_code_cleaned,
                      pRec.time_to_repair,
                      pRec.time_to_repair_defaulted,
                      pRec.tactical,
                      pRec.action_code,
                      pRec.last_update_dt,
                      pRec.rsp_on_hand,
                      pRec.rsp_objective,
                      pRec.order_cost,
                      pRec.holding_cost,
                      pRec.backorder_fixed_cost,
                      pRec.backorder_variable_cost);

         DBMS_OUTPUT.put_line (
            'insertIntoAmdPartLocs: rows inserted ' || SQL%ROWCOUNT);
      END InsertIntoAmdPartLocs;
   BEGIN
      --
      -- load mobs into part locations
      --
      writeMsg (
         pTableName        => 'amd_part_locs',
         pError_location   => 10,
         pKey1             => 'LoadAmdPartLocations',
         pKey3             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      OPEN partLocsMobList_cur;

      FETCH partLocsMobList_cur BULK COLLECT INTO partLocsMobRecs;

      CLOSE partLocsMobList_cur;

      IF partLocsMobRecs.FIRST IS NOT NULL
      THEN
         BEGIN
            FOR indx IN partLocsMobRecs.FIRST .. partLocsMobRecs.LAST
            LOOP
               -- minimize retrieving of amdNsiRec and onbaserepaircost, note order by in cursor
               -- all of the hardcoded null assignments related to amdPartLocsRec fields,
               -- could be taken out, already handled with
               -- amdPartLocsRec := null.  takes up minimal time, left in for visibility.
               rampData := NULL;

               IF (   partLocsMobRecs (indx).nsi_sid != amdNsiRec.nsi_sid
                   OR amdNsiRec.nsi_sid IS NULL)
               THEN
                  amdPartLocsRec := NULL;
                  amdNsiRec := GetAmdNsiRec (partLocsMobRecs (indx).nsi_sid);
                  amdPartLocsRec.nsi_sid := partLocsMobRecs (indx).nsi_sid;
                  amdPartLocsRec.cost_to_repair :=
                     GetOnBaseRepairCost (amdNsiRec.prime_part_no);

                  IF (amdPartLocsRec.cost_to_repair IS NULL)
                  THEN
                     -- currently default is 40
                     amdPartLocsRec.cost_to_repair_defaulted :=
                        amd_defaults.COST_TO_REPAIR_ONBASE;
                  END IF;
               END IF;

               locId := amd_utils.GetLocId (partLocsMobRecs (indx).loc_sid);

               amdPartLocsRec.loc_sid := partLocsMobRecs (indx).loc_sid;
               amdPartLocsRec.awt := NULL;
               amdPartLocsRec.awt_defaulted := NULL;

               amdPartLocsRec.mic := NULL;
               amdPartLocsRec.mic_defaulted := NULL;
               -- Eric Honma, default MOB 'Y'  FSL 'N' for repair_indicator/repair_level_code
               -- and removal indicator.
               -- also part of exception table bssm_base_parts
               -- if removal ind cleaned is 'N' then error in cursor
               amdPartLocsRec.removal_ind := NULL;
               amdPartLocsRec.removal_ind_defaulted := 'Y';
               -- will retrieve all cleanable fields for bssm base parts
               -- cleaning done as a post process to speed up
               amdPartLocsRec.removal_ind_cleaned := NULL;
               amdPartLocsRec.repair_level_code := NULL;
               amdPartLocsRec.repair_level_code_defaulted := 'Y';
               amdPartLocsRec.repair_level_code_cleaned := NULL;
               rampData := GetRampData (amdNsiRec.nsn, locId);
               amdPartLocsRec.time_to_repair := rampData.avg_repair_cycle_time;

               -- lauries "command decision" treat null and 0 as same => need default.
               IF (NVL (amdPartLocsRec.time_to_repair, 0) = 0)
               THEN
                  amdPartLocsRec.time_to_repair := NULL;
                  amdPartLocsRec.time_to_repair_defaulted :=
                     amd_defaults.TIME_TO_REPAIR_ONBASE;
               END IF;

               amdPartLocsRec.tactical := 'Y';
               amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
               amdPartLocsRec.last_update_dt := SYSDATE;
               /* kcs changes to support bssm 603 and amd1.7.1
               amdPartLocsRec.rsp_on_hand := rampData.wrm_balance;
               amdPartLocsRec.rsp_objective := rampData.wrm_level;
               */
               amdPartLocsRec.rsp_on_hand :=
                    NVL (rampData.wrm_balance, 0)
                  + NVL (rampData.spram_balance, 0)
                  + NVL (rampData.hpmsk_balance, 0);
               amdPartLocsRec.rsp_objective :=
                    NVL (rampData.wrm_level, 0)
                  + NVL (rampData.spram_level, 0)
                  + NVL (rampData.hpmsk_level_qty, 0);
               -- filled in afterwards in separate process, bssm only source for now
               -- look in amd_from_bssm_pkg,
               -- null assignment here just to note
               amdPartLocsRec.order_cost := NULL;
               amdPartLocsRec.holding_cost := NULL;
               amdPartLocsRec.backorder_fixed_cost := NULL;
               amdPartLocsRec.backorder_variable_cost := NULL;
               -- insert record to the dynamic table collection
               amdPartLocsRecs.EXTEND;
               amdPartLocsRecs (amdPartLocsRecs.LAST) := amdPartLocsRec;
               countRecs := countRecs + 1;
            END LOOP;

            FORALL indx IN amdPartLocsRecs.FIRST .. amdPartLocsRecs.LAST
               INSERT INTO amd_part_locs
                    VALUES amdPartLocsRecs (indx);

            DBMS_OUTPUT.put_line (
                  'LoadAmdPartLocations 1: rows inserted into amd_part_locs '
               || amdPartLocsRecs.LAST);
            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'insert',
                         pTableName        => 'amd_part_locs',
                         pError_location   => 20,
                         pKey1             => amdPartLocsRec.nsi_sid,
                         pKey2             => amdPartLocsRec.loc_sid);
         END;
      END IF;

      --
      -- load fsls into part locations
      --
      amdPartLocsRecs.delete;                                   -- empty table

      amdNsiRec := NULL;

      OPEN partLocsFslList_cur;

      FETCH partLocsFslList_cur BULK COLLECT INTO partLocsMobRecs;

      CLOSE partLocsFslList_cur;

      IF partLocsMobRecs.FIRST IS NOT NULL
      THEN
         BEGIN
            FOR indx IN partLocsMobRecs.FIRST .. partLocsMobRecs.LAST
            LOOP
               rampData := NULL;

               -- minimize retrieving of amdNsiRec and onbaserepaircost
               IF (   partLocsMobRecs (indx).nsi_sid != amdNsiRec.nsi_sid
                   OR amdNsiRec.nsi_sid IS NULL)
               THEN
                  amdPartLocsRec := NULL;
                  amdNsiRec := GetAmdNsiRec (partLocsMobRecs (indx).nsi_sid);
                  amdPartLocsRec.nsi_sid := partLocsMobRecs (indx).nsi_sid;
                  amdPartLocsRec.cost_to_repair :=
                     GetOnBaseRepairCost (amdNsiRec.prime_part_no);

                  IF (amdPartLocsRec.cost_to_repair IS NULL)
                  THEN
                     -- currently default is 40
                     amdPartLocsRec.cost_to_repair_defaulted :=
                        amd_defaults.COST_TO_REPAIR_ONBASE;
                  END IF;
               END IF;


               locId := amd_utils.GetLocId (partLocsMobRecs (indx).loc_sid);

               amdPartLocsRec.loc_sid := partLocsMobRecs (indx).loc_sid;
               amdPartLocsRec.awt := NULL;
               amdPartLocsRec.awt_defaulted := NULL;

               amdPartLocsRec.mic := NULL;
               amdPartLocsRec.mic_defaulted := NULL;
               -- Eric Honma, default MOB 'Y'  FSL 'N' for repair_indicator/repair_level_code
               -- and removal indicator.
               -- also part of exception table bssm_base_parts
               -- if removal ind cleaned is 'N' then error in cursor
               amdPartLocsRec.removal_ind := NULL;
               amdPartLocsRec.removal_ind_defaulted := 'N';
               -- cleaning done as a post process to speed up
               amdPartLocsRec.removal_ind_cleaned := NULL;
               amdPartLocsRec.repair_level_code := NULL;
               amdPartLocsRec.repair_level_code_defaulted := 'N';
               amdPartLocsRec.repair_level_code_cleaned := NULL;
               rampData := GetRampData (amdNsiRec.nsn, locId);
               amdPartLocsRec.time_to_repair := rampData.avg_repair_cycle_time;

               -- lauries "command decision" treat null and 0 as same => need default.
               IF (NVL (amdPartLocsRec.time_to_repair, 0) = 0)
               THEN
                  amdPartLocsRec.time_to_repair := NULL;
                  amdPartLocsRec.time_to_repair_defaulted :=
                     amd_defaults.TIME_TO_REPAIR_ONBASE;
               END IF;

               amdPartLocsRec.tactical := 'Y';
               amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
               amdPartLocsRec.last_update_dt := SYSDATE;
               /* kcs changes to support bssm 603 and amd1.7.1
               amdPartLocsRec.rsp_on_hand := rampData.wrm_balance;
               amdPartLocsRec.rsp_objective := rampData.wrm_level;
               */
               amdPartLocsRec.rsp_on_hand :=
                    NVL (rampData.wrm_balance, 0)
                  + NVL (rampData.spram_balance, 0)
                  + NVL (rampData.hpmsk_balance, 0);
               amdPartLocsRec.rsp_objective :=
                    NVL (rampData.wrm_level, 0)
                  + NVL (rampData.spram_level, 0)
                  + NVL (rampData.hpmsk_level_qty, 0); -- filled in afterwards in separate process, bssm only source for now
               -- look in amd_from_bssm_pkg,
               -- null assignment here just to note
               amdPartLocsRec.order_cost := NULL;
               amdPartLocsRec.holding_cost := NULL;
               amdPartLocsRec.backorder_fixed_cost := NULL;
               amdPartLocsRec.backorder_variable_cost := NULL;
               amdPartLocsRecs.EXTEND;
               amdPartLocsRecs (amdPartLocsRecs.LAST) := amdPartLocsRec;
               countRecs := countRecs + 1;
            END LOOP;

            FORALL indx IN amdPartLocsRecs.FIRST .. amdPartLocsRecs.LAST
               INSERT INTO amd_part_locs
                    VALUES amdPartLocsRecs (indx);

            DBMS_OUTPUT.put_line (
                  'LoadAmdPartLocations 2: rows inserted into amd_part_locs '
               || amdPartLocsRecs.LAST);
            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'insert',
                         pTableName        => 'amd_part_locs',
                         pError_location   => 30,
                         pKey1             => amdPartLocsRec.nsi_sid,
                         pKey2             => amdPartLocsRec.loc_sid);
         END;
      END IF;

      --
      -- load offbase into part locations
      --
      amdPartLocsRecs.delete;                                         -- empty

      OPEN partLocsOffBaseList_cur;

      FETCH partLocsOffBaseList_cur BULK COLLECT INTO partLocsOffBaseRecs;

      CLOSE partLocsOffBaseList_cur;

      IF partLocsOffBaseRecs.FIRST IS NOT NULL
      THEN
         BEGIN
            FOR indx IN partLocsOffBaseRecs.FIRST .. partLocsOffBaseRecs.LAST
            -- partLocsOffBaseRec only has nsn and location.
            -- should change defaulted to pull from params table.
            -- cursors all tied to ansi so nsn, partno in cursor will be in ansi
            LOOP
               amdPartLocsRec := NULL;
               amdPartLocsRec.nsi_sid := partLocsOffBaseRecs (indx).nsi_sid;
               amdPartLocsRec.loc_sid := partLocsOffBaseRecs (indx).loc_sid;
               amdPartLocsRec.awt := NULL;
               amdPartLocsRec.awt_defaulted := NULL;
               amdPartLocsRec.cost_to_repair :=
                  GetOffBaseRepairCost (
                     partLocsOffBaseRecs (indx).prime_part_no);

               IF (amdPartLocsRec.cost_to_repair IS NULL)
               THEN
                  -- amd_preferred throws exception
                  -- currently unit cost is null.
                  BEGIN
                     unitCost :=
                        amd_preferred_pkg.GetUnitCost (
                           pNsi_Sid   => partLocsOffBaseRecs (indx).nsi_sid);
                     amdPartLocsRec.cost_to_repair_defaulted :=
                        unitCost * (amd_defaults.UNIT_COST_FACTOR_OFFBASE);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        amdPartLocsRec.cost_to_repair_defaulted := NULL;
                  END;
               END IF;

               amdPartLocsRec.mic := NULL;
               -- no real meaning of following for offbase, set to null
               amdPartLocsRec.removal_ind := NULL;
               amdPartLocsRec.removal_ind_defaulted := NULL;
               amdPartLocsRec.removal_ind_cleaned := NULL;
               amdPartLocsRec.repair_level_code := NULL;
               amdPartLocsRec.repair_level_code_defaulted := NULL;
               amdPartLocsRec.repair_level_code_cleaned := NULL;

               amdPartLocsRec.time_to_repair :=
                  GetOffBaseTurnAround (
                     partLocsOffBaseRecs (indx).prime_part_no);

               IF (amdPartLocsRec.time_to_repair IS NULL)
               THEN
                  amdPartLocsRec.time_to_repair_defaulted :=
                     amd_defaults.TIME_TO_REPAIR_OFFBASE;
               END IF;

               amdPartLocsRec.tactical := 'Y';
               amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
               amdPartLocsRec.last_update_dt := SYSDATE;
               amdPartLocsRec.rsp_on_hand := NULL;
               amdPartLocsRec.rsp_objective := NULL;
               amdPartLocsRec.order_cost := NULL;
               amdPartLocsRec.holding_cost := NULL;
               amdPartLocsRec.backorder_fixed_cost := NULL;
               amdPartLocsRec.backorder_variable_cost := NULL;

               -- insert record
               amdPartLocsRecs.EXTEND;
               amdPartLocsRecs (amdPartLocsRecs.LAST) := amdPartLocsRec;
               countRecs := countRecs + 1;
            END LOOP;

            FORALL indx IN amdPartLocsRecs.FIRST .. amdPartLocsRecs.LAST
               INSERT INTO amd_part_locs
                    VALUES amdPartLocsRecs (indx);

            DBMS_OUTPUT.put_line (
                  'LoadAmdPartLocations 3: rows inserted '
               || amdPartLocsRecs.LAST);
            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'insert',
                         pTableName        => 'amd_part_locs',
                         pError_location   => 40,
                         pKey1             => amdPartLocsRec.nsi_sid,
                         pKey2             => amdPartLocsRec.loc_sid);
         END;
      END IF;

      --
      -- load warehouse parts
      --
      BEGIN
         INSERT INTO amd_part_locs (nsi_sid,
                                    loc_sid,
                                    tactical,
                                    action_code,
                                    last_update_dt)
            SELECT ansi.nsi_sid,
                   asn.loc_sid,
                   'Y',
                   amd_defaults.INSERT_ACTION,
                   SYSDATE
              FROM amd_national_stock_items ansi, amd_spare_networks asn
             WHERE     asn.loc_id = amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID
                   AND ansi.action_code IN ('A', 'C')
                   AND asn.action_code IN ('A', 'C');

         DBMS_OUTPUT.put_line (
            'LoadAmdPartLocations 4: rows inserted ' || SQL%ROWCOUNT);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            dups := dups + 1;
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'insert',
                      pTableName        => 'amd_part_locs',
                      pError_location   => 50);
      END;

      writeMsg (
         pTableName        => 'amd_part_locs',
         pError_location   => 60,
         pKey1             => 'LoadAmdPartLocations',
         pKey2             => 'dups=' || dups,
         pKey3             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey4             => 'countRecs=' || countRecs);

      COMMIT;
   END LoadAmdPartLocations;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_part_locs_load_pkg',
                pError_location   => 70,
                pKey1             => 'amd_part_locs_load_pkg',
                pKey2             => '$Revision:   1.14  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.14  $';
   END getVersion;
BEGIN
   NULL;
END AMD_PART_LOCS_LOAD_PKG;
/