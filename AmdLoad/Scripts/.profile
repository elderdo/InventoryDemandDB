#!/usr/bin/ksh
# vim: ts=2:sw=2:sts=2:expandtab:
# @(#) $Revision: 72.2 $      

# Default user .profile file (/usr/bin/sh initialization).

# Set up the terminal:
    if tty -s ; then
	    if [ "$TERM" = "" ]
	    then
	    	eval `tset -s -Q`
	    fi
      if [ "$TERM" = "xterm" ]
      then
        stty erase "^?"
      else
        stty erase "^H" kill "^U" intr "^C" eof "^D"
      fi
  		stty hupcl ixon ixoff
  		#tabs
    fi

# Set up the search paths:
	export PATH=$PATH:.
  export JAVA_HOME=/opt/java1.5
  export ORACLE_SID=db0093d1
  export ORACLE_HOME=/opt/oracle/app/oracle/product/12.1.0/client_1
  export PATH=$PATH:$ORACLE_HOME/bin:$JAVA_HOME/bin:. 

# Set up the shell environment:
	set -u
	trap "echo 'logout'" 0

# Set up the shell variables:
	EDITOR=vi
	export EDITOR
	export UNVAR=~amduser/zf297a
	export PATH=$PATH:~/bin
	export PATH=$PATH:~amdadmn/bin
	export PATH=$PATH:/apps/CRON/AMD/bin:/apps/CRON/AMD/lib
	export ENV=~/.kshrc
	#cd $UNVAR
	export UNVAR=
  alias home="cd /home/amd/amduser"
  alias kchome="cd /apps/CRON/KC46"
  alias kcbin="cd /apps/CRON/KC46/bin"
  alias kcsrc="cd /apps/CRON/KC46/src"
  alias kclog="cd /apps/CRON/KC46/log"
  alias kclib="cd /apps/CRON/KC46/lib"
  alias kcdat="cd /apps/CRON/KC46/data"

  alias amhome="cd /apps/CRON/AMD"
  alias amsrc="cd /apps/CRON/AMD/src"
  alias ambin="cd /apps/CRON/AMD/bin"
  alias amlog="cd /apps/CRON/AMD/log"
  alias amdat="cd /apps/CRON/AMD/data"
  alias amlib="cd /apps/CRON/AMD/lib"

  alias rmhome="cd /apps/CRON/RMADS"
  alias rmbin="cd /apps/CRON/RMADS/bin"
  alias rmlog="cd /apps/CRON/RMADS/log"
  alias rmsrc="cd /apps/CRON/RMADS/src"
  alias rmdat="cd /apps/CRON/RMADS/data"
  alias rmlib="cd /apps/CRON/RMADS/lib"
  alias wr="ps -elf -u amduser | grep amduser > /tmp/wr && vi /tmp/wr && rm /tmp/wr"
  alias prof="vi /home/amd/amduser/.profile && . /home/amd/amduser/.profile"

CWD=$(pwd)
if echo "$CWD" | grep -i -q "amd" ; then
  export BIN=/apps/CRON/AMD/lib
elif echo "$CWD" | grep -i -q "rmad" ; then
  export BIN=/apps/CRON/RMAD/bin
fi

function edl {
  if (($#==0)) ; then
    n=1
  else
    n=$1
  fi
  $BIN/edit_load_logs.ksh -n $n
}

function edi {
  if (($#==0)) ; then
    n=1
  else
    n=$1
  fi
  $BIN/edit_loadInventory_logs.ksh -n $n
}

  alias curlog="ls -t /apps/CRON/AMD/log/$(date +%Y%m)[1-31]* | head -n 50 | more"
  alias curdif="ls -t /apps/CRON/AMD/log/$(date +%Y%m)[1-31]*Diff* | head -n 22 | more"
function dbconn {
  sqlplus $DB_CONNECTION_STRING $1
}

function scanlog {
  curdir=`pwd`
  cd /apps/CRON/AMD/log
  scanLog.ksh
  cd $curdir
}
  . /apps/CRON/AMD/lib/amdenv.ksh
  . /apps/CRON/AMD/lib/amdconfig.ksh
  . /apps/CRON/AMD/lib/DB_CONNECTION_STRING
  set -o vi
  umask 007
  amhome
  pwd
