#/usr/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.0  $
#     $Date:   Feb 09 2006 08:33:44  $
# $Workfile:   splitFile.ksh  $
# This script splits a file into 2 or more files with suffixes ranging from aa to zz
USAGE="usage: ${0##*/} [-n num_of_files] [-s filesize] filename\n\twhere -n num_of_files can be any integer from 2..max\n\t-s filesize is the number of records in the input file.\n\t\tIf not supplied the size is calculated.\n\t\tThe script runs fater if the filesize is supplied\n\n\tfilename is the name of the file to split" # switch arguments
while getopts :n:s: arguments
do
	case $arguments in
	  n) num_of_files=$OPTARG;;
	  s) filesize=$OPTARG;;
	  :) print -u2 "You forgot to enter an argument for $OPTARG"
	     exit 4;;
	  \?) print -u2 "$OPTARG is not a valid switch."
	     print -u2 "$USAGE"
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
num_of_files=${num_of_files:-2} # default not to queue xml file
if [[ -z $1 ]]
then
	print -u2 "filename is required"
	print -u2 $USAGE
	exit 4
fi
split -l $(( ${filesize:-`cat $1 | wc -l`} / $num_of_files)) $1 $1
