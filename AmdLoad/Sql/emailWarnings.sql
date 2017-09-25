whenever sqlerror exit FAILURE
exec amd_warnings_pkg.sendWarnings('&1','&2') ;
quit
