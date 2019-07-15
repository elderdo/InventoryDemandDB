/*
      $Author:   Douglas Elder
    $Revision:   1.8  
        $Date:   19 May 2017
    $Workfile:   PartSumSranConv.sql  $
*
*		 Rev 1.9  13 Sep 2017 Douglas Elder removed FB6482 from decode
*		 Rev 1.8  19 May 2017 Douglas Elder added order by and formatted code
*		 Rev 1.7  22 Apr 2016 Douglas Elder
*		 .  FB4626 and FB5232 goes to McChord (FB4479) and FB6353 and FB6451 go to Charleston (FB4418) - per CR LBPSS00003521 
*  
*		 Rev 1.6  31 Oct 2011 C402417
*		 Removed FB6322 to be allocated to FB4418 per CR LBPSS00003155 .
*  
*		 Rev 1.5  12 Aug 2010  c402417
*		 Added 31 more loc_id per Change Request LBPSS0000277
* 
*      Rev 1.4   22 Apr 2009 12:30:30   zf297a
*   Thuy Pham added FMS demands
*   
*      Rev 1.3   29 May 2008 15:45:28   zf297a
*   Added PVCS keywords and loc_id set changed
*
* PartSumSranConv.sql  1.2  Modified:  03/31/06 10:02:26
*
**/

SET UNDERLINE OFF
SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT    TO_CHAR (n.nsn)
         || CHR (9)
         || DECODE (s.loc_id,
                    'FB2027', 'FB4479',
                    'FB2073', 'FB4479',
                    'FB2373', 'EY1746',
                    'FB2505', 'FB4479',
                    'FB2823', 'FB4418',
                    'FB3020', 'FB4664',
                    'FB3047', 'FB4664',
                    'FB4400', 'FB4418',
                    'FB4401', 'FB5612',
                    'FB4402', 'FB5685',
                    'FB4403', 'FB5621',
                    'FB4405', 'FB5260',
                    'FB4406', 'FB4418',
                    'FB4408', 'FB5209',
                    'FB4411', 'FB5270',
                    'FB4412', 'FB4418',
                    'FB4415', 'FB5240',
                    'FB4417', 'FB4418',
                    'FB4425', 'FB4497',
                    'FB4454', 'FB4479',
                    'FB4455', 'FB4418',
                    'FB4460', 'FB6242',
                    'FB4469', 'FB4664',
                    'FB4480', 'FB5000',
                    'FB4486', 'FB4479',
                    'FB4491', 'FB4418',
                    'FB4503', 'FB4418',
                    'FB4528', 'FB4418',
                    'FB4600', 'FB4479',
                    'FB4608', 'FB6242',
                    'FB4610', 'FB4427',
                    'FB4620', 'FB4479',
                    'FB4621', 'FB4479',
                    'FB4625', 'FB4418',
                    'FB4661', 'FB4479',
                    'FB4668', 'FB4418',
                    'FB4690', 'FB4479',
                    'FB4800', 'FB4418',
                    'FB4801', 'FB4479',
                    'FB4803', 'FB4418',
                    'FB4804', 'FB4418',
                    'FB4808', 'FB4479',
                    'FB4809', 'FB4418',
                    'FB4814', 'FB4418',
                    'FB4819', 'FB4418',
                    'FB4828', 'FB4418',
                    'FB4830', 'FB4418',
                    'FB4852', 'FB4479',
                    'FB4855', 'FB4427',
                    'FB4872', 'FB4418',
                    'FB4877', 'EY1746',
                    'FB4887', 'FB4427',
                    'FB4897', 'FB4479',
                    'FB5004', 'FB5000',
                    'FB5205', 'FB4479',
                    'FB5284', 'FB5260',
                    'FB5294', 'FB4479',
                    'FB5518', 'FB4418',
                    'FB5575', 'FB4418',
                    'FB5587', 'FB4418',
                    'FB5682', 'FB4418',
                    'FB5804', 'FB4418',
                    'FB5806', 'FB4418',
                    'FB5814', 'FB4418',
                    'FB5820', 'FB4418',
                    'FB5834', 'FB4418',
                    'FB5846', 'FB4418',
                    'FB5851', 'FB4418',
                    'FB5860', 'FB4418',
                    'FB5873', 'FB4418',
                    'FB5874', 'FB4418',
                    'FB5878', 'FB4479',
                    'FB5879', 'FB4418',
                    'FB5880', 'FB4418',
                    'FB5881', 'FB4418',
                    'FB5884', 'FB4418',
                    'FB5885', 'FB4418',
                    'FB5891', 'FB4418',
                    'FB5897', 'FB4418',
                    'FB6101', 'FB4418',
                    'FB6151', 'FB4479',
                    'FB6181', 'FB4418',
                    'FB6324', 'FB4884',
                    'FB6356', 'FB4484',
                    'FB6371', 'FB4479',
                    'FB6372', 'FB4479',
                    'FB6391', 'FB4418',
                    'FB6401', 'FB4418',
                    'FB6530', 'FB5260',
                    'FB6606', 'FB4418',
                    'FB4626', 'FB4479',        -- ChangeRequest  LBPSS00003521
                    'FB5232', 'FB4479',        -- ChangeRequest  LBPSS00003521
                    'FB6353', 'FB4418',        -- ChangeRequest  LBPSS00003521
                    'FB6451', 'FB4418',        -- ChangeRequest  LBPSS00003521
                    'FB6633', 'EY1746',                           -- TFS 22378
                    'FB2500', 'FB4427',                           -- TFS 22378
                    'FB2520', 'FB4418',                           -- TFS 22378
                    'FB3300', 'FB6242',                           -- TFS 22378
                    'FB4407', 'FB4484',                           -- TFS 22378
                    'FB4686', 'FB4627',                           -- TFS 22378
                    'FB4817', 'FB4427',                           -- TFS 22378
                    'FB5803', 'FB4418',                           -- TFS 22378
                    'FB5819', 'FB4418',                           -- TFS 22378
                    'FB6021', 'FB4664',                           -- TFS 22378
                    'FB6022', 'FB4664',                           -- TFS 22378
                    'FB6044', 'FB4427',                           -- TFS 22378
                    'FB6152', 'FB6422',                           -- TFS 22378
                    'FB6303', 'FB4497',                           -- TFS 22378
                    'FB6331', 'FB4418',                           -- TFS 22378
                    'FB6355', 'FB2300',                           -- TFS 22378
                    'FB6431', 'FB4419',                           -- TFS 22378
                    'FB6501', 'FB4479',                           -- TFS 22378
                    'FB6520', 'FB6242',                           -- TFS 22378
                    'FB6656', 'FB2300',                           -- TFS 22378
                    'FB6670', 'FB4484',                           -- TFS 22378
                    s.loc_id)
         || CHR (9)
         || TO_CHAR (TRUNC (d.doc_date, 'MONTH'), 'mm/"01"/yyyy')
         || CHR (9)
         || SUM (d.quantity)
    FROM amd_demands d, amd_spare_networks s, amd_national_stock_items n
   WHERE     d.loc_sid = s.loc_sid
         AND d.nsi_sid = n.nsi_sid
         AND n.action_code IN ('A', 'C')
         AND d.doc_date > TO_DATE ('12/31/2001', 'mm/dd/yyyy')
GROUP BY n.nsn,
         DECODE (s.loc_id,
                 'FB2027', 'FB4479',
                 'FB2073', 'FB4479',
                 'FB2373', 'EY1746',
                 'FB2505', 'FB4479',
                 'FB2823', 'FB4418',
                 'FB3020', 'FB4664',
                 'FB3047', 'FB4664',
                 'FB4400', 'FB4418',
                 'FB4401', 'FB5612',
                 'FB4402', 'FB5685',
                 'FB4403', 'FB5621',
                 'FB4405', 'FB5260',
                 'FB4406', 'FB4418',
                 'FB4408', 'FB5209',
                 'FB4411', 'FB5270',
                 'FB4412', 'FB4418',
                 'FB4415', 'FB5240',
                 'FB4417', 'FB4418',
                 'FB4425', 'FB4497',
                 'FB4454', 'FB4479',
                 'FB4455', 'FB4418',
                 'FB4460', 'FB6242',
                 'FB4469', 'FB4664',
                 'FB4480', 'FB5000',
                 'FB4486', 'FB4479',
                 'FB4491', 'FB4418',
                 'FB4503', 'FB4418',
                 'FB4528', 'FB4418',
                 'FB4600', 'FB4479',
                 'FB4608', 'FB6242',
                 'FB4610', 'FB4427',
                 'FB4620', 'FB4479',
                 'FB4621', 'FB4479',
                 'FB4625', 'FB4418',
                 'FB4661', 'FB4479',
                 'FB4668', 'FB4418',
                 'FB4690', 'FB4479',
                 'FB4800', 'FB4418',
                 'FB4801', 'FB4479',
                 'FB4803', 'FB4418',
                 'FB4804', 'FB4418',
                 'FB4808', 'FB4479',
                 'FB4809', 'FB4418',
                 'FB4814', 'FB4418',
                 'FB4819', 'FB4418',
                 'FB4828', 'FB4418',
                 'FB4830', 'FB4418',
                 'FB4852', 'FB4479',
                 'FB4855', 'FB4427',
                 'FB4872', 'FB4418',
                 'FB4877', 'EY1746',
                 'FB4887', 'FB4427',
                 'FB4897', 'FB4479',
                 'FB5004', 'FB5000',
                 'FB5205', 'FB4479',
                 'FB5284', 'FB5260',
                 'FB5294', 'FB4479',
                 'FB5518', 'FB4418',
                 'FB5575', 'FB4418',
                 'FB5587', 'FB4418',
                 'FB5682', 'FB4418',
                 'FB5804', 'FB4418',
                 'FB5806', 'FB4418',
                 'FB5814', 'FB4418',
                 'FB5820', 'FB4418',
                 'FB5834', 'FB4418',
                 'FB5846', 'FB4418',
                 'FB5851', 'FB4418',
                 'FB5860', 'FB4418',
                 'FB5873', 'FB4418',
                 'FB5874', 'FB4418',
                 'FB5878', 'FB4479',
                 'FB5879', 'FB4418',
                 'FB5880', 'FB4418',
                 'FB5881', 'FB4418',
                 'FB5884', 'FB4418',
                 'FB5885', 'FB4418',
                 'FB5891', 'FB4418',
                 'FB5897', 'FB4418',
                 'FB6101', 'FB4418',
                 'FB6151', 'FB4479',
                 'FB6181', 'FB4418',
                 'FB6324', 'FB4884',
                 'FB6356', 'FB4484',
                 'FB6371', 'FB4479',
                 'FB6372', 'FB4479',
                 'FB6391', 'FB4418',
                 'FB6401', 'FB4418',
                 'FB6530', 'FB5260',
                 'FB6606', 'FB4418',
                 'FB4626', 'FB4479',           -- ChangeRequest  LBPSS00003521
                 'FB5232', 'FB4479',           -- ChangeRequest  LBPSS00003521
                 'FB6353', 'FB4418',           -- ChangeRequest  LBPSS00003521
                 'FB6451', 'FB4418',           -- ChangeRequest  LBPSS00003521
                 'FB6633', 'EY1746',                              -- TFS 22378
                 'FB2500', 'FB4427',                              -- TFS 22378
                 'FB2520', 'FB4418',                              -- TFS 22378
                 'FB3300', 'FB6242',                              -- TFS 22378
                 'FB4407', 'FB4484',                              -- TFS 22378
                 'FB4686', 'FB4627',                              -- TFS 22378
                 'FB4817', 'FB4427',                              -- TFS 22378
                 'FB5803', 'FB4418',                              -- TFS 22378
                 'FB5819', 'FB4418',                              -- TFS 22378
                 'FB6021', 'FB4664',                              -- TFS 22378
                 'FB6022', 'FB4664',                              -- TFS 22378
                 'FB6044', 'FB4427',                              -- TFS 22378
                 'FB6152', 'FB6422',                              -- TFS 22378
                 'FB6303', 'FB4497',                              -- TFS 22378
                 'FB6331', 'FB4418',                              -- TFS 22378
                 'FB6355', 'FB2300',                              -- TFS 22378
                 'FB6431', 'FB4419',                              -- TFS 22378
                 'FB6501', 'FB4479',                              -- TFS 22378
                 'FB6520', 'FB6242',                              -- TFS 22378
                 'FB6656', 'FB2300',                              -- TFS 22378
                 'FB6670', 'FB4484',                              -- TFS 22378
                 s.loc_id),
         TO_CHAR (TRUNC (d.doc_date, 'MONTH'), 'mm/"01"/yyyy')
ORDER BY 1 ;

QUIT
