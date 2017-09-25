#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.12  $
#     $Date:   10 Jun 2008 14:26:58  $
# $Workfile:   amdconfig.ksh  $
#
# Prefix all local environment variables with config and all functions with config to make them unique to this script
# otherwise they will override any script that invokes it with dot notation!
#
# export environment variables are:
# JRE (unless already set)
# AMD_HOME (unless already set)
# DATA_HOME (unless already set)
# SRC_HOME (unless already set)
# BIN_HOME (unless already set)
# AMDENV (unless already set)
# LOG_HOME 
# XML_HOME 
# ARCH_HOME 
# PROFILE_DIR
# SHLIB_PATH (unless already set)
# myOSID (unless already set)
# AMD_SPO_ENV (unless already set)
# DateStr 
# TimeStamp 
#
configUSAGE="usage: . ${0##*/} use dot invocation to set environment variables."
configHostName=`uname -n`
configCurUser=`whoami`
configGroups="belonging to the folowing group(s) `groups`"

function configAbort {
	print -u2 ${1:-"createXml.ksh failed"}
	print -u2 $configUSAGE
	exit ${2:-4}
}

function configCheckFile {
	if  [[ ! -a $1 ]]
	then
		configAbort "$1 does not exist"
	else
		if  [[ ! -f $1 ]]
		then
			configAbort "$1 is not a regular file or symbolic link"
		else
			if  [[ ! -r $1 ]]
			then
				configAbort "$1 is not a readable file for $configCurUser $configGroups"
			fi
		fi
	fi
}

function configCheckDirectory {
	if [[ ! -a $1 ]]
	then
		configAbort "$1 does not exist"
	else
		if [[ ! -r $1 ]]
		then
			configAbort "$1 is not readable for $configCurUser $configGroups"
		else
			if [[ ! -d $1 ]]
			then
				configAbort "$1 is not a directory"
			fi
		fi
	fi
}

function configIsWritable {
	configCheckDirectory $1
	if [[ ! -w $1 ]]
	then
		configAbort "$1 is not writable by $configCurUser $configGroups"
	fi
}

function configIsExecutable {
	configCheckDirectory $1
	if [[ ! -x $1 ]]
	then
		configAbort "$1 is not executable by $configCurUser $configGroups"
	fi
}

if [[ $configHostName = svappl50 || $configHostName = svappl61 ]]
then
	if [[ $configCurUser != escmc172 ]]
	then
		PROFILE_DIR=/home/escmc172
		SHLIB_PATH=${SHLIB_PATH:-.} # if this variable is not set, .profile does not work
		export myOSID=${myOSID:-}
		AMD_SPO_ENV=${AMD_SPO_ENV:-} # make sure this variable is defined
		if [[ ! -x $PROFILE_DIR/.profile ]]
		then
			configAbort "$PROFILE_DIR/.profile is not executable by $configCurUser $configGroups"
		fi	

		. $PROFILE_DIR/.profile

		PATH=$PATH:$PROFILE_DIR/bin
		if [[ -z $AMD_SPO_ENV ]]
		then
			configThisFile=${0#$PROFILE_DIR/}
			case $configThisFile in
				bin/dev/amdconfig.ksh) export AMD_SPO_ENV=dev ;;
				bin/crp/amdconfig.ksh) export AMD_SPO_ENV=crp ;;
				bin/prd/amdconfig.ksh) export AMD_SPO_ENV=prd ;;
				*) configAbort "AMD_SPO_ENV did not get set"
			esac
		fi
		configIsExecutable $PROFILE_DIR/bin/$AMD_SPO_ENV
		PATH=$PATH:$PROFILE_DIR/bin/$AMD_SPO_ENV 
		export PATH
	fi
fi

export JRE=${JRE:-/opt/java1.4/jre}
configCheckDirectory $JRE

export AMD_HOME=${AMD_HOME:-/home/escmc172}
configCheckDirectory $AMD_HOME

export DATA_HOME=${DATA_HOME:-/data/escm_lb}
configIsWritable $DATA_HOME
if  [[ ! -w $DATA_HOME ]]
then
	configAbort "$DATA_HOME is not a writable directory for $configCurUser $configGroups"
fi

export SRC_HOME=${SRC_HOME:-$AMD_HOME/amd_tmp2xml}
configCheckDirectory $SRC_HOME

export BIN_HOME=${BIN_HOME:-$AMD_HOME/bin}
configCheckDirectory $BIN_HOME
if [[ ! -x $BIN_HOME ]]
then
	configAbort "$BIN_HOME is not an executable directory for $configCurUser $configGroups"
fi	

export AMDENV=${AMDENV:-}
if [[ $ENV = PRD || $configHostName = svappl61 ]]
then
	AMD_SPO_ENV=prd
fi
case $AMD_SPO_ENV in
	dev) AMDENV=dev 
	     export DB_CONNECTION_STRING_FOR_SPO=c17pgm@stl_descm/C1e3dc1c
	     export DB_CONNECTION_STRING=bsrm_loader@AMDD/fromnewyork;;
	crp) AMDENV=it
	     export DB_CONNECTION_STRING_FOR_SPO=c17pgm@stl_tescm/C1e3dc1c
	     export DB_CONNECTION_STRING=bsrm_loader@AMDI/fromnewyork;;
	prd) AMDENV=prod 
	     export DB_CONNECTION_STRING_FOR_SPO=c17pgm@stl_pescm/C1e3dc1c
	     export DB_CONNECTION_STRING=bsrm_loader@AMDP/fromnewyork;;
	*) configAbort "AMD_SPO_ENV=$AMD_SPO_ENV must be dev, crp, or prd" ;;
esac

if [[ ! -d $DATA_HOME/xml ]]
then
	mkdir $DATA_HOME/xml
	chgrp dstagelb $DATA_HOME/xml
	chmod g+w $DATA_HOME/xml

fi
if [[ ! -d $DATA_HOME/xml/$AMD_SPO_ENV ]]
then
	mkdir $DATA_HOME/xml/$AMD_SPO_ENV
	chgrp dstagelb $DATA_HOME/xml/$AMD_SPO_ENV
	chmod g+w $DATA_HOME/xml/$AMD_SPO_ENV
fi	
export XML_HOME=$DATA_HOME/xml/$AMD_SPO_ENV
configIsWritable $XML_HOME

# put the archive directory under the xml directory for now
if [[ ! -d $XML_HOME/archive ]]
then
	mkdir $XML_HOME/archive
	chgrp dstagelb $XML_HOME/archive
	chmod g+w $XML_HOME/archive
fi
export ARCH_HOME=$XML_HOME/archive
configIsWritable $XML_HOME

if [[ ! -d $DATA_HOME/log ]]
then
	mkdir $DATA_HOME/log
	chgrp dstagelb $DATA_HOME/log
	chmod g+w $DATA_HOME/log
fi
# define a log area for each environment
if [[ ! -d $DATA_HOME/log/$AMD_SPO_ENV ]]
then
	mkdir $DATA_HOME/log/$AMD_SPO_ENV ]]
	chgrp dstagelb $DATA_HOME/log/$AMD_SPO_ENV
	chmod g+w $DATA_HOME/log/$AMD_SPO_ENV
fi
export LOG_HOME=$DATA_HOME/log/$AMD_SPO_ENV
configIsWritable $LOG_HOME

DateStr="+%Y"
export DateStr="$DateStr%m%d%H:%M:%S"

export TimeStamp=`date +%Y%m%d%H:%M:%S`
export myenv=${AMD_SPO_ENV:-} # maintain until myenv is removed from all scripts

