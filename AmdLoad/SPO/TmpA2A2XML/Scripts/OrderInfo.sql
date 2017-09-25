/*
	$Author:   zf297a  $
      $Revision:   1.5  $
          $Date:   13 Dec 2007 10:00:38  $
      $Workfile:   OrderInfo.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Scripts\OrderInfo.sql.-arc  $
/*   
/*      Rev 1.5   13 Dec 2007 10:00:38   zf297a
/*   Make sure the quantity does not have any decimal values.
**/

SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'001' as tran_priority,
'ORDER_INFO_LINE' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS')  as tran_date,
ol.ORDER_NO order_no,
ol.SITE_LOCATION site_location,
to_char(ol.CREATED_DATE, 'YYYYMMDDHH24MISS') as CREATED_DATE,
ol.STATUS,
CAGE_CODE,
ol.PART_NO part_no,
line,
round(qty_ordered) qty_ordered,
qty_received,
to_char(due_date, 'YYYYMMDDHH24MISS') as due_date
FROM tmp_a2a_order_info_line ol 
where ol.action_code in ('A','C')
