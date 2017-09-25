CREATE OR REPLACE function C17PGM.deleteConfirmedRequest(name in varchar2) return number IS
    id NUMBER;
/*
   $Author:   zf297a  $
   $Revision:   1.1  $
   $Date:   14 Jan 2009 12:10:34  $
   $Workfile:   deleteConfirmedRequest.fnc  $
   $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Functions\C17PGM\deleteConfirmedRequest.fnc.-arc  $
/*   
/*      Rev 1.1   14 Jan 2009 12:10:34   zf297a
/*   enable PVCS keywords

*/

BEGIN
    select id into deleteConfirmedRequest.id 
    from spoc17v2.confirmed_request 
    where name = deleteConfirmedRequest.name ;

    begin
        delete from spoc17v2.confirmed_request_line where confirmed_request = deleteConfirmedRequest.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;

    
    delete from spoc17v2.confirmed_request where name = deleteConfirmedRequest.name ;
    return 0 ;
    
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       return 0 ;
     
END deleteConfirmedRequest ;
/

