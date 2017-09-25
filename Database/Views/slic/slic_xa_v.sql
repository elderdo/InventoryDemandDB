DROP VIEW AMD_OWNER.SLIC_XA_V;

/* Formatted on 7/9/2012 4:34:57 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_XA_V
(
   DBKEY,
   UPDTCNT,
   BCKP,
   CAN_INT,
   UPDTCD,
   EIACODXA,
   LCNSTRXA,
   ADDLTMXA,
   CTDLTMXA,
   CONTNOXA,
   CSREORXA,
   CSPRRQXA,
   DEMILCXA,
   DISCNTXA,
   ESSALVXA,
   HLCSPCXA,
   INTBINXA,
   INCATCXA,
   INTRATXA,
   INVSTGXA,
   LODFACXA,
   WSOPLVXA,
   OPRLIFXA,
   PRSTOVXA,
   PRSTOMXA,
   PROFACXA,
   RCBINCXA,
   RCCATCXA,
   RESTCRXA,
   SAFLVLXA,
   SECSFCXA,
   TRNCSTXA,
   WSTYAQXA,
   TSSCODXA,
   EXT_EIAC_ID
)
AS
   SELECT "DBKEY",
          "UPDTCNT",
          "BCKP",
          "CAN_INT",
          "UPDTCD",
          "EIACODXA",
          "LCNSTRXA",
          "ADDLTMXA",
          "CTDLTMXA",
          "CONTNOXA",
          "CSREORXA",
          "CSPRRQXA",
          "DEMILCXA",
          "DISCNTXA",
          "ESSALVXA",
          "HLCSPCXA",
          "INTBINXA",
          "INCATCXA",
          "INTRATXA",
          "INVSTGXA",
          "LODFACXA",
          "WSOPLVXA",
          "OPRLIFXA",
          "PRSTOVXA",
          "PRSTOMXA",
          "PROFACXA",
          "RCBINCXA",
          "RCCATCXA",
          "RESTCRXA",
          "SAFLVLXA",
          "SECSFCXA",
          "TRNCSTXA",
          "WSTYAQXA",
          "TSSCODXA",
          "EXT_EIAC_ID"
     FROM pslms_xa@amd_pslms_link.boeingdb;


DROP PUBLIC SYNONYM SLIC_XA_V;

CREATE OR REPLACE PUBLIC SYNONYM SLIC_XA_V FOR AMD_OWNER.SLIC_XA_V;


GRANT SELECT ON AMD_OWNER.SLIC_XA_V TO AMD_READER_ROLE;

GRANT SELECT ON AMD_OWNER.SLIC_XA_V TO BSRM_LOADER;
