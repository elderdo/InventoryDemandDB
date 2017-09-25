CREATE OR REPLACE PACKAGE body C17DEVLPR.spo_util_pkg AS
 /*
      $Author:   c970984  $
    $Revision:   1.0  $
        $Date:   Oct 02 2007 11:14:30  $
    $Workfile:   spo_util_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\C17DEVLPR\spo_util_pkg.pkb.-arc  $
/*   
/*      Rev 1.0   Oct 02 2007 11:14:30   c970984
/*   Initial revision.
/*   
/*   
/*      Rev 1.0   27 Sep 2007 17:27:12   C970984
/*   Initial revision.
*/   
    
    function getNextBatchSequence return number is
    
        new_batch_seq number ;
    
    begin
        select SPOC17V2.batch_sequence.nextval into new_batch_seq from dual;
        
        return new_batch_seq ;
        
    exception when others then
        /*
        errorMsg(pSqlfunction       => 'diff',pTableName  => TARGET_TABLE,
            pError_location => 220, 
            pKey1 => 'part_no=' || part_no,
            pKey2 => 'spo_location=' || spo_location,
            pKey3 => 'tsl_override_type=' || tsl_override_type,
            pKey4 => 'tsl_override_user=' || tsl_override_user ) ;
        */
        raise ;            
    end;
    
      
     
    procedure version IS
    begin
        --writeMsg(pTableName => 'sspo_util_pkg', 
        --     pError_location => 250, pKey1 => 'sspo_util_pkg', pKey2 => '$Revision:   1.0  $') ;
        dbms_output.put_line('spo_util_pkg: $Revision:   1.0  $') ;
    end version ;


end spo_util_pkg ;
/