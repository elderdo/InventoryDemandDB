 /*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   23 Aug 2007 10:41:20  $
    $Workfile:   addColumnWesmIndicator.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\addColumnWesmIndicator.sql.-arc  $
/*   
/*      Rev 1.0   23 Aug 2007 10:41:20   zf297a
/*   Initial revision.
*/

ALTER TABLE amd_national_stock_items
ADD ( wesm_indicator varchar2(1) ) ;

