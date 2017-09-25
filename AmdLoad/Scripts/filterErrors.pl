#!/usr/bin/perl
# This script scans a log for Oracle errors
# that are not critical and removes
# them from the log 
use strict;
use warnings;

my @search_for;
# open file of errors to filter out
if ($#ARGV == 2) {
  open(FILE, $ARGV[1]); 
	if (fileno(FILE)) {
		# read filters into an array
		@search_for = <FILE>;
		# close log file 
		close(FILE);
	} else {
		# default search array
		@search_for = ("unique constraint");
	}
} else {
  @search_for = ("unique constraint");
}


# open log file
open(FILE, $ARGV[0]) or die("Unable to open file");
# read log file into an array
my @data = <FILE>;
# close log file 
close(FILE);

my $index;
my $search_text;
my $i;
# process all text to be filtered
foreach (@search_for) {
	chomp;
	$search_text = $_ ;
	$search_text =~ s/\r$//;
	# remove all matching errors 
	while ( ( $index )= grep { $data[$_] =~ $search_text } 0..$#data ) { 
		my $lastErrorIndx = 0 ;
		for ($i=$index+1;$i<$#data && $data[$i] =~ "^ORA-";$i++) {
		  $lastErrorIndx = $i ;
			#print "i=$i\n" ;
		} ;
		my $firstErrorIndx = ($data[$index-1] =~ "ERROR at line 1:") ? ($index - 1) : $index ;
		my $len = ($lastErrorIndx > 0 && $lastErrorIndx > $firstErrorIndx) ? ($lastErrorIndx - $firstErrorIndx + 1) : 1 ; 
		# remove all the Oracle error messages associated with the current error
		my @errorMessages = splice(@data, $firstErrorIndx, $len); 
	}
}
# write out new log
foreach (@data) {
  print $_ ;
}
