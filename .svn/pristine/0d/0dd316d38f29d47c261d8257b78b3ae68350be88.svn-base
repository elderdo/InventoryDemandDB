CREATE OR REPLACE TRIGGER AMD_OWNER.tmpDmndFrcstConsumablesBefTrig
BEFORE INSERT 
ON AMD_OWNER.tmp_amd_dmnd_frcst_consumables
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
THE_TABLE_NAME constant amd_log.table_name%type := 'tmp_amd_dmnd_frcst_consumables' ;
action_code varchar2(1) ;
theKey varchar2(80) ;
last_update_dt date := sysdate ;


/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   23 May 2007 00:02:08  $
    $Workfile:   TMPDMNDFRCSTCONSUMABLESBEFTRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\TMPDMNDFRCSTCONSUMABLESBEFTRIG.trg.-arc  $
/*   
/*      Rev 1.0   23 May 2007 00:02:08   zf297a
/*   Initial revision.
******************************************************************************/

    function getNsn(part_no in varchar2) return varchar2 is
        nsn amd_spare_parts.nsn%type ;
    begin
        select nsn into nsn
        from amd_spare_parts
        where part_no = getNsn.part_no
        and action_code <> amd_defaults.getDELETE_ACTION ;
        return nsn ;
    exception when standard.no_data_found then
        return null ;
    end getNsn ;
BEGIN
    if substr(:new.nsn,1,4) = 'NSL~' then
        :new.nsn := getNsn(substr(:new.nsn,5)) ;
    end if ;
    if :new.nsn is null then
        raise_application_error(-20550,'Cannot find nsn for ' || :new.nsn) ;
    end if ;
   EXCEPTION
     WHEN OTHERS then
       -- Consider logging the error and) then re-raise
       RAISE;
END tmpDmndFrcstConsumablesBefTrig ;

