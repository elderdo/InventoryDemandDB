    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:50  $
     $Workfile:   temp_ham.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\temp_ham.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:50   c970183
/*   Initial revision.
*/

CREATE TABLE TEMP_HAM
(
  PROCESS_ID   NUMBER,
  PDPQ         NUMBER,
  TFIX         NUMBER,
  UCOST        NUMBER,
  PCOND        NUMBER,
  TCOND        NUMBER,
  ISRU         VARCHAR2(1 BYTE),
  NHAVE        NUMBER,
  TIME_PERIOD  DATE
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


CREATE PUBLIC SYNONYM TEMP_HAM FOR TEMP_HAM;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_HAM TO AMD_COSMIC_SUPERUSER;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_HAM TO AMD_DATALOAD;

GRANT SELECT ON  TEMP_HAM TO AMD_USER;

GRANT SELECT ON  TEMP_HAM TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TEMP_HAM TO AMD_WRITER_ROLE;


