#!/bin/sh
# Default user .profile file (/usr/bin/sh initialization).
#   $Author:   zf297a  $
# $Revision:   1.3  $
#     $Date:   09 May 2008 12:37:54  $
# $Workfile:   .profile  $
# This profile script is used by the escmc172 account for interfacing
# to the St Louis SCM system

FROM_TRIGGER=no
#echo "TERM is '"$TERM"'"
# Set up the terminal:
if [ "$TERM" = "" ]
then
  #eval ` tset -s -Q -m ':?hp' `
  echo ""
  FROM_TRIGGER=yes
else
  eval ` tset -s -Q `
  stty erase "^H" kill "^U" intr "^C" eof "^D"
  stty hupcl ixon ixoff
  tabs
  resize
fi

# Set up the search paths:
PATH=$PATH:.:$HOME/bin

# Set up the shell environment:
set -u
trap "echo 'logout'" 0

# Set up the shell variables:
EDITOR=vi
export EDITOR

export ESCM_SCRATCH=/scratch/ESCM_LB/io_files
export ESCMXML=/data/escm_lb/xml
export ESCM_DEV=/data/imacs_dev/ai_dev/src/escmv2
export ESCM_CRP=/data/imacs_dev/ai_crp/src/escmv2
export HOSTNAME=`uname -n`
uptime

case "$HOSTNAME"
  in
    svdbms32|dbmsdv01|smrs085a|svappl50) export ENV="DEV";;
    svdbms29|svappl60|svappl61) export ENV="PRD";;
    *) export ENV="DEV";;
esac
clear

echo "Environment set to " $ENV

#. /usr/local/mq/adm/QMC1HA02_setup.sh

export ORACLE_HOME=/usr/oracle_db9.2.0

# Setup MQ Queue Variables
# define and export myenv variable used during interactive login and with remsh's
profileHostname=`uname -n`
# First attempt at phasing myenv out of all scripts.  myenv is not application
# specific and could easily be wiped out by some other script 
export AMD_SPO_ENV=${AMD_SPO_ENV:-} 
export myenv=${myenv:-$AMD_SPO_ENV} 
if [[ -z $AMD_SPO_ENV && $profileHostname = svappl61 ]]
then
	export AMD_SPO_ENV=prd
	export myenv=prd
fi

if [ $ENV = "DEV" ]
  then
    if [ $FROM_TRIGGER = "no" ]
      then
        until [ "$AMD_SPO_ENV" = "dev" -o "$AMD_SPO_ENV" = "crp" ] 
        do
          echo "\nPlease input your environment dev (descm) or crp (tescm): \c"
          read AMD_SPO_ENV
	  if [[ "$AMD_SPO_ENV" != "dev" && "$AMD_SPO_ENV" != "crp" ]] ; then
		  AMD_SPO_ENV=dev
		  print "defaulting to dev"
	  fi
	  myenv=$AMD_SPO_ENV # retain compatibility until all .ksh files are changed
	  if (( $# > 0 ))
	  then
	  	SAVEPARAMS=$*
	  else
		SAVEPARAMS=
	  fi
          . /home/escmc172/.profile2 -i DEV05 -e ${AMD_SPO_ENV}
	  if (( $# > 0 ))
	  then
	  	set -- $SAVEPARAMS # restore positional params
	  fi
          export PROPDIR=/data/imacs_dev/ai_"$AMD_SPO_ENV"/properties
          export SSLPROPFILE=$DEV05/ai_"$AMD_SPO_ENV"/properties/Escmv2LBSSL.properties
        done
    else
 #       . /data/imacs_dev/ai_scripts/profile.sh -i DEV05 -e crp
 	 # use an explicit name, since this could be executed from
	 # the home directory of amGuser when this script gets invoked via
	 # remsh from a Long Beach unix machine
	case $AMD_SPO_ENV in
		dev) ENVIRON=$AMD_SPO_ENV ;;
		crp) ENVIRON=$AMD_SPO_ENV ;;
		prd) ENVIRON=$AMD_SPO_ENV ;;
		*) print -u2 "AMD_SPO_ENV=$AMD_SPO_ENV is invalid, it must be dev, crp, or prd"
		   exit 4 ;;
	esac
	 if (( $# > 0 ))
	 then
	 	SAVEPARAMS=$*
	  else
		SAVEPARAMS=
	 fi
         . /home/escmc172/.profile2 -i DEV05 -e ${AMD_SPO_ENV}
	 if (( $# > 0 ))
	 then
	 	set -- $SAVEPARAMS # restore positional params
	fi
        export PROPDIR=/data/imacs_dev/ai_"$AMD_SPO_ENV"/properties
        echo "PROPDIR="$PROPDIR
        export SSLPROPFILE=$DEV05/ai_"$AMD_SPO_ENV"/properties/Escmv2LBSSL.properties
        echo "SSLPROPFILE="$SSLPROPFILE
    fi
    ENVIRON=${ENVIRON:-$AMD_SPO_ENV}
    if [ $ENVIRON = "dev" ]
    then
      export MQCHANNEL=QMT1ESCMC172
      export MQMGR=QMT1HA02
      echo "Setting stl_descm"
      export ORACLE_SID=descm
    else
      MQCHANNEL=QMC1ESCMC172;export MQCHANNEL
      MQMGR=QMC1HA02;export MQMGR
      echo "Setting stl_tescm"
      ORACLE_SID=tescm;export ORACLE_SID
      echo "ORACLE_SID="$ORACLE_SID
      echo "MQCHANNEL="$MQCHANNEL
      echo "MQMGR="$MQMGR
    fi
    JAVA_HOME=/opt/java1.5

else
    #. /home/escmC172/sh/profile.sh -i PRD01 -e prd
    #. /data/imacs_prd/ai_scripts/profile.sh -i PRODSUP01 -e prd
    if (( $# > 0 ))
    then
    	SAVEPARAMS=$*
    else
	SAVEPARAMS=
    fi
    . /home/escmc172/.profile2 -i PRODSUP01 -e prd
    if (( $# > 0 ))
    then
    	set -- $SAVEPARAMS # restore positional params
    fi
    export ORACLE_SID=escmpd01
    export PROPDIR=/data/imacs_prd/ai_prd/properties
    #export SSLPROPFILE=$AI_DIR/ai_prd/properties/Escmv2LBSSL.properties
    export SSLPROPFILE=$AI_DIR/ai_prd/properties/Escmv2LBSSL.properties 
    export MQCHANNEL=QMP1ESCMC172
    export MQMGR=QMP1HA01
    echo "ORACLE_SID2="$ORACLE_SID
    echo "PROPDIR="$PROPDIR
    echo "SSLPROPFILE2="$SSLPROPFILE
    echo "MQCHANNEL2="$MQCHANNEL
    echo "MQMGR2="$MQMGR
fi
#if [ $HOSTNAME = "svappl50" -o $HOSTNAME = "svappl61" ]
#then
#  JAVA_HOME=/opt/java1.4
#  CLASSPATH=$CLASSPATH:$AI_ENV_JAR/escmv2/escmv2_1.4.jar
#else
  JAVA_HOME=/opt/java1.5
  CLASSPATH=$CLASSPATH:$AI_ENV_JAR/escmv2/escmv2.jar
#fi

export ESCMXML=$ESCMXML/$AMD_SPO_ENV
export ID=`whoami`
export PS1='[$ID($ENVIRON)@$HOSTNAME:$PWD]$ '
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH:$HOME/bin/$ENVIRON
export CLASSPATH=$AI_ENV_JAR/escmv2/xschema.jar:$AI_ENV_JAR/escmv2/xmlparserv2.jar:$AI_ENV_JAR/escmv2/log4j.jar:$CLASSPATH:$HOME/bin:$HOME/lib/bigdate45.zip:$AI_ENV_JAR/escmv2/jdom.jar:/opt/java1.5

export ENVPROP=${ENVPROP}escm/
export SSLPROPFILE=${ENVPROP}Escmc172SSL.properties

#echo "PATH="$PATH
#JAVA_HOME=/opt/java1.5;
#echo "JAVA_HOME="$JAVA_HOME
#echo "CLASSPATH="$CLASSPATH

# import aliases
# must use explicit path for the remsh to work
if [ $ENV = "DEV" ]
then
  if [ $ENVIRON = "dev" ]
  then 
    . /home/escmc172/.alias_dev
  else
    . /home/escmc172/.alias_crp
  fi
else
  . /home/escmc172/.alias
fi
