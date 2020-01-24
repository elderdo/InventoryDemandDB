#!/bin/ksh
var1=`echo $$`
echo "k2.sh pid => " $var1 ## Just for checking. Will be erased...
echo "Listing processes with the k2.sh pid" ## Just for checking. Will be erased...
ps -ef | grep $var1 ## Just for checking. Will be erased...
v=`ps -ef | grep $var1 | sort +1 -2 | cut -d" " -f4 | head -1`
print "v=$v"
echo "k2.sh parent process => "$v ## Just for checking. Will be erased...
echo "Listing processes with the k2.sh parent process" ## Just for checking. Will be erased...
ps -ef | grep $v ## Just for checking. Will be erased...
echo "The parent process..." ## Just for checking. Will be erased...
ps -ef | grep $v | sort | head -1 | cut -d" " -f13

ps -ef | grep $PPID | sort | head -1 | awk '{ print $NF }'

echo "PPID=$PPID"

getParentScript() {
	PARENT_SCRIPT=`ps -ef | grep $PPID | sort | head -1 | awk '{ print $NF }'` # get parent script
	if [[ "$PARENT_SCRIPT" != "ksh" ]] ; then
		PARENT_SCRIPT=`basename $PARENT_SCRIPT` # remove path
		PARENT_SCRIPT=${PARENT_SCRIPT%\.*} # remove file extension
	else
		PARENT_SCRIPT=
	fi
	return $PARENT_SCRITP
}



PARENT_SCRIPT=`ps -ef | grep $PPID | sort | head -1 | awk '{ print $NF }'` # get parent script
print "PARENT_SCRIPT=$PARENT_SCRIPT"
if [[ $PARENT_SCRIPT != ksh ]] ; then
	PARENT_SCRIPT=`basename $PARENT_SCRIPT` # remove path
	print "PARENT_SCRIPT=$PARENT_SCRIPT"
	PARENT_SCRIPT=${PARENT_SCRIPT%\.*} # remove file extension
	print "PARENT_SCRIPT=$PARENT_SCRIPT"
else
	PARENT_SCRIPT=
fi


DATA_HOME=../data
OVERRIDE_FILE=$DATA_HOME/trimTactics${PARENT_SCRIPT:+_${PARENT_SCRIPT}}.txt
print OVERRIDE_FILE=$OVERRIDE_FILE

#script=`ps -ef | grep $PPID | sort | head -1 | awk '{ print $NF }'`
#file=`basename $script`
#print ${file%\.*}



