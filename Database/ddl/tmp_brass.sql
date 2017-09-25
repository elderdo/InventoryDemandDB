    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:58  $
     $Workfile:   tmp_brass.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_brass.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:58   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_BRASS
(
  PART_NO               VARCHAR2(20 BYTE),
  NSN                   VARCHAR2(16 BYTE),
  NIIN                  VARCHAR2(10 BYTE),
  OFF_BASE_TURN_AROUND  NUMBER,
  OFF_BASE_COND         NUMBER,
  OFF_BASE_DIAG_TIME    NUMBER,
  GOLD_PART             CHAR(50 BYTE)
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


CREATE PUBLIC SYNONYM TMP_BRASS FOR TMP_BRASS;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_BRASS TO AMD_DATALOAD;

GRANT SELECT ON  TMP_BRASS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_BRASS TO AMD_WRITER_ROLE;


