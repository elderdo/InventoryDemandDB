CREATE OR REPLACE procedure mta_truncate_table (
                            table_name   varchar2,
                            storage_type varchar2)
as
 /*
      $Author:   zf297a  $
	$Revision:   1.4  $
        $Date:   Jun 09 2006 09:18:32  $
    $Workfile:   MTA_TRUNCATE_TABLE.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\MTA_TRUNCATE_TABLE.prc-arc  $
/*   
/*      Rev 1.4   Jun 09 2006 09:18:32   zf297a
/*   Added pData to set data_line in amd_load_details
/*   
/*      Rev 1.3   Jun 08 2006 13:00:16   zf297a
/*   Added mta_truncate_table to last "end" statement.
/*   
/*      Rev 1.2   Jun 08 2006 12:57:24   zf297a
/*   Made sure that the table_name appears in key2 of amd_load_details
/*   
/*      Rev 1.1   Jun 07 2006 19:20:54   zf297a
/*   Added writeMsg with $Revision:   1.4  $
*/
crsor integer;
rval  integer;
begin
 amd_utils.writeMsg(pSourceName => 'mta_truncate_table', 
   pTableName => table_name, pError_location => 1, pData => 'mta_truncate_table',
     pKey1 => storage_type, pKey2 => table_name, pKey3 => '$Revision:   1.4  $') ;
    dbms_output.put_line('Truncating Table : '|| table_name ||
                     ' Storage : '|| storage_type);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'truncate table '|| table_name ||
                ' '|| storage_type ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end mta_truncate_table;
/
