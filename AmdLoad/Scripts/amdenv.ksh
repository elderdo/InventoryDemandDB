#!/usr/bin/ksh
# vim: set ts=2 sw=2 sts=2 et
#   $Author:   Douglas S. Elder
# $Revision:   2.1
#     $Date:   15 Feb 2018
# $Workfile:   amdenv.ksh  $
#
# SCCSID: amdenv.ksh  1.1  Modified: 07/13/01 15:44:00
#
# Date      By            History
# 02/15/18  Douglas Elder 2.1 removed obsolete back tic's replaced
#                             with $(..)
# 10/01/13  Douglas Elder 2.0 Converted to new Spo servers
# 07/13/01  Fernando F.   Initial
#
#

# defines environment, dev, it, prod
hostname=$(hostname -s)
case $hostname in
	ssd-sw-9000) export AMDENV=dev
		export DATASYSENV=dev
       		export SCM_HOST=app-ehs-d3001a.stl.mo.boeing.com ;;
	ssd-sw-6000) export AMDENV=it
		export DATASYSENV=crp
       		export SCM_HOST=app-ehs-t3001a.stl.mo.boeing.com ;;
	ssd-sw-3000) export AMDENV=prod 
		export DATASYSENV=prd
		export SCM_HOST=app-ehs-p3001a.stl.mo.boeing.com ;;
	*) print -u2 $hostname is not a valid machine
	   exit 4 ;;
esac

export JRE=/usr/java/jdk1.7.0_72/jre
