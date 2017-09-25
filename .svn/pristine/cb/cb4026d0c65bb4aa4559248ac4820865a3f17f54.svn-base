/*
      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   June 2 2015
   
      Rev 1.0   Feb 17 2006 13:22:22   zf297a
      Rev 1.1   May 19 2015
      Rev 1.2   June 01 2015 - per Eric Honma's 6/1/2015 email
      Rev 1.3   June 02 2015 - per Eric Honma's 6/2/2015 email
      ClearQuest rev LBPSS00003513 
 **/

set heading off
set feedback off
set tab off 
set newpage none
set pagesize 0

SELECT    SUBSTR (c.prime, 1, 20)
         || CHR (9)
         || to_char(Completed_docdate,'MM/DD/YYYY')
         || CHR (9)
         || to_char(created_docdate,'MM/DD/YYYY')
         || CHR (9)
         || action_taken
    FROM cat1 C, ord1 I
   WHERE     c.source_code = 'F77'
         AND C.PART = I.PART
         AND (   Action_taken IN ('A',
                                  'B',
                                  'E',
                                  'F',
                                  'G')
              OR action_taken IS NULL)
         AND ORDER_TYPE = 'J'
ORDER BY SUBSTR (i.part, 1, 20) ;

quit
