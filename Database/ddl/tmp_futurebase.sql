    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:54:00  $
     $Workfile:   tmp_futurebase.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_futurebase.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:54:00   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_FUTUREBASE
(
  LOC_ID  VARCHAR2(10 BYTE),
  BASE    VARCHAR2(20 BYTE),
  PERIOD  VARCHAR2(10 BYTE),
  STOPS   NUMBER,
  HOURS   NUMBER,
  LANDS   NUMBER
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


CREATE PUBLIC SYNONYM TMP_FUTUREBASE FOR TMP_FUTUREBASE;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_FUTUREBASE TO AMD_DATALOAD;

GRANT SELECT ON  TMP_FUTUREBASE TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_FUTUREBASE TO AMD_WRITER_ROLE;


