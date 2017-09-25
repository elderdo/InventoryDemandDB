/* Formatted on 6/20/2016 2:37:46 PM (QP5 v5.256.13226.35538) */
/*
      $Author:   zf297a  $
    $Revision:   1.1
        $Date:   6/20/2016
    $Workfile:   loadWecm.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadWecm.sql.-arc  $
/*   
/*      Rev 1.1   6/20/2016 add set serveroutput and reformatted code
/*   Initial revision.
/*      Rev 1.0   20 May 2008 14:30:54   zf297a
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC amd_load.loadwecm;

EXIT
