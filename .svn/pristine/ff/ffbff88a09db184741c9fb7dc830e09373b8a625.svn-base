#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   Sep 08 2006 13:49:56  $
# $Workfile:   sendErrorMsg.ksh  $
/usr/sbin/sendmail  -t <<EOF
To: Douglas.S.Elder@boeing.com,phuong-thuy.pham@boeing.com,willy.yao@boeing.com
From: ${1:-$0}
Subject: ${2:-"Test"}
${3:-"The system failed"}
EOF
