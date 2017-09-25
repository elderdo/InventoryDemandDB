    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 20 2005 08:53:54  $
     $Workfile:   tmp_amd_national_stock_items.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\ddl\tmp_amd_national_stock_items.sql-arc  $
/*   
/*      Rev 1.0   May 20 2005 08:53:54   c970183
/*   Initial revision.
*/

CREATE TABLE TMP_AMD_NATIONAL_STOCK_ITEMS
(
  NSN               VARCHAR2(13 BYTE),
  NSN_NOMENCLATURE  VARCHAR2(25 BYTE)
)
TABLESPACE AMD_DATA
PCTUSED    40
PCTFREE    5
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


CREATE PUBLIC SYNONYM TMP_AMD_NATIONAL_STOCK_ITEMS FOR TMP_AMD_NATIONAL_STOCK_ITEMS;


GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_NATIONAL_STOCK_ITEMS TO AMD_DATALOAD;

GRANT SELECT ON  TMP_AMD_NATIONAL_STOCK_ITEMS TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON  TMP_AMD_NATIONAL_STOCK_ITEMS TO AMD_WRITER_ROLE;


