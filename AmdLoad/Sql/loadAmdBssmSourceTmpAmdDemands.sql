/*
  vim: ff=unix:ts=2:sw=2:sts=2:autoindent:smartindent:expandtab:
      $Author:   Douglas S Elder
    $Revision:   1.2  $
        $Date:   25 Jan 2017
        File:    loadAmdBssmSourceTmpAmdDemands.sql
	
      Rev 1.0   31 Jul 2012
   Initial revision.
      Rev 1.1   21 Jul 2014 dse added set serveroutput
      Rev 1.2   25 Jan 2017 Douglas S Elder added analyzeTmpLcf1.sql,
                            analyzeTmpLcfIcp.sql,
                            analyzeAmdBssmSource.sql,
                            analyzeTmpAmdDemands.sql,
                            reformatted code
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC   amd_owner.mta_truncate_table('tmp_amd_demands','reuse storage');
EXEC   amd_demand.loadAmdBssmSourceTmpAmdDemands;

@@analyzeTmpLcf1.sql
@@analyzeTmpLcfIcp.sql
@@analyzeAmdBssmSource.sql
@@analyzeTmpAmdDemands.sql

EXIT
