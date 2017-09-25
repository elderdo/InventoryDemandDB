CREATE OR REPLACE procedure mta_disable_constraint (
                            table_name		varchar2,
                            constraint_name	varchar2)
as
 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   Jun 09 2006 09:19:12  $
    $Workfile:   MTA_DISABLE_CONSTRAINT.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\MTA_DISABLE_CONSTRAINT.prc-arc  $
/*   
/*      Rev 1.1   Jun 09 2006 09:19:12   zf297a
/*   Added PVCS keywords and writeMsg to log the event to amd_load_details
*/
crsor integer;
rval  integer;
begin
 amd_utils.writeMsg(pSourceName => 'mta_disable_constraint', 
   pTableName => table_name, pError_location => 1, pData => 'mta_disable_constraint',
     pKey1 => table_name, pKey2 => constraint_name, pKey3 => '$Revision:   1.1  $') ;
 dbms_output.put_line('Disabling Constraint: ' || constraint_name ||
	' Table: '|| table_name);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'alter table '|| table_name ||
                ' disable constraint '|| constraint_name ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;
/
