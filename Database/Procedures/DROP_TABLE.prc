    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:30:44  $
     $Workfile:   DROP_TABLE.prc  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Procedures\DROP_TABLE.prc-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:30:44   c970183
/*   Initial revision.
*/
CREATE OR REPLACE procedure drop_table (
                            table_name   varchar2)
as
crsor integer;
rval  integer;
begin
 dbms_output.put_line('Dropping Table : '|| table_name);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'drop table '|| table_name
                ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;
/
