    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:54:02  $
     $Workfile:   tmp_lcf_raw.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_lcf_raw.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:54:02   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_LCF_RAW
(
  F_PRE                 VARCHAR2(30 BYTE),
  F_LS                  VARCHAR2(30 BYTE),
  STOCK_NO              VARCHAR2(20 BYTE),
  F_SD                  VARCHAR2(30 BYTE),
  F_TS                  VARCHAR2(30 BYTE),
  ERC                   VARCHAR2(4 BYTE),
  F_SPC                 VARCHAR2(30 BYTE),
  F_IP                  VARCHAR2(30 BYTE),
  F_TX                  VARCHAR2(30 BYTE),
  DMD_CD                VARCHAR2(4 BYTE),
  DIC                   VARCHAR2(6 BYTE),
  TTPC                  VARCHAR2(6 BYTE),
  TRANS_DATE            VARCHAR2(10 BYTE),
  TRANS_SER             VARCHAR2(10 BYTE),
  UNIT_OF_ISSUE         VARCHAR2(2 BYTE),
  F_FUND_CD             VARCHAR2(30 BYTE),
  SUPPLEMENTAL_ADDRESS  VARCHAR2(6 BYTE),
  F_RID                 VARCHAR2(30 BYTE),
  DOC_NO                VARCHAR2(20 BYTE),
  F_DOLD                VARCHAR2(30 BYTE),
  F_ENDING_BAL          VARCHAR2(30 BYTE),
  F_FIA                 VARCHAR2(30 BYTE),
  ACTION_QTY            NUMBER,
  F_EXTENDED_COST       VARCHAR2(30 BYTE),
  F_FLR4                VARCHAR2(30 BYTE),
  DATE_OF_LAST_DEMAND   VARCHAR2(10 BYTE),
  F_ADVICE_CODE         VARCHAR2(30 BYTE),
  F_FLR1                VARCHAR2(30 BYTE),
  F_TERM_OPUT           VARCHAR2(30 BYTE),
  F_SOS_CD              VARCHAR2(30 BYTE),
  F_PF                  VARCHAR2(30 BYTE),
  F_BC                  VARCHAR2(30 BYTE),
  MARKED_FOR            VARCHAR2(14 BYTE),
  F_NSN_REQ             VARCHAR2(30 BYTE),
  NOMENCLATURE          VARCHAR2(32 BYTE),
  F_CAGE                VARCHAR2(30 BYTE),
  REASON                VARCHAR2(30 BYTE),
  F_DF                  VARCHAR2(30 BYTE),
  F_FILLER2             VARCHAR2(30 BYTE),
  F_IX                  VARCHAR2(30 BYTE),
  F_CALC_KEY            VARCHAR2(30 BYTE),
  F_DRC_CLR             VARCHAR2(30 BYTE),
  F_FYOB                VARCHAR2(30 BYTE),
  F_EEIC                VARCHAR2(30 BYTE),
  F_ORIG                VARCHAR2(30 BYTE),
  F_USER_INIT           VARCHAR2(30 BYTE),
  F_MC                  VARCHAR2(30 BYTE),
  F_SRC_TRN             VARCHAR2(30 BYTE),
  F_RBL_FLG             VARCHAR2(30 BYTE),
  F_FLR3                VARCHAR2(30 BYTE),
  F_CSMS_FLAG           VARCHAR2(30 BYTE),
  F_AF_RAMPS            VARCHAR2(30 BYTE),
  F_MACR_DOLLAR         VARCHAR2(30 BYTE),
  F_MUC                 VARCHAR2(30 BYTE),
  F_MACR_ACT            VARCHAR2(30 BYTE),
  F_PRJ                 VARCHAR2(30 BYTE),
  F_MDC                 VARCHAR2(30 BYTE),
  F_FYFM                VARCHAR2(30 BYTE),
  F_SALES_CODE          VARCHAR2(30 BYTE),
  F_RID2                VARCHAR2(30 BYTE),
  F_FUND_CODE           VARCHAR2(30 BYTE),
  F_JOB_CONTROL_NO      VARCHAR2(30 BYTE),
  F_TRANS_TIME          VARCHAR2(30 BYTE),
  F_JOCAS               VARCHAR2(30 BYTE),
  F_DBOF_FLAG           VARCHAR2(30 BYTE),
  F_COST_SYS_IND        VARCHAR2(30 BYTE),
  F_SA_FLAG             VARCHAR2(30 BYTE),
  F_MSD_COST_1          VARCHAR2(30 BYTE),
  F_MSD_COST_2          VARCHAR2(30 BYTE),
  F_MSD_COST_3          VARCHAR2(30 BYTE),
  F_MSD_COST_4          VARCHAR2(30 BYTE),
  F_MSD_COST_5          VARCHAR2(30 BYTE),
  F_FILLER5             VARCHAR2(30 BYTE),
  F_PO_YEAR             VARCHAR2(30 BYTE),
  F_PO_NBR              VARCHAR2(30 BYTE),
  F_BEF_DELAY_DAYS      VARCHAR2(30 BYTE),
  F_AFT_DELAY_DAYS      VARCHAR2(30 BYTE),
  F_OTH_DELAY_DAYS      VARCHAR2(30 BYTE),
  F_AWP_DAYS            VARCHAR2(30 BYTE),
  F_REQ_DATE            VARCHAR2(30 BYTE),
  F_TOLC                VARCHAR2(30 BYTE),
  F_PRE_REPAIR          VARCHAR2(30 BYTE),
  F_REPAIR_REPAIR       VARCHAR2(30 BYTE),
  F_POST_REPAIR         VARCHAR2(30 BYTE),
  F_AWP                 VARCHAR2(30 BYTE),
  F_OTHER               VARCHAR2(30 BYTE),
  F_AP_CD               VARCHAR2(30 BYTE),
  SRAN                  VARCHAR2(10 BYTE)
)
TABLESPACE AMD_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCACHE
NOPARALLEL;


CREATE PUBLIC SYNONYM TMP_LCF_RAW FOR TMP_LCF_RAW;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_LCF_RAW TO AMD_DATALOAD;

GRANT SELECT ON  TMP_LCF_RAW TO AMD_USER;

GRANT SELECT ON  TMP_LCF_RAW TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_LCF_RAW TO AMD_WRITER_ROLE;


