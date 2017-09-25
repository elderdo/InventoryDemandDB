/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:

      $Author:   Douglas S. Elder
    $Revision:   1.5
        $Date:   23 Aug 2017
    $Workfile:   BssmRspOnHand.sql  $
         
      Rev 1.5   23 Aug 2017 fixed header added 4th tabbed column header
      Rev 1.4   26 Oct 2016 use new view and accept file name parameter
      Rev 1.3   17 Sep 2015 put back tabs
      Rev 1.2   27 Aug 2015 updated received from Laurie Compton
                              and implemented by Douglas Elder

      Rev 1.1   16 Apr 2009 10:07:44   zf297a
  Added tab characters per a BSSM requirement

     Rev 1.0   24 Mar 2009 11:00:34   zf297a
   Initial revision.
**/



WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE


SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 200
SET PAGESIZE 0
SET TRIMSPOOL ON
SET TERM OFF

SPOOL &1

SELECT 'NSN' || chr(9) || 'SRAN' || chr(9) || 'RSP_ON_HAND' || chr(9) ||  'RSP_OBJECTIVE' FROM DUAL;


  SELECT    NSN
         || CHR (9)
         || SRAN
         || CHR (9)
         || RSP_ON_HAND
         || CHR (9)
         || RSP_OBJECTIVE
    FROM amd_rsp_on_hand_n_objective_v
ORDER BY 1;

SPOOL OFF

QUIT
