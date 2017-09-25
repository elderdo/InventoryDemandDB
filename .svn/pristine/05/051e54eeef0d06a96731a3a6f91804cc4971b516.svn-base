/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   05 Nov 2007 10:44:54  $
    $Workfile:   PartAlt.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\PartAlt.sql.-arc  $
/*   
/*      Rev 1.1   05 Nov 2007 10:44:54   zf297a
/*   Added Order by clause to make sure the changes are sent to the queue in the order that they were applied to the tmp_a2a_part_alt table.
/*   
/*      Rev 1.0   27 Sep 2007 13:09:02   zf297a
/*   Initial revision.
*/
SELECT
'LBC17' as site_program,
'BATCH' as tran_source,
'001' as tran_priority,
'PART_ALT' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
part_no,
prime_part
from tmp_a2a_part_alt
where tran_action <> 'D'
order by part_no, last_update_dt
 
