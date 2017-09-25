/*
   	  $Author:   c970183  $
	$Revision:   1.0  $
	    $Date:   02 Aug 2004 12:20:50  $
	$Workfile:   tmp_amd_on_hand_invs.sql  $
	     $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_amd_on_hand_invs.sql-arc  $
/*   
/*      Rev 1.0   02 Aug 2004 12:20:50   c970183
/*   Initial revision.
*/
CREATE TABLE TMP_AMD_ON_HAND_INVS
(
  PART_NO         VARCHAR2(50 BYTE)             NOT NULL,
  LOC_SID         NUMBER                        NOT NULL,
  INV_DATE        DATE                          NOT NULL,
  INV_QTY         NUMBER                        NOT NULL,
  ACTION_CODE     VARCHAR2(1 BYTE)              NOT NULL,
  LAST_UPDATE_DT  DATE                          NOT NULL
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


CREATE UNIQUE INDEX TMP_AMD_ON_HAND_INVS_PK ON TMP_AMD_ON_HAND_INVS
(PART_NO, LOC_SID, INV_DATE)
LOGGING
TABLESPACE AMD_INDEX
PCTFREE    10
INITRANS   2
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
NOPARALLEL;


CREATE PUBLIC SYNONYM TMP_AMD_ON_HAND_INVS FOR TMP_AMD_ON_HAND_INVS;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_ON_HAND_INVS TO BSRM_LOADER;

