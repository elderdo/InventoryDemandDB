/*

      Author:   Douglas S. Elder
    Revision:   1.0
        Date:   25 Aug 2017
    Workfile:   loadWarnerRobinsDemands.sql
/*
/*      Rev 1.0   25 Aug 2017
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size 100000

exec   amd_demand.loadWarnerRobinsDemands;

@@analyzeAmdBssmSource.sql
@@analyzeTmpAmdDemands.sql

exit

