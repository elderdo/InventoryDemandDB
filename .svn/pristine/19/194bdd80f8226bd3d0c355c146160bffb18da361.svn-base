/*
      $Author:   c402417  $
    $Revision:   1.4  $
        $Date:   6/20/16
    $Workfile:   AmdLoad1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\AmdLoad1.sql.-arc  $
/*   
/*      Rev 1.4   6/20/16 added set serveroutput and reformated code

/*      Rev 1.3   Aug 09 2007 09:18:22   c402417
/*   Added exec amd_load.loadwecm.
/*   
/*      Rev 1.2   Jan 30 2007 09:51:08   c402417
/*   Take out the  amd_load.LoadRblPairs and put in AmdLoad2.sql
/*   
/*      Rev 1.1   Jan 17 2007 16:04:50   c402417
/*   Added exec amd_load.LoadRblPairs .
/*   
/*      Rev 1.0   Feb 17 2006 13:21:10   zf297a
/*   Latest Prod version
*/
--
-- SCCSID: AmdLoad1.sql  1.2  Modified: 11/21/01 08:58:55
--
-- Date      By   History
-- 11/21/01  FF   Mod order.
--

SET ECHO ON
SET TERMOUT ON
SET TIME ON
SET SERVEROUTPUT ON SIZE 100000

PROMPT exec amd_load.LoadGold;
EXEC amd_load.loadgold;
COMMIT;

PROMPT exec amd_load.LoadPsms;
EXEC amd_load.loadpsms;
COMMIT;

PROMPT exec amd_load.LoadMain;
EXEC amd_load.loadmain;
COMMIT;

PROMPT exec amd_load.LoadWecm;
EXEC amd_load.loadwecm;
COMMIT;

QUIT
