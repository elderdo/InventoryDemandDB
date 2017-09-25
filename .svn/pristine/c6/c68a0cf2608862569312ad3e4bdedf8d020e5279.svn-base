    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:30:46  $
     $Workfile:   TRUNCATE_TABLE.prc  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Procedures\TRUNCATE_TABLE.prc-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:30:46   c970183
/*   Initial revision.
*/
CREATE OR REPLACE procedure truncate_table (
                            table_name   varchar2,
                            storage_type varchar2)
as
crsor integer;
rval  integer;
begin
 dbms_output.put_line('Truncating Table : '|| table_name ||
                     ' Storage : '|| storage_type);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'truncate table '|| table_name ||
                ' '|| storage_type ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;
/

