/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:

      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   17 Sep 2015
    $Workfile:   BssmRspOnHand.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\BssmRspOnHand.sql.-arc  $
/*
/*      Rev 1.3   17 Sep 2015 put back tabs
/*      Rev 1.2   27 Aug 2015 updated received from Laurie Compton
                              and implemented by Douglas Elder

/*      Rev 1.1   16 Apr 2009 10:07:44   zf297a
/*   Added tab characters per a BSSM requirement
/*
/*      Rev 1.0   24 Mar 2009 11:00:34   zf297a
/*   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT    TO_CHAR (ansi.nsn)
         || CHR (9)
         || DECODE (asn.loc_id,
                    'FB2067', 'FB4479',
                    'FB4419', 'FB4479',
                    'FB4804', 'FB4418',
                    'FB5240', 'FB4479',
                    'FB5612', 'FB4479',
                    'FB5804', 'FB4479',
                    'FB5806', 'FB4427',
                    'FB5814', 'FB4479',
                    'FB5820', 'FB4479',
                    'FB5891', 'FB4484',
                    'KITAUS', 'EY1258',
                    'KITCAN', 'EY1414',
                    'KITIND', 'EB1233',
                    'KITUAE', 'EY1750',
                    asn.loc_id)
         || CHR (9)
         || SUM (rsp_inv)
         || CHR (9)
         || SUM (rsp_level)
    FROM amd_rsp r, amd_spare_networks asn, amd_national_stock_items ansi
   WHERE     r.action_code != 'D'
         AND R.PART_NO = ANSI.PRIME_PART_NO
         AND ANSI.ACTION_CODE != 'D'
         AND r.loc_sid = asn.loc_sid
GROUP BY ansi.nsn,
         DECODE (asn.loc_id,
                 'FB2067', 'FB4479',
                 'FB4419', 'FB4479',
                 'FB4804', 'FB4418',
                 'FB5240', 'FB4479',
                 'FB5612', 'FB4479',
                 'FB5804', 'FB4479',
                 'FB5806', 'FB4427',
                 'FB5814', 'FB4479',
                 'FB5820', 'FB4479',
                 'FB5891', 'FB4484',
                 'KITAUS', 'EY1258',
                 'KITCAN', 'EY1414',
                 'KITIND', 'EB1233',
                 'KITUAE', 'EY1750',
                 asn.loc_id)
  HAVING SUM (rsp_inv) > 0 AND SUM (rsp_level) > 0;
QUIT
