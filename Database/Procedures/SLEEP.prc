
CREATE OR REPLACE procedure AMD_OWNER.sleep( secs in number) is
/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   07 Aug 2009 10:07:58  $
    $Workfile:   SLEEP.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\SLEEP.prc.-arc  $
/*   
/*      Rev 1.0   07 Aug 2009 10:07:58   zf297a
/*   Initial revision.
*/
        end_date_time date := sysdate + (1/(24*60*60) * secs) ;
    begin
        while sysdate < end_date_time
        loop
            null;
        end loop;
    end sleep ;
/
