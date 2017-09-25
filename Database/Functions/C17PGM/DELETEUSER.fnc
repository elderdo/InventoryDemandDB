CREATE OR REPLACE function C17PGM.deleteUser(name in varchar2) return number IS
    id NUMBER;
/*
   $Author:   zf297a  $
   $Revision:   1.3  $
   $Date:   26 Mar 2009 23:10:30  $
   $Workfile:   DELETEUSER.fnc  $
   $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Functions\C17PGM\DELETEUSER.fnc.-arc  $
/*   
/*      Rev 1.3   26 Mar 2009 23:10:30   zf297a
/*   update lp_override and set override_user to zero for the spo_user that is being deleted.
/*   
/*      Rev 1.2   21 Jan 2009 11:08:52   zf297a
/*   delete children from user_part
/*   
/*      Rev 1.1   14 Jan 2009 12:12:12   zf297a
/*   enable PVCS keywords
*/

BEGIN
    select id into deleteUser.id 
    from spoc17v2.spo_user 
    where name = deleteUser.name ;

    begin
        delete from spoc17v2.user_user_type where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;

    begin
        delete from spoc17v2.user_login where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;
    
    begin
        update spoc17v2.user_login 
        set last_modified_by = 0 
        where last_modified_by = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;

    begin
        update spoc17v2.exception_rule 
        set spo_user = 0 
        where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;

    begin
        update spoc17v2.exception_rule_parameter 
        set spo_user = 0 
        where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;

    begin
        update spoc17v2.exception_rule_precedence 
        set spo_user = 0 
        where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;

    begin
        update spoc17v2.lp_comment 
        set spo_user = 0 
        where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;
    
    begin
        update spoc17v2.lp_override
        set override_user = 0
        where override_user = deleteUser.id ;
    exception
        when no_data_found then
            null ; -- do nothing
    end ;                    

    begin
        delete from spoc17v2.spo_user_preference where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;
    
    begin
        delete from spoc17v2.user_part where spo_user = deleteUser.id ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null ; -- do nothing
    end ;
    
    delete from spoc17v2.spo_user where name = deleteUser.name ;
    return 0 ;
    
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       return 0 ;
     
END deleteUser ;
/
