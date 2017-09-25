CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_USER_TYPE_BEFORE_TRIG
before INSERT
ON AMD_OWNER.AMD_USER_TYPE REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author$ zf297a
    $Revision$ 1.1
        $Date$ 13 Feb 2015
    $Workfile$

            Rev 1.1 commented out spo code
*/         
wk_bems_id amd_people_all_v.bems_id%type ;
--wk_user_type spo_user_type_v.NAME%type ;
BEGIN
    begin
        select bems_id into wk_bems_id from amd_people_all_v
        where :new.bems_id = amd_people_all_v.bems_id;
    exception when standard.no_data_found then     
        raise_application_error(-20800,'bems_id ' || :new.bems_id || ' does not exist in amd_people_all_v.') ;
    end   ;         
    /*
    begin
        select name into wk_user_type from spo_user_type_v
        where :new.user_type = spo_user_type_v.name ;
    exception when standard.no_data_found then     
        raise_application_error(-20900,'user_type ' || :new.bems_id || ' does not exist in spo_user_type_v.') ;
    end ;
    */     
END ;
/