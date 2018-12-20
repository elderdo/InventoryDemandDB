DROP PACKAGE AMD_OWNER.AMD_PART_FACTORS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_FACTORS_PKG
AS
   /*
        $Author: Douglas S. Elder
   $Revision:   1.9
          $Date:   16 May 2017
      $Workfile:   AMD_PART_FACTORS_PKG.pks  $

          Rev 1.9 16 May 2017 used the old deleteRow long param list to be compatible with the current Java
          separately
          
          Rev 1.8 02 Jul 2016 made LoadTmpAmdPartFactorsByLocType public so it can be executed and tested
          separately

          Rev 1.7 fixed deleteRow - only needs the key to amd_part_factors

  /*      Rev 1.6   02 Jul 2009 13:14:00   zf297a
  /*   Added type mtd_rec and interfaces for convertMtdToDataSys
  /*   and getCapabilityLevel
  /*
  /*      Rev 1.5   24 Feb 2009 13:46:12   zf297a
  /*   Removed a2a code.
  /*
  /*      Rev 1.4   13 Jan 2009 15:28:20   zf297a
  /*   Define an exception to be used for maintenance task distribution calculations.
  /*   Defined interfaces setDebug, getDebug, and getVersion.
  /*
  /*      Rev 1.3   Jun 09 2006 12:02:52   zf297a
  /*   added interface version
  /*
  /*      Rev 1.2   Jan 03 2006 13:03:18   zf297a
  /*   Added date range to procedure loadA2AByDate
  /*
  /*      Rev 1.1   Jan 03 2006 08:07:42   zf297a
  /*   Added procedure loadA2AByDate
  /*
  /*      Rev 1.0   Oct 31 2005 08:04:54   zf297a
  /*   Initial revision.
  */



   TYPE mtd_rec IS RECORD
   (
      rts       NUMBER,
      nrts      NUMBER,
      condemn   NUMBER
   );

   maint_task_distrib_exception              EXCEPTION;
   DEFAULT_WHSE_COND                CONSTANT NUMBER := .005;
   CRITICALITY_REPAIRABLE_DEFAULT   CONSTANT amd_national_stock_items.criticality%TYPE
      := .5 ;
   --  consumable not defined yet, placeholder for when defined
   CRITICALITY_CONSUMABLE_DEFAULT   CONSTANT amd_national_stock_items.criticality%TYPE
      := 0 ;

   -- calcs done to 4 decimal places
   DP                               CONSTANT NUMBER := 4;
   COMMITAFTER                      CONSTANT NUMBER := 100000;
   SUCCESS                          CONSTANT NUMBER := 0;
   FAILURE                          CONSTANT NUMBER := 4;



   PROCEDURE LoadTmpAmdPartFactors;

   PROCEDURE LoadInitial;



   /* current spec says to send a auto default nrts, rts, cond to vub, vcd, basc,
      others - mob, fsl, ctlatl, uk will use #'s from best spares.
      Below function will have to be maintained at this point for which
      locations are autodefaulted and which are not */
   FUNCTION IsAutoDefaulted (pLocRow amd_spare_networks%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION InsertRow (
      pPartNo                amd_part_factors.part_no%TYPE,
      pLocSid                amd_part_factors.loc_sid%TYPE,
      pPassUpRate            amd_part_factors.pass_up_rate%TYPE,
      pRts                   amd_part_factors.rts%TYPE,
      pCmdmdRate             amd_part_factors.cmdmd_rate%TYPE,
      pCriticality           amd_national_stock_items.criticality%TYPE,
      pCriticalityChanged    amd_national_stock_items.criticality_changed%TYPE,
      pCriticalityCleaned    amd_national_stock_items.criticality_cleaned%TYPE)
      RETURN NUMBER;

   FUNCTION UpdateRow (
      pPartNo                amd_part_factors.part_no%TYPE,
      pLocSid                amd_part_factors.loc_sid%TYPE,
      pPassUpRate            amd_part_factors.pass_up_rate%TYPE,
      pRts                   amd_part_factors.rts%TYPE,
      pCmdmdRate             amd_part_factors.cmdmd_rate%TYPE,
      pCriticality           amd_national_stock_items.criticality%TYPE,
      pCriticalityChanged    amd_national_stock_items.criticality_changed%TYPE,
      pCriticalityCleaned    amd_national_stock_items.criticality_cleaned%TYPE)
      RETURN NUMBER;


   FUNCTION DeleteRow (pPartNo    amd_part_factors.part_no%TYPE,
                       pLocSid    amd_part_factors.loc_sid%TYPE)
      RETURN NUMBER;

   FUNCTION DeleteRow (
      pPartNo                amd_part_factors.part_no%TYPE,
      pLocSid                amd_part_factors.loc_sid%TYPE,
      pPassUpRate            amd_part_factors.pass_up_rate%TYPE,
      pRts                   amd_part_factors.rts%TYPE,
      pCmdmdRate             amd_part_factors.cmdmd_rate%TYPE,
      pCriticality           amd_national_stock_items.criticality%TYPE,
      pCriticalityChanged    amd_national_stock_items.criticality_changed%TYPE,
      pCriticalityCleaned    amd_national_stock_items.criticality_cleaned%TYPE)
      RETURN NUMBER;

   FUNCTION GetRepairIndicator (pNsn        bssm_base_parts.nsn%TYPE,
                                pSran       bssm_base_parts.sran%TYPE,
                                pLockSid    bssm_locks.LOCK_SID%TYPE)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (GetRepairIndicator, WNDS);

   -- added 6/9/2006 by dse
   PROCEDURE version;

   PROCEDURE setDebug (VALUE IN VARCHAR2);

   FUNCTION getDebug
      RETURN VARCHAR2;

   FUNCTION getVersion
      RETURN VARCHAR2;

   FUNCTION ConvertMtdToDataSys (pLocId              amd_spare_networks.LOC_ID%TYPE,
                                 pCapabilityLevel    VARCHAR2,
                                 pRepairInd          VARCHAR2,
                                 pNrts               NUMBER,
                                 pRts                NUMBER,
                                 pCondemn            NUMBER)
      RETURN mtd_rec;

   FUNCTION GetCapabilityLevel (pLocId amd_spare_networks.loc_id%TYPE)
      RETURN bssm_bases.capabilty_level%TYPE;

   FUNCTION LoadTmpAmdPartFactorsByLocType (
      pLocType   IN amd_spare_networks.loc_type%TYPE)
      RETURN NUMBER;
END AMD_PART_FACTORS_PKG;
/


DROP PUBLIC SYNONYM AMD_PART_FACTORS_PKG;

CREATE PUBLIC SYNONYM AMD_PART_FACTORS_PKG FOR AMD_OWNER.AMD_PART_FACTORS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_FACTORS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_FACTORS_PKG TO AMD_WRITER_ROLE;
