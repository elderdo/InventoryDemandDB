#!/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
# get the infile param from a sqlldr ctl file
# Date      By               History
# --------  ---------------  --------------------------------------
# 10/13/09  Elder D.         Initial implementation.

awk 'tolower($1) ~ /infile/ {print substr($2,2,length($2)-2) }' $1
