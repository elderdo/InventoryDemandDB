#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   07 May 2008 18:50:16  $
# $Workfile:   truncateLpOverride.ksh  $
# This script truncates the Data Systems lp_override table
# and the SPO lp_overaride table
sqlplus /nolog << EOF
whenever sqlerror exit sql.sqlcode
whenever oserror exit 4
connect $DB_CONNECTION_STRING_FOR_SPO
exec escmc17v2.pkg_escm.truncate_table('lp_override')  ;
exec spoc17v2.pkg_escmspo.truncate_table('lp_override') ;
EOF

