THIS=$(basename $0)
APP=$(echo $THIS | cut -d. -f1)
HOME=/apps/CRON/AMD
DATA=$HOME
DEBUG_FILE=$DATA/debug.txt
if [[ -f $DEBUG_FILE ]] ; then
  DEBUG=$(cat $DEBUG_FILE)
else
  DEBUG=N
fi
[[ "$DEBUG" == "Y" ]] && set -x
