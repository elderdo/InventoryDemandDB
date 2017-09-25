    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:36  $
     $Workfile:   exceptions.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\exceptions.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:36   c970183
/*   Initial revision.
*/

CREATE TABLE EXCEPTIONS
(
  ROW_ID      ROWID,
  OWNER       VARCHAR2(30 BYTE),
  TABLE_NAME  VARCHAR2(30 BYTE),
  CONSTRAINT  VARCHAR2(30 BYTE)
)
TABLESPACE AMD_NDX
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


CREATE PUBLIC SYNONYM EXCEPTIONS FOR EXCEPTIONS;


GRANT SELECT ON  EXCEPTIONS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  EXCEPTIONS TO AMD_WRITER_ROLE;


