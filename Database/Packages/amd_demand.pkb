CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Demand
AS
   /*
         $Author:    Douglas S. Elder
       $Revision:   1.58
           $Date:   09 Feb 2018
       $Workfile:   amd_demand.sql
            Rev 1.58    DSE 02/09/2018 fixed proc_code value to be GFP vs GPV
            Rev 1.57    DSE 01/31/2018 for procedures loadSanAntonioDemands and its cursor sanAntonioDemands
                                       add a check of proc_code and accept it if it is NULL or GPF
                                       and added EY1746 to the IN list for AND NOT (    SUBSTR (R.request_id, 1, 6) IN
                                  ('FB2065', 'EY1213', 'EY1746') of loadDepotDemands ( formerly loadBascUkDemands)
                                       per TFS ticket 52919

            Rev 1.56    DSE 12/19/2017 removed locattion EY1746 from the date filter implemented by
                        rev 1.54.1 per TFS 48244

            Rev 1.55    DSE 11/22/2017 added dbms_output for all raise commands

            Rev 1.54.3  DSE 8/25/2017 added loadWarnerRobinsDemands


            Rev 1.54.2  DSE 8/8/2017 Changed query for loadSanAntonioDemands: date comparison
            >= '2015-01' and created_date not truncated to the first of the month

            Rev 1.54.1  DSE 8/7/2017 excluded demands for ukbasc that are
                       1. substr(request_id,1,6) in ('FB2065', 'EY1213','EY1746')
                       2. and created_datetime >= 2015-01

            Rev 1.54    DSE 8/2/2017 added procedure loadSanAntonioDemands

            Rev 1.53.11 DSE 10/19/16 added DBMS output when loading amd_demands

            Rev 1.53.10 DSE 09/23/15 use START_LOC_ID constant

            Rev 1.53.9 DSE 09/21/15 use amd_defaults.getProgramId

            Rev 1.53.8 DSE 06/09/15 use trhi.loc_id

            Rev 1.53.7 DSE 06/05/15 added nsi_sid to merge command for load_amd_demands_table

            Rev 1.53.6 DSE 2/23/15 added amd_defaults.getStartLocId

           Rev 1.53.5 DSE 6/17/15 for any lcf table filtered out substr(doc_no,1,4) = 'S005'

           Rev 1.53.4 DSE 6/16/15 for amd_l67_source filtered out substr(doc_no,1,4) = 'S005'

           Rev 1.53.3 DSE 8/19/14 Laurie said the nsn's with dashes in them for amd_l67_source can be ignored - the function was also slowing down access and
           the process was taking 19 hours to complete!

           Rev 1.53.2 DSE 6/13/14 added amd_utils.formatNsn function when comparing nsn against amd_rbl_pairs.old_nsn

           Rev 1.53.1 DSE 6/12/14 changed L67cur to manage TIN and TRN's , DOC and DUO's and related ISG pairs

           Rev 1.53 DSE 2/21/14 changed loadAmdBssmSourceTmpAmdDemands' to use  writeMsg for start/end stats
           added writeMsg to:
               InsertL67TmpLcfIcp
               loadAmdBssmSourceTmpAmdDemands
               LoadFmsDemands
               LoadBascUkDemands
               load_amd_demands_table
           added merge to load_amd_demands_table


           Rev 1.52 DSE 2/11/14 changed loadAmdBssmSourceTmpAmdDemands's docsur's group by to include nsn and modified
           CalcQuantity and CalcBadQuantity to include nsn as an argument so qty's will be by doc and nsn per Laurie Compton's request
           Also, changed spec and made CalcQuantity and CalcBadQuantiy public so they can be easily tested

          Rev 1.51 (DouglasElder) added an "when others" exception hanlder for LoadBascUkDemands

          Rev 1.50 (402417) and asn2.loc_sid is not null  ... added to cursor for loadFmsDemand

         Rev 1.49 renamed procedure loadAmdDemands to loadAmdBssmSourceTmpAmdDemands

         Rev 1.48 renamed procedure amd_demand_a2a to load_amd_demand_table

         Rev 1.47 Streamlined demandCur for loadBascUkDemands and added table amd_depot_partnering_locations with the addition of Macon to
         the list of locations previously used

         Rev 1.46 fix the query against amd_sc_inclusions to use an existential qualifier

         Rev 1.45   Additional criteria to the REASON in function CalcQuantity per CQ# LBPSS00002694 (L67 Demand DOC TTPC Action Taken Code Modification) requested by LC.

         Rev 1.44   Added Procedure LoadFmsDemand per ClearQuest# LBPSS00002393 by Laurie Compton.

         Rev 1.43   Thuy switched reason and dmd_cd for CalcQuantity and CalcBadQuantity
                    Thuy modified CalcQuantity and CalcBadQuantity

         Rev 1.42   11 Sep 2009 12:40:20   zf297a
      Implemented interfaces getVersion, setDebug, and getDebugYorN
      and added pragma for ErrorMsg

         Rev 1.41   24 Feb 2009 14:13:40   zf297a
      Removed a2a code.

         Rev 1.40   28 Oct 2008 08:46:46   zf297a
      When creating ExtForecast A2A transactions, make the duplicate column 1 when it is null.

         Rev 1.39   10 Apr 2008 11:07:02   zf297a
      Thuy Pham added EB as request_id to be part of LoadBascUKDemand.

         Rev 1.38   23 Oct 2007 18:29:34   zf297a
      For genDuplicateForConsumables fix the cursor demandsNotSame to make sure that it only retrieves the current period and beyond.

         Rev 1.37   03 Oct 2007 13:25:08   zf297a
      Implemented interface getCalendarDate and interface getFiscalPeriod.

         Rev 1.36   12 Sep 2007 13:58:38   zf297a
      Removed commits from for loop.

         Rev 1.35   21 Aug 2007 11:52:00   zf297a
      Passed part_no instead of rec.nsn to amd_utils.isPartActive for nested procedure insertA2A which is subordinate to procedure loadAllA2A.

         Rev 1.34   20 Aug 2007 09:32:02   zf297a
      Added constant EXTERNAL and implemented procedure loadAllA2A.

         Rev 1.33   17 Aug 2007 13:42:36   zf297a
      Changed the program code to count the total number of periods that should have the same quantity for each part/location - so the A2A record with the PERIOD counts that record itself as being included in the DUPLICATE count.  Where we had DUPLICATE value of '1' before goes to '2', and value of '63' goes to '64'.

         Rev 1.32   08 Aug 2007 11:23:42   zf297a
      Fixed getCurrentPeriod for when the period > cur_year to compute the current period as 10/01/period - 1 when the cur_month < 10, and cur_month/01/period - 1  when the cur_month >= 10.

         Rev 1.31   08 Aug 2007 09:59:42   zf297a
      Adjusted the duplicate count to be 1 less so that the count includes the record that contains the duplicate: ie a duplicate of 1 means the current record plus 1 = 2 records of the 66 total allowed and a duplicate of 63 means the current record plus 63 = 64 of the 66 total allowed.

         Rev 1.30   08 Aug 2007 00:26:06   zf297a
      Fixed getCurrentPeriod to return 10/1/period when period > current year.
      Fixed genDuplicateForConsumables to sum periods together that have the same demand_forecast.  Fixed final update to update only those periods belonging to the current_period with 66.

         Rev 1.29   07 Aug 2007 13:31:04   zf297a
      Fixed update of tmp_amd_dmnd_frcst_consumables - the where clause should have period = (select min(period)....) not perdiod <> (select min(period)...)

         Rev 1.28   01 Aug 2007 16:58:56   zf297a
      Make sure the update of tmp_amd_dmnd_frcst_consumables updates only the current_period with the duplicate of  DUP_THRESHOLD

         Rev 1.27   01 Aug 2007 16:38:38   zf297a
      removed function getDuplicate.  Enhanced procedure doDmndFrcstConsumablesDiff by adding duplicate to the interface.
      Added function getCurrentPeriod, which will be using in creating the tmp_a2a_ext_forecast table.
      Create a routine to read tmp_amd_dmnd_frcst_consumables and create the duplicate column needed for the ExtForecast A2A transactions.

         Rev 1.26   23 Jul 2007 15:47:22   zf297a
      Implemented interface for getDuplicate, which is a function used to get the duplicate # for the A2A External Forecast Transaction.

      Used amd_loc_part_forecasts_pkg.getCurrentPeriod, which gets it data from the amd_param_changes table, for the period and the new function getDuplicate(cur_period) to get the duplicate # for the A2A External  Forecast Transaction.

         Rev 1.25   Jul 20 2007 07:03:38   c402417
      Added Canada Demand(EY1414).

         Rev 1.24   Jul 19 2007 19:19:26   c402417
      Modified procedure insertA2A
      to get correct Period and Duplicate.

         Rev 1.23   23 May 2007 00:12:14   zf297a
      Implemented interface doDmndFrcstConsumablesDiff

         Rev 1.22   Apr 05 2007 11:13:10   c402417
      Remove all the  TRIM from WHERE clauses for AMD v1.8.06.6

         Rev 1.21   Mar 05 2007 12:09:46   c402417
      Added AU demand.

         Rev 1.20   Jun 09 2006 12:51:26   zf297a
      implemented version

         Rev 1.19   Mar 07 2006 13:17:32   c402417
      Changed field Site to get spo_location from amd_spare_networks instead of loc_id.

         Rev 1.18   Dec 07 2005 13:12:20   zf297a
      When joining with amd_sent_to_a2a, make sure the part was not deleted from the SPO - i.e. action_code != 'D'.

      Check that the super prime part no is actually vaild and that it has been sent to the SPO.

         Rev 1.17   Dec 05 2005 16:43:30   c402417
      Added version 1.10.1.2 to the current version.

         Rev 1.14   Dec 01 2005 09:30:38   zf297a
      added pvcs keywords
   */



   debug                    BOOLEAN := FALSE;
   doWarnings               BOOLEAN := FALSE;
   PROGRAM_ID      CONSTANT VARCHAR2 (30) := amd_defaults.getProgramId;
   PROGRAM_ID_LL   CONSTANT NUMBER := LENGTH (PROGRAM_ID);
   START_LOC_ID    CONSTANT NUMBER := amd_defaults.getStartLocId;

   EXTERNAL_CNST   CONSTANT VARCHAR2 (8) := 'External';

   PROCEDURE InsertTmpLcf1;

   PROCEDURE InsertTmpLcfIcp;

   PROCEDURE InsertL67TmpLcfIcp;

   PROCEDURE errorMsg (sqlFunction         IN VARCHAR2,
                       tableName           IN VARCHAR2,
                       pError_Location     IN NUMBER,
                       key1                IN VARCHAR2 := '',
                       key2                IN VARCHAR2 := '',
                       key3                IN VARCHAR2 := '',
                       key4                IN VARCHAR2 := '',
                       key5                IN VARCHAR2 := '',
                       keywordValuePairs   IN VARCHAR2 := '')
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (pSourceName   => sqlFunction,
                                                 pTableName    => tableName),
         pData_line_no   => pError_Location,
         pData_line      => 'amd_demand',
         pKey_1          => key1,
         pKey_2          => key2,
         pKey_3          => key3,
         pKey_4          => key4,
         pKey_5          =>    key5
                            || ' '
                            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS')
                            || ' '
                            || keywordValuePairs,
         pComments       =>    SqlFunction
                            || '/'
                            || TableName
                            || ' sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN;
   END ErrorMsg;


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
      Amd_Utils.writeMsg (pSourceName       => 'amd_demand',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;

   FUNCTION CalcQuantity (pDocNo VARCHAR2, pNsn VARCHAR2, pDic VARCHAR2)
      RETURN NUMBER
   IS
      qty     NUMBER := 0;
      qtyd1   NUMBER := 0;
      qtyd2   NUMBER := 0;
   BEGIN
      IF pDic = 'TIN'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   --                    AND dic = 'TIN'
                   AND ttpc = '1B'
                   AND dmd_cd IN ('B',
                                  'C',
                                  'J',
                                  'V',
                                  'X',
                                  'A',
                                  'D',
                                  'F',
                                  'G',
                                  'K',
                                  'L',
                                  'Z',
                                  '1',
                                  '2',
                                  '3',
                                  '4',
                                  '5',
                                  '6',
                                  '7',
                                  '8',
                                  '9');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      ELSIF pDic = 'TRN'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'TRN'
                   AND ttpc = '4S'
                   AND reason IN ('A',
                                  'F',
                                  'G',
                                  'K',
                                  'L',
                                  'Z');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      ELSIF pDic = 'ISU'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'ISU'
                   AND ttpc IN ('1A', '3P', '3Q');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      ELSIF pDic = 'MSI'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'MSI'
                   AND ttpc IN ('1C',
                                '1G',
                                '1O',
                                '1Q',
                                '2I',
                                '2K',
                                '3P');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      ELSIF pDic = 'DUO'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'DUO'
                   AND ttpc IN ('2D', '4W');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      ELSIF pDic = 'DOC'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qtyd1
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'DOC'
                   AND ttpc IN ('2A', '2C')
                   AND (   reason IN ('B',
                                      'C',
                                      'J',
                                      'V',
                                      'X',
                                      'A',
                                      'F',
                                      'G',
                                      'K',
                                      'L',
                                      'Z')
                        OR reason IS NULL); /* added on 7/20/2010 by TP requested by LC */
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qtyd1 := 0;
         END;

         qty := qtyd1;
      END IF;

      RETURN (qty);
   END CalcQuantity;


   FUNCTION CalcBadQuantity (pDocNo VARCHAR2, pNsn VARCHAR2, pDic VARCHAR2)
      RETURN NUMBER
   IS
      qty   NUMBER := 0;
   BEGIN
      IF pDic = 'TIN'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'TIN'
                   AND ttpc = '1B'
                   AND dmd_cd NOT IN ('B',
                                      'C',
                                      'J',
                                      'V',
                                      'X',
                                      'A',
                                      'D',
                                      'F',
                                      'G',
                                      'K',
                                      'L',
                                      'Z',
                                      '1',
                                      '2',
                                      '3',
                                      '4',
                                      '5',
                                      '6',
                                      '7',
                                      '8',
                                      '9');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      ELSIF pDic = 'TRN'
      THEN
         BEGIN
            SELECT NVL (SUM (action_qty), 0)
              INTO qty
              FROM TMP_LCF_ICP
             WHERE     doc_no = pDocNo
                   AND nsn = pNsn
                   AND dic = 'TRN'
                   AND ttpc = '4S'
                   AND reason NOT IN ('A',
                                      'F',
                                      'G',
                                      'K',
                                      'L',
                                      'Z');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               qty := 0;
         END;
      END IF;

      RETURN (qty);
   END CalcBadQuantity;



   PROCEDURE InsertTmpLcf1
   IS
   BEGIN
      INSERT INTO TMP_LCF_1 (stock_no,
                             erc,
                             dic,
                             ttpc,
                             dmd_cd,
                             reason,
                             doc_no,
                             trans_date,
                             trans_ser,
                             action_qty,
                             sran,
                             nomenclature,
                             marked_for,
                             date_of_last_demand,
                             unit_of_issue,
                             supplemental_address)
           SELECT stock_no,
                  erc,
                  dic,
                  ttpc,
                  dmd_cd,
                  reason,
                  doc_no,
                  TO_DATE (trans_date, 'yyyyddd'),
                  trans_ser,
                  action_qty,
                  sran,
                  nomenclature,
                  marked_for,
                  TO_DATE (date_of_last_demand, 'yyyyddd'),
                  unit_of_issue,
                  supplemental_address
             FROM TMP_LCF_RAW
            WHERE     SUBSTR (doc_no, 1, 1) IN ('X',
                                                'J',
                                                'R',
                                                'B',
                                                'S')
                  AND SUBSTR (doc_no, 1, 4) <> 'S005'
         GROUP BY stock_no,
                  erc,
                  dic,
                  ttpc,
                  dmd_cd,
                  reason,
                  doc_no,
                  TO_DATE (trans_date, 'yyyyddd'),
                  trans_ser,
                  action_qty,
                  sran,
                  nomenclature,
                  marked_for,
                  TO_DATE (date_of_last_demand, 'yyyyddd'),
                  unit_of_issue,
                  supplemental_address;


      UPDATE TMP_LCF_1
         SET nsn = SUBSTR (stock_no, 1, 13),
             mmc = SUBSTR (stock_no, 14, 2),
             sran = 'FB' || sran;

      COMMIT;
   END InsertTmpLcf1;


   PROCEDURE InsertTmpLcfIcp
   IS
   BEGIN
      INSERT INTO TMP_LCF_ICP (nsn,
                               mmc,
                               stock_no,
                               erc,
                               dic,
                               ttpc,
                               dmd_cd,
                               reason,
                               doc_no,
                               trans_date,
                               trans_ser,
                               action_qty,
                               sran,
                               nomenclature,
                               marked_for,
                               date_of_last_demand,
                               supplemental_address)
         SELECT nsn,
                mmc,
                stock_no,
                erc,
                dic,
                ttpc,
                dmd_cd,
                reason,
                doc_no,
                trans_date,
                trans_ser,
                action_qty,
                DECODE (asn.loc_type, 'TMP', asn.mob, sran) sran,
                nomenclature,
                marked_for,
                date_of_last_demand,
                supplemental_address
           FROM TMP_LCF_1 tl1, AMD_SPARE_NETWORKS asn
          WHERE tl1.sran = asn.loc_id AND SUBSTR (tl1.doc_no, 1, 4) <> 'S005';

      COMMIT;
   END InsertTmpLcfIcp;



   PROCEDURE InsertL67TmpLcfIcp
   IS
      CURSOR l67Cur
      IS
         SELECT DISTINCT als.nsn,
                         mmc,
                         erc,
                         tric,
                         ttpc,
                         dmd_cd,
                         reason,
                         als.doc_no,
                         trans_date,
                         trans_ser,
                         action_qty,
                         DECODE (asn.loc_type, 'TMP', asn.mob, sran) sran,
                         nomenclature,
                         marked_for,
                         dold,
                         supp_address
           FROM AMD_L67_SOURCE als, AMD_SPARE_NETWORKS asn, amd_rbl_pairs p
          WHERE     SUBSTR (als.doc_no, 1, 1) IN ('X',
                                                  'S',
                                                  'B',
                                                  'J',
                                                  'R')
                AND SUBSTR (als.doc_no, 1, 4) <> 'S005'
                AND als.sran = asn.loc_id
                AND amd_utils.formatNsn (als.nsn) = p.old_nsn
                AND (   tric IN ('TIN', 'TRN')
                     OR (    tric = 'DOC'
                         AND EXISTS
                                (SELECT NULL
                                   FROM amd_l67_source
                                  WHERE     doc_no = als.doc_no
                                        AND nsn = als.nsn
                                        AND tric = 'DUO'))
                     OR (    tric = 'DUO'
                         AND EXISTS
                                (SELECT NULL
                                   FROM amd_l67_source
                                  WHERE     doc_no = als.doc_no
                                        AND nsn = als.nsn
                                        AND tric = 'DOC'))
                     OR (    tric NOT IN ('TRN', 'TIN')
                         AND NOT EXISTS
                                (SELECT NULL
                                   FROM amd_l67_source
                                  WHERE     tric IN ('TIN', 'TRN')
                                        AND doc_no = als.doc_no
                                        AND nsn IN
                                               (SELECT old_nsn
                                                  FROM amd_rbl_pairs
                                                 WHERE new_nsn = p.new_nsn))))
         UNION
         SELECT DISTINCT als.nsn,
                         mmc,
                         erc,
                         tric,
                         ttpc,
                         dmd_cd,
                         reason,
                         als.doc_no,
                         trans_date,
                         trans_ser,
                         action_qty,
                         DECODE (asn.loc_type, 'TMP', asn.mob, sran) sran,
                         nomenclature,
                         marked_for,
                         dold,
                         supp_address
           FROM AMD_L67_SOURCE als, AMD_SPARE_NETWORKS asn
          WHERE     SUBSTR (als.doc_no, 1, 1) IN ('X',
                                                  'S',
                                                  'B',
                                                  'J',
                                                  'R')
                AND SUBSTR (als.doc_no, 1, 4) <> 'S005'
                AND als.sran = asn.loc_id
                AND amd_utils.formatNsn (als.nsn) NOT IN
                       (SELECT old_nsn
                          FROM amd_rbl_pairs);

      nsn        VARCHAR2 (20);
      mmacCode   NUMBER;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_lcf_icp',
         pError_location   => 10,
         pKey1             => 'InsertL67TmpLcfIcp',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR rec IN l67Cur
      LOOP
         BEGIN
            mmacCode := rec.mmc;
            nsn := rec.nsn || rec.mmc;
         EXCEPTION
            WHEN OTHERS
            THEN
               nsn := rec.nsn;
         END;

         INSERT INTO TMP_LCF_ICP (nsn,
                                  mmc,
                                  stock_no,
                                  erc,
                                  dic,
                                  ttpc,
                                  dmd_cd,
                                  reason,
                                  doc_no,
                                  trans_date,
                                  trans_ser,
                                  action_qty,
                                  sran,
                                  nomenclature,
                                  marked_for,
                                  date_of_last_demand,
                                  supplemental_address)
              VALUES (nsn,
                      rec.mmc,
                      nsn,
                      rec.erc,
                      rec.tric,
                      rec.ttpc,
                      rec.dmd_cd,
                      rec.reason,
                      rec.doc_no,
                      rec.trans_date,
                      rec.trans_ser,
                      rec.action_qty,
                      rec.sran,
                      rec.nomenclature,
                      rec.marked_for,
                      rec.dold,
                      rec.supp_address);
      END LOOP;

      COMMIT;
      writeMsg (
         pTableName        => 'tmp_lcf_icp',
         pError_location   => 20,
         pKey1             => 'InsertL67TmpLcfIcp',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   END;



   --
   -- loadAmdBssmSourceTmpAmdDemands -
   --
   -- procedure to load amd_af_reqs from lcf data.
   --
   -- currently, we manually load lcf data into tmp_lcf_raw, tmp_lcf_1,
   -- tmp_lcf_icp tables manually.  we do not know at this time how we would
   -- receive the lcf data in the future.
   --
   -- assume we have data loaded into tmp_lcf_icp, the follows are processes
   -- to be perform to load data into amd_af_reqs table.
   --
   -- 1) loop for each doc_no.
   -- 2) for each doc_no:
   --     2.1) select sum of qualified tin into goodtin
   --     2.2) select sum of non-qualified tin into badtin
   --     2.3) select sum of qualified trn into goodtrn
   --     2.4) select sum of non-qualified trn into badtrn
   --     2.5) calculate tin quantity:
   --                         tinqty = goodtin + goodtrn
   --     2.6) calculate badtin quantity:
   --             badtinqty = badtin + badtrn
   -- 2.7) select sum of qualified isu
   -- 2.8) select sum of qualified msi
   -- 2.9) select sum of qualified duo
   -- 2.10)select sum of qualified doc
   -- 2.11)calculate duo quantity:
   --             duoqty = duo - doc.
   --           note: if duoqty is negative, set duoqty = 0.
   -- 2.12)calculate non tin quantity:
   --             ntinqty = isu + msi + duoqty - badtinqty
   --     2.13)calculate other quantity:
   --             otherqty = ntinqty - tinqty
   -- 2.14)calculate requisition quantity:
   --                 if otherqty > 0 then
   --                             qty        = tinqty + otherqty
   --                    else
   --                      qty        = tinqty
   --                    end if
   --    2.15) if the qty = 0, do not insert the requisition.
   --
   -- 3) select nsn of the doc_no and select prime part from amd_spare_parts
   -- 4) use trans_date as requistion_date
   -- 5) insert into amd_demands table.
   --
   PROCEDURE loadAmdBssmSourceTmpAmdDemands
   IS
      vNsn                VARCHAR2 (20);
      tinqty              NUMBER := 0;
      ntinqty             NUMBER := 0;
      otherqty            NUMBER := 0;
      qty                 NUMBER := 0;
      goodtin             NUMBER := 0;
      badtin              NUMBER := 0;
      goodtrn             NUMBER := 0;
      badtrn              NUMBER := 0;
      badtinqty           NUMBER := 0;
      isu                 NUMBER := 0;
      msi                 NUMBER := 0;
      duo                 NUMBER := 0;
      doc                 NUMBER := 0;
      duoqty              NUMBER := 0;
      reqDate             DATE;
      lcf1cnt             NUMBER;
      nsiSid              NUMBER;
      dup_cnt             NUMBER := 0;
      load_cnt            NUMBER := 0;
      rows_read           NUMBER := 0;
      nsiSidNotFoundCnt   NUMBER := 0;
      CRLF       CONSTANT CHAR (2) := CHR (13) || CHR (10);

      CURSOR docCur
      IS
           SELECT tli.doc_no,
                  asn.loc_sid,
                  amd_utils.formatNsn (TLI.NSN) nsn,
                  MIN (tli.trans_date) trans_date
             FROM TMP_LCF_ICP tli, AMD_SPARE_NETWORKS asn
            WHERE tli.sran = asn.loc_id AND SUBSTR (tli.doc_no, 1, 4) <> 'S005'
         -- and  not exists (select null from amd_rbl_pairs where tli.nsn = old_nsn and old_nsn = new_nsn)
         GROUP BY tli.doc_no, asn.loc_sid, amd_utils.formatNsn (tli.nsn);
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_demands',
         pError_location   => 30,
         pKey1             => 'loadAmdBssmSourceTmpAmdDemands',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));


      --
      -- if there are no records in tmp_lcf_1 then
      -- insert them from tmp_lcf_raw
      --
      SELECT COUNT (*) INTO lcf1cnt FROM TMP_LCF_1;

      IF (lcf1cnt = 0)
      THEN
         InsertTmpLcf1;
      END IF;

      InsertTmpLcfIcp; --* limits locations to the ones specified in amd_spare_networks
      InsertL67TmpLcfIcp;

      FOR rec IN docCur
      LOOP
         rows_read := rows_read + 1;
         goodtin := CalcQuantity (rec.doc_no, rec.nsn, 'TIN');
         badtin := CalcBadQuantity (rec.doc_no, rec.nsn, 'TIN');
         goodtrn := CalcQuantity (rec.doc_no, rec.nsn, 'TRN');
         badtrn := CalcBadQuantity (rec.doc_no, rec.nsn, 'TRN');
         tinqty := goodtin + goodtrn;
         badtinqty := badtin + badtrn;

         isu := CalcQuantity (rec.doc_no, rec.nsn, 'ISU');
         msi := CalcQuantity (rec.doc_no, rec.nsn, 'MSI');
         duo := CalcQuantity (rec.doc_no, rec.nsn, 'DUO');
         doc := CalcQuantity (rec.doc_no, rec.nsn, 'DOC');

         duoqty := duo - doc;

         IF duoqty < 0
         THEN
            duoqty := 0;
         END IF;

         ntinqty := isu + msi + duoqty - badtinqty;
         otherqty := ntinqty - tinqty;

         IF otherqty > 0
         THEN
            qty := tinqty + otherqty;
         ELSE
            qty := tinqty;
         END IF;

         IF qty != 0
         THEN
            IF rec.doc_no = 'X317SA73191200'
            THEN
               DBMS_OUTPUT.put_line (
                     'doc_no: '
                  || rec.doc_no
                  || CRLF
                  || repeat (' ', 2)
                  || 'rec.nsn: '
                  || rec.nsn
                  || CRLF
                  || repeat (' ', 2)
                  || 'rows_read: '
                  || rows_read
                  || CRLF
                  || repeat (' ', 2)
                  || 'goodtin: '
                  || goodtin
                  || CRLF
                  || repeat (' ', 2)
                  || 'badtin: '
                  || badtin
                  || CRLF
                  || repeat (' ', 2)
                  || 'goodtrn: '
                  || goodtrn
                  || CRLF
                  || repeat (' ', 2)
                  || 'badtrn:  '
                  || badtrn
                  || CRLF
                  || repeat (' ', 2)
                  || 'tinqty: '
                  || tinqty
                  || CRLF
                  || repeat (' ', 2)
                  || 'badtinqty: '
                  || badtinqty
                  || CRLF
                  || repeat (' ', 2)
                  || 'isu: '
                  || isu
                  || CRLF
                  || repeat (' ', 2)
                  || 'msi: '
                  || msi
                  || CRLF
                  || repeat (' ', 2)
                  || 'duo: '
                  || duo
                  || CRLF
                  || repeat (' ', 2)
                  || 'doc: '
                  || doc
                  || CRLF
                  || repeat (' ', 2)
                  || 'duoqty: '
                  || duoqty
                  || CRLF
                  || repeat (' ', 2)
                  || 'ntinqty: '
                  || ntinqty
                  || CRLF
                  || repeat (' ', 2)
                  || 'otherqty: '
                  || otherqty
                  || CRLF
                  || repeat (' ', 2)
                  || 'qty: '
                  || qty
                  || CRLF);
            END IF;


            --
            --  Get the NSN to use for BSSM
            --
            IF tinqty > 0
            THEN
               SELECT MAX (nsn)
                 INTO vNsn
                 FROM TMP_LCF_ICP
                WHERE doc_no = rec.doc_no AND dic IN ('TIN', 'TRN');
            ELSE
               SELECT MAX (nsn)
                 INTO vNsn
                 FROM TMP_LCF_ICP
                WHERE doc_no = rec.doc_no AND dic NOT IN ('TIN', 'TRN');
            END IF;


            IF (vNsn IS NOT NULL)
            THEN
               reqDate := rec.trans_date;

              <<getNsiSid>>
               BEGIN
                  nsiSid := Amd_Utils.GetNsiSid (pNsn => rec.nsn);

                  IF rec.doc_no = 'X317SA73191200'
                  THEN
                     DBMS_OUTPUT.put_line (
                           'doc_no: '
                        || rec.doc_no
                        || ' Nsn: '
                        || vNsn
                        || ' rec.nsn: '
                        || rec.nsn
                        || ' (nsisid '
                        || nsiSid
                        || ') qty: '
                        || qty);
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     nsiSidNotFoundCnt := nsiSidNotFoundCnt + 1;

                     IF debug
                     THEN
                        writeMsg (
                           pTableName        => 'tmp_amd_denads',
                           pError_location   => 40,
                           pKey1             => 'loadAmdBssmSourceTmpAmdDemands',
                           pKey2             =>    'Nsn '
                                                || vNsn
                                                || ' no nsi_sid found',
                           pKey3             => 'doc_no: ' || rec.doc_no);
                     END IF;

                     CONTINUE;
                  WHEN OTHERS
                  THEN
                     IF SQLCODE = -20000
                     THEN
                        DBMS_OUTPUT.DISABLE ();
                        CONTINUE;
                     ELSE
                        DBMS_OUTPUT.put_line (
                              'getNsiSid: sqlcode='
                           || SQLCODE
                           || ' sqlerrm='
                           || SQLERRM);
                        RAISE;
                     END IF;
               END getNsiSid;

               --
               -- send data to bssm table for extract to bssm
               --
               INSERT INTO amd_bssm_source (requisition_no,
                                            requisition_date,
                                            quantity,
                                            loc_sid,
                                            nsn,
                                            action_code)
                    VALUES (rec.doc_no,
                            reqDate,
                            qty,
                            rec.loc_sid,
                            rec.nsn,
                            AMD_DEFAULTS.INSERT_ACTION);

               BEGIN
                  INSERT INTO tmp_amd_demands (doc_no,
                                               doc_date,
                                               nsi_sid,
                                               loc_sid,
                                               quantity,
                                               action_code,
                                               last_update_dt)
                       VALUES (rec.doc_no,
                               reqDate,
                               nsiSid,
                               rec.loc_sid,
                               qty,
                               Amd_Defaults.INSERT_ACTION,
                               SYSDATE);

                  load_cnt := load_cnt + 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;     -- nsiSid not found generates this, just ignore
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     dup_cnt := dup_cnt + 1;
                     errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                               tableName         => 'tmp_amd_demands',
                               pError_Location   => 50,
                               key1              => rec.doc_no,
                               key2              => rec.loc_sid,
                               key3              => qty,
                               key4              => dup_cnt,
                               key5              => rows_read);
               END;
            END IF;
         END IF;
      END LOOP;

      writeMsg (
         pTableName        => 'tmp_amd_denads',
         pError_location   => 60,
         pKey1             => 'loadAmdBssmSourceTmpAmdDemands',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             =>    rows_read
                              || ' row(s) read '
                              || load_cnt
                              || ' row(s) loaded '
                              || dup_cnt
                              || ' duplicate(s)',
         pkey4             => 'nsi_sid not found count ' || nsiSidNotFoundCnt);

      DBMS_OUTPUT.put_line (
            'loadAmdBssmSourceTmpAmdDemands: '
         || rows_read
         || ' row(s) read '
         || load_cnt
         || ' row(s) loaded '
         || dup_cnt
         || ' duplicate(s)'
         || ' nsi_sid not found count '
         || nsiSidNotFoundCnt);

      IF nsiSidNotFoundCnt > 0 AND doWarnings
      THEN
         amd_warnings_pkg.insertWarningMsg (
            pData_line_no   => 77,
            pData_line      => 'loadAmdBssmSourceTmpAmdDemands',
            pWarning        =>    'nsi_sid not found cnt: '
                               || nsiSidNotFoundCnt
                               || ' select * from amd_load_details where data_line = ''amd_demand'' and key_2 like ''Nsn''');
      END IF;
   END loadAmdBssmSourceTmpAmdDemands;


   PROCEDURE LoadFmsDemands
   IS
      load_cnt    NUMBER := 0;
      dup_cnt     NUMBER := 0;
      rows_read   NUMBER := 0;

      CURSOR demandCur
      IS
         SELECT DISTINCT asp.nsn nsn,
                         t.tran_id tran_id,
                         t.created_datetime created_datetime,
                         (NVL (t.qty, 0)) quantity,
                         asn2.loc_sid loc_sid,
                         t.loc_id sc,
                         t.part part
           FROM TRHI t,
                amd_spare_parts asp,
                amd_spare_networks asn1,
                amd_spare_networks asn2
          WHERE     asp.part_no = t.part
                AND asp.action_code != 'D'
                AND (NVL (t.qty, 0)) != 0
                AND (   asn1.loc_id = t.loc_id
                     OR (EXISTS
                            (SELECT NULL
                               FROM amd_sc_inclusions
                              WHERE SUBSTR (t.sc, START_LOC_ID, 7) =
                                       SUBSTR (include_sc, START_LOC_ID, 7))))
                AND asn1.mob = asn2.loc_id(+)
                AND asn1.loc_type = 'FMS'
                AND asn2.loc_sid IS NOT NULL;

      nsiSid      NUMBER;
      nsnAmd      VARCHAR2 (20);
   BEGIN
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 70,
         pKey1             => 'LoadFmsDemands',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));


      FOR rec IN demandCur
      LOOP
         rows_read := rows_read + 1;
         nsnAmd := Amd_Utils.FormatNsn (rec.nsn, 'AMD');

         INSERT INTO AMD_BSSM_SOURCE (requisition_no,
                                      requisition_date,
                                      quantity,
                                      loc_sid,
                                      nsn)
              VALUES (rec.tran_id,
                      rec.created_datetime,
                      rec.quantity,
                      rec.loc_sid,
                      nsnAmd);

         BEGIN
            nsiSid := Amd_Utils.GetNsiSid (pPart_no => rec.part);

            INSERT INTO TMP_AMD_DEMANDS (doc_no,
                                         doc_date,
                                         nsi_sid,
                                         loc_sid,
                                         quantity,
                                         action_code,
                                         last_update_dt)
                 VALUES (rec.tran_id,
                         rec.created_datetime,
                         nsiSid,
                         rec.loc_sid,
                         rec.quantity,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);

            load_cnt := load_cnt + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;           -- nsiSid not found generates this, just ignore
            WHEN DUP_VAL_ON_INDEX
            THEN
               dup_cnt := dup_cnt + 1;
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 80,
                         key1              => rec.tran_id,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => dup_cnt,
                         key5              => rows_read);
         END;
      END LOOP;

      DBMS_OUTPUT.put_line (
            'LoadFmsDemands: '
         || rows_read
         || ' row(s) read '
         || load_cnt
         || ' row(s) loaded '
         || dup_cnt
         || ' duplicate(s)');
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 90,
         pKey1             => 'LoadFmsDemands',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             =>    rows_read
                              || ' row(s) read '
                              || load_cnt
                              || ' row(s) loaded '
                              || dup_cnt
                              || ' duplicate(s)');
   END LoadFmsDemands;

   PROCEDURE loadSanAntonioDemands
   IS
      dup_cnt     NUMBER := 0;
      load_cnt    NUMBER := 0;
      rows_read   NUMBER := 0;

      --
      CURSOR sanAntonioDemands
      IS
         SELECT p.nsn,
                R.REQUEST_ID,
                r.created_datetime,
                (  NVL (r.QTY_RESERVED, 0)
                 + NVL (r.QTY_ISSUED, 0)
                 + NVL (r.QTY_DUE, 0))
                   quantity,
                amd_utils.getLocSid ('EY1746') loc_sid,
                r.prime,
                n.nsi_sid
           FROM Amd_spare_parts p,
                req1sa r,
                amd_national_stock_items n,
                cat1
          WHERE     p.part_no = r.select_from_part
                AND r.prime = cat1.part
                AND r.select_from_sc = 'SATCAA0001C17G'
                AND R.STATUS IN ('U',
                                 'H',
                                 'O',
                                 'R',
                                 'S')
                AND NVL (proc_code, 'GFP') = 'GFP'
                AND TO_CHAR (r.created_datetime, 'YYYY-MM') >= '2015-01'
                AND p.nsn = n.nsn
                AND n.action_code != 'D';

      nsiSid      NUMBER;
      nsnAmd      VARCHAR2 (20);
   BEGIN
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 100,
         pKey1             => 'loadSanAntonioDemands',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR rec IN sanAntonioDemands
      LOOP
         rows_read := rows_read + 1;

         INSERT INTO AMD_BSSM_SOURCE (requisition_no,
                                      requisition_date,
                                      quantity,
                                      loc_sid,
                                      nsn)
              VALUES (rec.request_id,
                      rec.created_datetime,
                      rec.quantity,
                      rec.loc_sid,
                      rec.nsn);

         BEGIN
            INSERT INTO TMP_AMD_DEMANDS (doc_no,
                                         doc_date,
                                         nsi_sid,
                                         loc_sid,
                                         quantity,
                                         action_code,
                                         last_update_dt)
                 VALUES (rec.request_id,
                         rec.created_datetime,
                         rec.nsi_sid,
                         rec.loc_sid,
                         rec.quantity,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);

            load_cnt := load_cnt + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;           -- nsiSid not found generates this, just ignore
            WHEN DUP_VAL_ON_INDEX
            THEN
               dup_cnt := dup_cnt + 1;
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 110,
                         key1              => rec.request_id,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => dup_cnt,
                         key5              => rows_read);
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 120,
                         key1              => rec.request_id,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => rec.prime,
                         key5              => rows_read);
         END;
      END LOOP;

      DBMS_OUTPUT.put_line (
            'loadSanAntonioDemands: '
         || rows_read
         || ' row(s) read '
         || load_cnt
         || ' row(s) loaded '
         || dup_cnt
         || ' duplicate(s)');
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 130,
         pKey1             => 'loadSanAntonioDemands',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             =>    rows_read
                              || ' row(s) read '
                              || load_cnt
                              || ' row(s) loaded '
                              || dup_cnt
                              || ' duplicate(s)');
   END loadSanAntonioDemands;

   PROCEDURE unloadWarnerRobinsDemands
   IS
      unload_cnt           NUMBER := 0;
      rows_read            NUMBER := 0;
      invalid_number_cnt   NUMBER := 0;
      bssm_deleted         NUMBER := 0;
      wr_updated           NUMBER := 0;


      --
      CURSOR warnerRobinsDemands
      IS
           SELECT items.nsn,
                  request_id,
                  created_datetime,
                  qty quantity,
                  amd_utils.getLocSid ('EY1746') loc_sid,
                  items.prime_part_no prime,
                  items.nsi_sid
             FROM (  SELECT wr.nsn nsn,
                            doc_no request_id,
                            MIN (transaction_date) created_datetime,
                            SUM (demand_quantity) qty
                       FROM amd_warner_robins_files wr, amd_nsns
                      WHERE     wr.nsn = amd_nsns.nsn
                            AND (   date_loaded_to_demands IS NOT NULL
                                 OR bad_nsn IS NOT NULL
                                 OR action_code IS NOT NULL)
                   GROUP BY wr.nsn, doc_no) wr_summed,
                  amd_nsns,
                  amd_national_stock_items items
            WHERE     wr_summed.nsn = amd_nsns.nsn
                  AND amd_nsns.nsi_sid = items.nsi_sid
         ORDER BY nsn, request_id;
   BEGIN
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 332,
         pKey1             => 'unloadWarnerRobinsDemands',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR rec IN warnerRobinsDemands
      LOOP
         rows_read := rows_read + 1;

         IF rows_read MOD 500 = 0
         THEN
            COMMIT;
         END IF;

        <<deleteAmdBssmSource>>
         BEGIN
            DELETE AMD_BSSM_SOURCE
             WHERE     requisition_no = rec.request_id
                   AND requisition_date = rec.created_datetime
                   AND quantity = rec.quantity
                   AND loc_sid = rec.loc_sid
                   AND nsn = rec.nsn;

            bssm_deleted := bssm_deleted + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END deleteAmdBssmSource;

         BEGIN
            DELETE TMP_AMD_DEMANDS
             WHERE     doc_no = rec.request_id
                   AND doc_date = rec.created_datetime
                   AND nsi_sid = rec.nsi_sid
                   AND loc_sid = rec.loc_sid
                   AND quantity = rec.quantity;

            unload_cnt := unload_cnt + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;           -- nsiSid not found generates this, just ignore
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 336,
                         key1              => rec.request_id,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => rec.prime,
                         key5              => rows_read);
         END;
      END LOOP;

     <<updateDateLoadedToDemands>>
      BEGIN
         UPDATE amd_warner_robins_files
            SET date_loaded_to_demands = NULL,
                bad_nsn = NULL,
                action_code = NULL
          WHERE    date_loaded_to_demands IS NOT NULL
                OR bad_nsn IS NOT NULL
                OR action_code IS NOT NULL;

         wr_updated := wr_updated + SQL%ROWCOUNT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN INVALID_NUMBER
         THEN
            invalid_number_cnt := invalid_number_cnt + 1;
            errorMsg (sqlFunction       => amd_defaults.UPDATE_ACTION,
                      tableName         => 'amd_warner_robins_files',
                      pError_Location   => 337,
                      key1              => unload_cnt);
      END updateDateLoadedToDemands;

      DBMS_OUTPUT.put_line (
            'unloadWarnerRobinsDemands: '
         || rows_read
         || ' row(s) read '
         || unload_cnt
         || ' row(s) unloaded '
         || bssm_deleted
         || ' bssm_deleted '
         || wr_updated
         || ' wr_updated ');
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 338,
         pKey1             => 'unloadWarnerRobinsDemands',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             =>    rows_read
                              || ' row(s) read '
                              || unload_cnt
                              || ' row(s) unloaded ');
   END unloadWarnerRobinsDemands;

   PROCEDURE loadWarnerRobinsDemands
   IS
      dup_cnt              NUMBER := 0;
      other_bssm           NUMBER := 0;
      load_cnt             NUMBER := 0;
      rows_read            NUMBER := 0;
      invalid_number_cnt   NUMBER := 0;
      other_demands        NUMBER := 0;
      wr_recs_updated      NUMBER := 0;
      fixed_nsn            NUMBER := 0;
      bad_nsn_cnt          NUMBER := 0;
      no_rows_to_process   NUMBER := 0;
      deleted_nsn_cnt      NUMBER := 0;
      fixed_action_code    NUMBER := 0;

      --
      CURSOR warnerRobinsDemands
      IS
         SELECT doc_no,
                loc_sid,
                nsi_sid,
                nsn,
                created_datetime,
                quantity,
                prime_part_no prime
           FROM amd_warner_robins_summed_v;
   BEGIN
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 132,
         pKey1             => 'loadWarnerRobinsDemands',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      -- check if any nsn's that were bad were fixed
      UPDATE amd_warner_robins_files wr
         SET bad_nsn = NULL
       WHERE     bad_nsn = 'Y'
             AND nsn IN (SELECT nsn
                           FROM amd_nsns
                          WHERE wr.nsn = nsn);

      fixed_nsn := fixed_nsn + SQL%ROWCOUNT;

      UPDATE amd_warner_robins_files wr
         SET action_code = NULL
       WHERE     action_code = 'D'
             AND nsn IN
                    (SELECT nsns.nsn
                       FROM amd_nsns nsns, amd_national_stock_items items
                      WHERE     wr.nsn = nsns.nsn
                            AND nsns.nsi_sid = items.nsi_sid
                            AND items.action_code <> 'D');

      fixed_action_code := fixed_action_code + SQL%ROWCOUNT;

      COMMIT;

      FOR rec IN warnerRobinsDemands
      LOOP
         rows_read := rows_read + 1;

         IF rows_read MOD 500 = 0
         THEN
            COMMIT;
         END IF;

        <<insertAmdBssmSource>>
         BEGIN
            INSERT INTO AMD_BSSM_SOURCE (requisition_no,
                                         requisition_date,
                                         quantity,
                                         loc_sid,
                                         nsn)
                 VALUES (rec.doc_no,
                         rec.created_datetime,
                         rec.quantity,
                         rec.loc_sid,
                         rec.nsn);
         EXCEPTION
            WHEN OTHERS
            THEN
               other_bssm := other_bssm + 1;
               DBMS_OUTPUT.put_line (
                  'amd_bssm_source: ' || SQLCODE || ' -ERROR- ' || SQLERRM);

               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'amd_bssm_source',
                         pError_Location   => 133,
                         key1              => rec.doc_no,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => other_bssm,
                         key5              => rows_read);
         END insertAmdBssmSource;

        <<insertTmpAmdDemands>>
         BEGIN
            INSERT INTO TMP_AMD_DEMANDS (doc_no,
                                         doc_date,
                                         nsi_sid,
                                         loc_sid,
                                         quantity,
                                         action_code,
                                         last_update_dt)
                 VALUES (rec.doc_no,
                         rec.created_datetime,
                         rec.nsi_sid,
                         rec.loc_sid,
                         rec.quantity,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);

            load_cnt := load_cnt + 1;

           <<updateAmdWarnerRobinsFiles>>
            BEGIN
               UPDATE amd_warner_robins_files
                  SET date_loaded_to_demands = SYSDATE, bad_nsn = NULL
                WHERE     nsn IN (SELECT nsn
                                    FROM amd_nsns
                                   WHERE nsi_sid = rec.nsi_sid)
                      AND doc_no = rec.doc_no
                      AND date_loaded_to_demands IS NULL;

               wr_recs_updated := wr_recs_updated + SQL%ROWCOUNT;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  no_rows_to_process := no_rows_to_process + 1;
               WHEN OTHERS
               THEN
                  errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                            tableName         => 'tmp_amd_demands',
                            pError_Location   => 135,
                            key1              => rec.doc_no,
                            key2              => rec.loc_sid,
                            key3              => rec.quantity,
                            key4              => rec.prime,
                            key5              => rows_read);
            END updateAmdWarnerRobinsFiles;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               dup_cnt := dup_cnt + 1;

               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 134,
                         key1              => rec.doc_no,
                         key2              => rec.nsn,
                         key3              => dup_cnt,
                         key4              => rows_read);
            WHEN OTHERS
            THEN
               other_demands := other_demands + 1;

               DBMS_OUTPUT.put_line (
                     'Error tmp_amd_demands: requestion_no '
                  || rec.doc_no
                  || ' nsn '
                  || rec.nsn
                  || ' sqlcode('
                  || SQLCODE
                  || ') sqlerrm('
                  || SQLERRM
                  || ')');
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 136,
                         key1              => rec.doc_no,
                         key2              => rec.nsn,
                         key3              => rec.quantity,
                         key4              => rec.prime,
                         key5              => rows_read);
         END;
      END LOOP;

     <<badNsn>>
      DECLARE
      BEGIN
         UPDATE amd_warner_robins_files wr
            SET bad_nsn = 'Y'
          WHERE     nsn NOT IN (SELECT nsn
                                  FROM amd_nsns
                                 WHERE wr.nsn = nsn)
                AND bad_nsn IS NULL;

         bad_nsn_cnt := bad_nsn_cnt + SQL%ROWCOUNT;
      END badNsn;

     <<deletedNsn>>
      DECLARE
      BEGIN
         UPDATE amd_warner_robins_files wr
            SET action_code = 'D'
          WHERE     nsn IN
                       (SELECT nsns.nsn
                          FROM amd_nsns nsns, amd_national_stock_items items
                         WHERE     wr.nsn = nsns.nsn
                               AND nsns.nsi_sid = items.nsi_sid
                               AND items.action_code = 'D')
                AND action_code IS NULL;

         deleted_nsn_cnt := deleted_nsn_cnt + SQL%ROWCOUNT;
      END deletedNsn;


      DBMS_OUTPUT.put_line (
            'loadWarnerRobinsDemands: '
         || rows_read
         || ' row(s) read '
         || load_cnt
         || ' row(s) loaded ');

      IF wr_recs_updated > 0
      THEN
         DBMS_OUTPUT.put_line ('rows processed: ' || wr_recs_updated);
      END IF;

      IF dup_cnt > 0
      THEN
         DBMS_OUTPUT.put_line (
            'tmp_amd_demands: ' || dup_cnt || ' duplicate(s)');
      END IF;

      IF bad_nsn_cnt > 0
      THEN
         DBMS_OUTPUT.put_line (
            'amd_warnerrobins_files: has ' || bad_nsn_cnt || ' bad nsns');
      END IF;

      IF deleted_nsn_cnt > 0
      THEN
         DBMS_OUTPUT.put_line (
               'amd_warnerrobine_files: has '
            || deleted_nsn_cnt
            || ' nsns that are flagged as DELETED');
      END IF;

      IF fixed_nsn > 0
      THEN
         DBMS_OUTPUT.put_line (
            'amd_warnerrobins_files: fixed ' || fixed_nsn || ' nsns fixed.');
      END IF;

      IF fixed_action_code > 0
      THEN
         DBMS_OUTPUT.put_line (
               'amd_warnerrobins_files: fixed '
            || fixed_action_code
            || ' flagged as deleted');
      END IF;

      IF no_rows_to_process > 0
      THEN
         DBMS_OUTPUT.put_line (
               'There were '
            || no_rows_to_process
            || ' records that were not processed');
      END IF;

      IF invalid_number_cnt > 0
      THEN
         DBMS_OUTPUT.put_line (
               'amd_warner_robins_files: update error '
            || invalid_number_cnt
            || ' invalid_number_cnt');
      END IF;

      IF other_bssm > 0
      THEN
         DBMS_OUTPUT.put_line (
            'amd_bssm_source: ' || other_bssm || ' category: other errors');
      END IF;

      IF other_demands > 0
      THEN
         DBMS_OUTPUT.put_line (
            'tmp_amd_demands: ' || other_demands || ' category: other errors');
      END IF;


      IF wr_recs_updated > 0
      THEN
         DBMS_OUTPUT.put_line (
               'amd_warner_robins_files: rows_updated with date_loaded_to_demands '
            || wr_recs_updated);
      END IF;

      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 138,
         pKey1             => 'loadWarnerRobinsDemands',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             =>    rows_read
                              || ' row(s) read '
                              || load_cnt
                              || ' row(s) loaded '
                              || wr_recs_updated
                              || ' recs_updated');
   END loadWarnerRobinsDemands;



   PROCEDURE LoadDepotDemands
   IS
      dup_cnt     NUMBER := 0;
      load_cnt    NUMBER := 0;
      rows_read   NUMBER := 0;

      CURSOR demandCur
      IS
           SELECT c.nsn,
                  r.request_id,
                  r.created_datetime,
                  (  NVL (r.qty_issued, 0)
                   + NVL (r.qty_due, 0)
                   + NVL (r.qty_reserved, 0))
                     quantity,
                  asn.loc_sid,
                  r.prime
             FROM REQ1 r,
                  CAT1 c,
                  amd_spare_networks asn,
                  amd_depot_partnering_locations depot
            WHERE     r.prime = c.part
                  AND NVL (r.nsn, 'null') <> 'null'
                  AND SUBSTR (r.request_id, 1, 6) = depot.loc_id
                  AND NOT (    SUBSTR (R.request_id, 1, 6) IN
                                  ('FB2065', 'EY1213', 'EY1746')
                           AND TRUNC (r.created_datetime, 'YEAR') >=
                                  TO_DATE ('01/01/2015', 'MM/DD/YYYY'))
                  AND SUBSTR (r.select_from_sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                  AND (  NVL (r.qty_issued, 0)
                       + NVL (r.qty_due, 0)
                       + NVL (r.qty_reserved, 0)) != 0
                  AND SUBSTR (request_id, 11, 1) != 'S'
                  AND r.status NOT IN ('X', 'C')
                  AND asn.loc_id = 'EY1746'
         ORDER BY 1;



      nsiSid      NUMBER;
      nsnAmd      VARCHAR2 (20);
   BEGIN
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 100,
         pKey1             => 'LoadDepotDemands',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      FOR rec IN demandCur
      LOOP
         rows_read := rows_read + 1;
         nsnAmd := Amd_Utils.FormatNsn (rec.nsn, 'AMD');

         INSERT INTO AMD_BSSM_SOURCE (requisition_no,
                                      requisition_date,
                                      quantity,
                                      loc_sid,
                                      nsn)
              VALUES (rec.request_id,
                      rec.created_datetime,
                      rec.quantity,
                      rec.loc_sid,
                      nsnAmd);

         BEGIN
            nsiSid := Amd_Utils.GetNsiSid (pPart_no => rec.prime);

            INSERT INTO TMP_AMD_DEMANDS (doc_no,
                                         doc_date,
                                         nsi_sid,
                                         loc_sid,
                                         quantity,
                                         action_code,
                                         last_update_dt)
                 VALUES (rec.request_id,
                         rec.created_datetime,
                         nsiSid,
                         rec.loc_sid,
                         rec.quantity,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);

            load_cnt := load_cnt + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;           -- nsiSid not found generates this, just ignore
            WHEN DUP_VAL_ON_INDEX
            THEN
               dup_cnt := dup_cnt + 1;
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 110,
                         key1              => rec.request_id,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => dup_cnt,
                         key5              => rows_read);
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction       => amd_defaults.INSERT_ACTION,
                         tableName         => 'tmp_amd_demands',
                         pError_Location   => 120,
                         key1              => rec.request_id,
                         key2              => rec.loc_sid,
                         key3              => rec.quantity,
                         key4              => rec.prime,
                         key5              => rows_read);
         END;
      END LOOP;

      DBMS_OUTPUT.put_line (
            'LoadDepotDemands: '
         || rows_read
         || ' row(s) read '
         || load_cnt
         || ' row(s) loaded '
         || dup_cnt
         || ' duplicate(s)');
      writeMsg (
         pTableName        => 'amd_bssm_source',
         pError_location   => 130,
         pKey1             => 'LoadDepotDemands',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             =>    rows_read
                              || ' row(s) read '
                              || load_cnt
                              || ' row(s) loaded '
                              || dup_cnt
                              || ' duplicate(s)');
   END LoadDepotDemands;

   PROCEDURE load_amd_demands_table
   IS
      CURSOR get_new_demands_cur
      IS
         SELECT doc_no,
                doc_date,
                doc_date_defaulted,
                nsi_sid,
                loc_sid,
                quantity,
                action_code,
                last_update_dt
           FROM TMP_AMD_DEMANDS a
          WHERE NOT EXISTS
                   (SELECT 'x'
                      FROM AMD_DEMANDS b
                     WHERE a.doc_no = b.doc_no AND a.loc_sid = b.loc_sid);
   BEGIN
      writeMsg (
         pTableName        => 'amd_demands',
         pError_location   => 140,
         pKey1             => 'load_amd_demands_table',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      DBMS_OUTPUT.put_line (
            'load_amd_demands_table: started at '
         || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      BEGIN
         MERGE INTO amd_demands tgt
              USING tmp_amd_demands src
                 ON (    SRC.DOC_NO = tgt.doc_no
                     AND SRC.LOC_SID = tgt.loc_sid
                     AND SRC.NSI_SID = tgt.nsi_sid)
         WHEN MATCHED
         THEN
            UPDATE SET tgt.doc_date = src.doc_date,
                       tgt.doc_date_defaulted = src.doc_date_defaulted,
                       tgt.quantity = src.quantity,
                       tgt.action_code = AMD_DEFAULTS.UPDATE_ACTION,
                       tgt.last_update_dt = SYSDATE
         WHEN NOT MATCHED
         THEN
            INSERT     (tgt.doc_no,
                        tgt.doc_date,
                        tgt.doc_date_defaulted,
                        tgt.nsi_sid,
                        tgt.loc_sid,
                        tgt.quantity,
                        tgt.action_code,
                        tgt.last_update_dt)
                VALUES (src.doc_no,
                        src.doc_date,
                        src.doc_date_defaulted,
                        src.nsi_sid,
                        src.loc_sid,
                        src.quantity,
                        AMD_DEFAULTS.INSERT_ACTION,
                        SYSDATE);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.put_line (
                  'load_amd_demands_table: 1 sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE_APPLICATION_ERROR (
               -20001,
               'no data found load_amd_demands_table proc for loc_id, amd_spare_networks');
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
                  'load_amd_demands_table: 1 sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE_APPLICATION_ERROR (
               -20001,
                  'OTHERS: load_amd_demands_table proc SQLERRM '
               || SQLERRM
               || ' SQLCODE '
               || SQLCODE);
      END;

      writeMsg (
         pTableName        => 'amd_demands',
         pError_location   => 150,
         pKey1             => 'load_amd_demands_table',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => SQL%ROWCOUNT || ' rows merged.');

      DBMS_OUTPUT.put_line (
            'load_amd_demands_table: ended at '
         || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM')
         || ' '
         || SQL%ROWCOUNT
         || ' rows merged');
   END load_amd_demands_table;

   PROCEDURE prime_part_change (
      old_part_no    AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE,
      new_part_no    AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE)
   AS
      CURSOR get_nsi_sid_cur (
         cv_prime_part_no    AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE)
      IS
         SELECT nsi_sid
           FROM AMD_NATIONAL_STOCK_ITEMS
          WHERE prime_part_no = cv_prime_part_no;

      CURSOR get_demands_cur (
         cv_nsi_sid    AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE)
      IS
         SELECT a.doc_no,
                a.doc_date,
                a.doc_date_defaulted,
                a.nsi_sid,
                b.spo_location, -- changed loc_id to spo_location . Thuy 2/16/06
                a.quantity,
                a.action_code,
                a.last_update_dt
           FROM AMD_DEMANDS a, AMD_SPARE_NETWORKS b
          WHERE a.nsi_sid = cv_nsi_sid AND a.loc_sid = b.loc_sid;
   BEGIN
      --  This iteration is for all the 'D' using the old_part_no being passed
      --  Then read them with the new_part_no being passed

      FOR get_nsi_sid_rec IN get_nsi_sid_cur (old_part_no)
      LOOP
         FOR get_demands_rec IN get_demands_cur (get_nsi_sid_rec.nsi_sid)
         LOOP
            NULL;
         END LOOP;
      END LOOP;
   END;

   FUNCTION getFiscalPeriod (aDate IN DATE)
      RETURN NUMBER
   IS
      the_year    NUMBER := TO_NUMBER (TO_CHAR (aDate, 'YYYY'));
      the_month   NUMBER := TO_NUMBER (TO_CHAR (aDate, 'MM'));
   BEGIN
      IF the_month <= 9
      THEN
         RETURN TO_NUMBER (the_year);
      ELSE
         RETURN TO_NUMBER (the_year) + 1;
      END IF;
   END getFiscalPeriod;

   FUNCTION getCalendarDate (period IN NUMBER)
      RETURN DATE
   IS
      cur_year        NUMBER := TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY'));
      cur_month       NUMBER := TO_NUMBER (TO_CHAR (SYSDATE, 'MM'));
      calendar_date   DATE := NULL;   -- return null if the period has expired
   BEGIN
      IF period = cur_year
      THEN
         IF cur_month <= 9
         THEN
            calendar_date :=
               TO_DATE (TO_CHAR (cur_month) || '/01/' || TO_CHAR (cur_year),
                        'MM/DD/YYYY');
         ELSE
            NULL; -- do nothing since october starts a new fiscal year.  So, period has expired if cur_month >= 10
         END IF;
      ELSIF period > cur_year
      THEN
         IF cur_month < 10
         THEN
            calendar_date :=
               TO_DATE ('10/01/' || TO_CHAR (period - 1), 'MM/DD/YYYY');
         ELSE
            calendar_date :=
               TO_DATE (
                  TO_CHAR (cur_month) || '/01/' || TO_CHAR (period - 1),
                  'MM/DD/YYYY');
         END IF;
      END IF;

      RETURN calendar_date;
   END getCalendarDate;

   FUNCTION doDmndFrcstConsumablesDiff (nsn               IN VARCHAR2,
                                        sran              IN VARCHAR2,
                                        period            IN NUMBER,
                                        demand_forecast   IN NUMBER,
                                        duplicate         IN NUMBER,
                                        action_code       IN VARCHAR2)
      RETURN NUMBER
   IS
      PROCEDURE updateRow
      IS
      BEGIN
         UPDATE amd_dmnd_frcst_consumables
            SET demand_forecast = doDmndFrcstConsumablesDiff.demand_forecast,
                duplicate = doDmndFrcstConsumablesDiff.duplicate,
                action_code = doDmndFrcstConsumablesDiff.action_code,
                last_update_dt = SYSDATE
          WHERE     nsn = doDmndFrcstConsumablesDiff.nsn
                AND sran = doDmndFrcstConsumablesDiff.sran
                AND period = doDmndFrcstConsumablesDiff.period;
      END updateRow;

      PROCEDURE insertRow
      IS
      BEGIN
         INSERT INTO amd_dmnd_frcst_consumables (nsn,
                                                 sran,
                                                 period,
                                                 demand_forecast,
                                                 duplicate,
                                                 action_code)
              VALUES (nsn,
                      sran,
                      period,
                      demand_forecast,
                      duplicate,
                      action_code);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            updateRow;
      END insertRow;
   BEGIN
      IF action_code = amd_defaults.INSERT_ACTION
      THEN
         insertRow;
      ELSIF action_code = amd_defaults.UPDATE_ACTION
      THEN
         updateRow;
      ELSIF action_code = amd_defaults.DELETE_ACTION
      THEN
         updateRow;
      ELSE
         errorMsg (sqlFunction       => action_code,
                   tableName         => 'doDmndFrcstConsumables',
                   pError_Location   => 160,
                   key1              => nsn,
                   key2              => sran,
                   key3              => period);
         DBMS_OUTPUT.put_line (
               'doDmndFrcstConsumables: 1 action_code='
            || action_code
            || ' nsn='
            || nsn
            || ' period='
            || period
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE badActionCode;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => action_code,
                   tableName         => 'doDmndFrcstConsumables',
                   pError_Location   => 170,
                   key1              => nsn,
                   key2              => sran,
                   key3              => period);
         DBMS_OUTPUT.put_line (
               'doDmndFrcstConsumables: 2 action_code='
            || action_code
            || ' nsn='
            || nsn
            || ' period='
            || period
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END doDmndFrcstConsumablesDiff;

   PROCEDURE genDuplicateForConsumables
   IS
      TYPE demandTab IS TABLE OF tmp_amd_dmnd_frcst_consumables%ROWTYPE
         INDEX BY VARCHAR2 (23);

      demands                  demandTab;

      CURSOR demandsNotSame (
         the_current_period    NUMBER)
      IS
           SELECT CASE
                     WHEN TO_DATE ('10/01/' || TO_CHAR (period - 1),
                                   'MM/DD/YYYY') >= TRUNC (SYSDATE, 'Month')
                     THEN
                        MONTHS_BETWEEN (
                           TO_DATE ('09/01/' || period, 'MM/DD/YYYY'),
                           TO_DATE ('10/01/' || TO_CHAR (period - 1),
                                    'MM/DD/YYYY'))
                     WHEN SYSDATE <= TO_DATE ('09/01/' || period, 'MM/DD/YYYY')
                     THEN
                        MONTHS_BETWEEN (
                           TO_DATE ('09/01/' || period, 'MM/DD/YYYY'),
                           TRUNC (SYSDATE, 'Month'))
                     ELSE
                        0
                  END
                     calc_duplicate,
                  tmp.*
             FROM tmp_amd_dmnd_frcst_consumables tmp,
                  (  SELECT nsn, sran, COUNT (*)
                       FROM (  SELECT nsn,
                                      sran,
                                      demand_forecast,
                                      COUNT (period)
                                 FROM tmp_amd_dmnd_frcst_consumables
                                WHERE period >= the_current_period
                             GROUP BY nsn, sran, demand_forecast)
                   GROUP BY nsn, sran
                     HAVING COUNT (*) > 1) x
            WHERE     tmp.nsn = x.nsn
                  AND tmp.sran = x.sran
                  AND tmp.period >= the_current_period
         --and tmp.nsn = '1560013299845'
         --and tmp.sran = 'FB4400'
         ORDER BY tmp.nsn, tmp.sran, tmp.period;

      totDuplicates            NUMBER := 0;
      nsn                      tmp_amd_dmnd_frcst_consumables.nsn%TYPE;
      sran                     tmp_amd_dmnd_frcst_consumables.SRAN%TYPE;
      demand_forecast          tmp_amd_dmnd_frcst_consumables.demand_forecast%TYPE;
      period                   tmp_amd_dmnd_frcst_consumables.period%TYPE;
      dupValue                 NUMBER := 0;
      DUP_THRESHOLD   CONSTANT NUMBER := 66;
      cur_period               NUMBER := getFiscalPeriod (SYSDATE);

      PROCEDURE doUpdate (nsn      IN VARCHAR2,
                          sran     IN VARCHAR2,
                          period   IN NUMBER)
      IS
      BEGIN
         UPDATE tmp_amd_dmnd_frcst_consumables
            SET duplicate = dupValue
          WHERE     nsn = doUpdate.nsn
                AND sran = doUpdate.sran
                AND period = doUpdate.period;

         IF totDuplicates + dupValue > DUP_THRESHOLD
         THEN
            totDuplicates := DUP_THRESHOLD;
         ELSE
            totDuplicates := totDuplicates + dupValue;
         END IF;
      END doUpdate;
   BEGIN
      FOR rec IN demandsNotSame (cur_period)
      LOOP
         IF nsn IS NULL
         THEN
            nsn := rec.nsn;
            sran := rec.sran;
            demand_forecast := rec.demand_forecast;
            period := rec.period;
         END IF;

         IF nsn || sran <> rec.nsn || rec.sran
         THEN
            IF dupValue > 0
            THEN
               doUpdate (nsn, sran, period);
            END IF;

            totDuplicates := 0;
            dupValue := 0;
            nsn := rec.nsn;
            sran := rec.sran;
            period := rec.period;
            demand_forecast := rec.demand_forecast;
         END IF;

         IF demand_forecast <> rec.demand_forecast
         THEN
            IF dupValue > 0
            THEN
               doUpdate (nsn, sran, period);
            END IF;

            dupValue := 0;
            period := rec.period;
            demand_forecast := rec.demand_forecast;
         END IF;

         IF totDuplicates + dupValue + rec.calc_duplicate + 1 > DUP_THRESHOLD
         THEN
            dupValue := DUP_THRESHOLD - totDuplicates;
         ELSE
            dupValue := dupValue + rec.calc_duplicate + 1;
         END IF;
      END LOOP;

      IF dupValue > 0
      THEN
         doUpdate (nsn, sran, period);
      END IF;

      UPDATE tmp_amd_dmnd_frcst_consumables a
         SET duplicate = DUP_THRESHOLD
       WHERE duplicate IS NULL AND period = cur_period;

      COMMIT;
   END genDuplicateForConsumables;

   FUNCTION getDoWarningsYorN
      RETURN VARCHAR2
   IS
   BEGIN
      IF doWarnings
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getDoWarningsYorN;

   PROCEDURE setDoWarnings (switch VARCHAR2)
   IS
   BEGIN
      doWarnings :=
         UPPER (switch) IN ('Y',
                            'T',
                            'YES',
                            'TRUE');
   END setDoWarnings;

   FUNCTION getDebugYorN
      RETURN VARCHAR2
   IS
   BEGIN
      IF debug
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getDebugYorN;

   PROCEDURE setDebug (switch IN VARCHAR2)
   IS
   BEGIN
      debug :=
         UPPER (switch) IN ('Y',
                            'T',
                            'YES',
                            'TRUE');

      IF debug
      THEN
         DBMS_OUTPUT.ENABLE (100000);
      ELSE
         DBMS_OUTPUT.DISABLE;
      END IF;
   END setDebug;


   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_demand',
                pError_location   => 180,
                pKey1             => 'amd_demand',
                pKey2             => '$Revision:   1.58');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.58';
   END getVersion;
END Amd_Demand;
/