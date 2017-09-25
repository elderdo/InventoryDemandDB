#!/bin/ksh
#   $Author:   zf297a  $
# $Revision:   1.1  $
#     $Date:   Dec 14 2005 09:21:02  $
# $Workfile:   fileInfo.ksh  $
# fileInofo: list files and total size and average size in bytes
ls -l $* | awk '

#1 output column headers
BEGIN { print "BYTES" "\t\t" "FILE"
}#2 test for 9 fields; files begin with "-"
NF == 9 && /^-/ {
	sum += $5 	# accumulate size of file
	++filenum	# count number of files
	print $5,"\t",$9	# print size and filename
}

#3 test for 9 fields; directory begins with "d"
NF == 9 && /^d/ {
	print "<dir>", "\t", $9 # print <dir> and name
}

#4 test for ls -lR line ./dir:
$1 ~ /^..*:$/ {
	print "\t" $0 # print that line preceded by tab
}

#5 once all is done,
END {
	#print total file size, average size and number of files
	printf("Total: %d bytes ( %d  files)\n", sum, filenum)
	printf("Average: %d bytes\n", sum / filenum)
}' -


