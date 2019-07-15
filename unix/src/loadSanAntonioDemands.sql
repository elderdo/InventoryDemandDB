/*

      Author:   Douglas S. Elder
    Revision:   1.1
        Date:   22 Nov 2017
    Workfile:   loadSanAntonioDemands.sql
/*
/*      Rev 1.1   21 Nov 2017 DSE used UNLIMITED for serveroutput
/*      Rev 1.0   2 Aug 2017
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size UNLIMITED

exec   amd_demand.loadSanAntonioDemands;

@@analyzeAmdBssmSource.sql
@@analyzeTmpAmdDemands.sql

exit

