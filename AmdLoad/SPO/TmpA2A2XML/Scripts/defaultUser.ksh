#/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   Nov 21 2005 13:46:02  $
# $Workfile:   defaultUser.ksh  $
# Using prebuilt xml that is stored in the amd home directory create a
# default user and the planner that goes with it.
USAGE="usage: defaultUser.ksh [-q queue_name] [-h home_directory] [-u defaultuser_xml] [-p defaultplanner_xml]" # switch arguments
while getopts :f:q:x: arguments
do
	case $arguments in
	  u) DEF_USER=$OPTARG;;
	  p) DEF_PLANNER=$OPTARG;;
	  h) AMD_HOME=$OPTARG;;
	  q) queuename=$OPTARG ;;
	  :) print "You forgot to enter an argument for $OPTARG"
	     exit 4;;
	  \?) print "OPTARG$ is not a valid switch."
	     print "$USAGE"
	     exit 4;;
	esac
done
# OPTIND now contains a numnber representing the identity of the first
# nonswitch argument on the command line.  For example, if the first
# nonswitch argume on the command line is positional parameter $<F5>,
# OPTIND hold the number 5.
((positions_occupied_by_switches = OPTIND - 1))
# Use a shift statement to eliminate all switches and switch arguments
# from the set of positional parameters.
shift $positions_occupied_by_switches
# After the shift, the set of positional parameter contains all
# remaining nonswitch arguments.
queuename=${queuename:-LBC17V2} # default not to queue xml file
DEF_USER=${DEF_USER:-RichelleBodine}
DEF_PLANNER=${DEF_USER:-RJBplanner}
AMD_HOME=${XML_HOME:-~/amd_tmp2xml}
XML_HOME=${XML_HOME:-/scratch/ESCM_LB/io_files/xml}

cd ${BIN_HOME:-~/bin}

function sendXml {
		runEnqueue.sh -q $queuename -i $AMD_HOME/$1.xml
}
##########################################################################
# The script begins execution at the next line

  sendXml RichelleBodine
  sendXml RJBplanner
