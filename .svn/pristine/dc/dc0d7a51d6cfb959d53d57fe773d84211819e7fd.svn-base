# vim: ff=unix:ts=2:sw=2:sts=2:autoindent:smartindent:expandtab 
# calcTimeDiff.pl
# Author: Douglas S Elder
# Date: 1/1/2010
# Desc: scan a log and calculate the average and maxium
#       execution times for each app
use POSIX ;
use strict ;
use warnings;
use Getopt::Long;

use Date::Manip;

my $beginning = 'Oct 25 17:37:58 2007';
my $end       = 'Oct 26 06:54:09 2007';

my $diff = DateCalc($beginning, $end);
my %max ;
my %maxTimeStamp ;
my %avg ;
my $csvFlag;
my $dSubStep;

my $systemTotal = 0 ;
my $systemCnt = 0 ;
my $prevSystem = "" ;
my $system = "" ;
my $timeStamp = "" ;
my $dflag = "" ;
my $optionalstring = "" ;

my %mon2num = qw(
  jan 1  feb 2  mar 3  apr 4  may 5  jun 6
  jul 7  aug 8  sep 9  oct 10 nov 11 dec 12
);

# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub convert_time {
  my $time = shift;
  my $days = int($time / 86400);
   $time -= ($days * 86400);
  my $hours = int($time / 3600);
   $time -= ($hours * 3600);
  my $minutes = int($time / 60);
  my $seconds = $time % 60;

  $days = $days < 1 ? '' : $days . ":" ;
  $hours = $hours < 1 ? '00:' : sprintf("%02d",$hours)  . ":";
  $minutes = $minutes < 1 ? '00:' : sprintf("%02d",$minutes) . ":" ;
  $time = $days . $hours . $minutes . sprintf("%02d",$seconds) ;
  return $time;
}

GetOptions("d"=>\$dflag, "c"=>\$csvFlag, "s:s"=>\$dSubStep,
            "optional:s",\$optionalstring) ;

my @lines = <STDIN> ;
while (@lines) {
	my $line1 =  shift @lines ;
	chomp($line1);
	if ($dflag) {
		print "line=*$line1*\n";
	}
	if ($line1 =~ m/(.*?)started at/) {
		my $filename = $1 ;
		if ($dflag) {
			print "filename=$filename\n" ;
		}
		if (index($filename,':') > 0) {
			($filename, $system) = split(":",$filename) ;
			if ($dflag) {
				print "0. filename=$filename system=$system\n" ;
			}
			$system = trim($system) ;
			if (index($system," ") > 0) {
				(my $count, $system) = split(" ",$system) ;
			}
			if ($dflag) {
				print "1. system=$system\n" ;
			}
		} elsif (index($filename,$1) > 0 && index($filename," ")  > 1) {
				$system = substr($filename,0,length($1)) ;
		} else {
			$filename =~ s/ /_/ ;
			$system = $filename ;
		}
		if ($dflag) {
			print "2. system=$system substr=" . substr($line1, length($1),length($line1) - length($1)) . "\n" ;
		}
		(my $when,my $at,my $weekday,my $mon, my $day, my $time, my $zone, my $year)
	       		= split(" ",substr($line1, length($1),length($line1) - length($1)));

		(my $hr,my $min,my $sec) = split(":",$time) ;
		$beginning = ParseDate("$weekday $mon $day $time $zone $year") ;
		my $beginSecs = mktime($sec, $min, $hr, $day, $mon2num{lc $mon} - 1, $year - 1900, 0, 0) ;
		$line1 =  shift @lines ;
    next if grep { !defined } $line1; 
		chomp($line1);
		if ($line1 =~ m/(.*?)ended at/) {
			(my $when,my $at,my $weekday,my $mon, my $day, my $time, my $zone, my $year)
	       			= split(" ",substr($line1, length($1),length($line1) - length($1)));
			if ($filename =~ m/^\d+/) {
				$timeStamp = substr $filename, 0,16 ;
			} else { 
				$timeStamp = "" ;
			}
			$end = ParseDate("$weekday $mon $day $time $zone $year") ;
			($hr,$min,$sec) = split(":",$time) ;
			my $endSecs = mktime($sec, $min, $hr, $day, $mon2num{lc $mon} - 1, $year - 1900, 0, 0) ;
			my $durationSecs = $endSecs - $beginSecs ;
			if ($durationSecs > 0) {
				my $readableTime = localtime($durationSecs);
				$diff = DateCalc($beginning, $end);
				my $diffHr = Delta_Format($diff,0,"%hv") ;
				my $diffMin = Delta_Format($diff,0,"%mv") ;
				my $diffSec = Delta_Format($diff,0,"%sv") ;
				my $theDate = UnixDate($diff,"%H:%M:%S") ;
				my $diffX = Delta_Format($diff,2,"%md") ;
				if ($dflag) {
					print "$end - $beginning = $diff, diffHr=$diffHr diffX=$diffX or theDate=$theDate\n ";
					print "$diffHr:$diffMin:$diffSec\n" ;
					print convert_time($durationSecs) . " durationSecs=$durationSecs readableTime=$readableTime\n" ;
				}
				if ($diffHr > 0) {
					$diffX = $diffX + ($diffHr * 60) ;
				}
				if (exists($max{$system})) {
					if ($max{$system} < $durationSecs) {
						$max{$system} = $durationSecs ;
						$maxTimeStamp{$system} = $timeStamp ;
					}
				} else {
					$max{$system} = $diffX ;
				}
				if ($system ne $prevSystem) {
					$avg{$system} = $systemTotal / $systemCnt if $systemCnt > 0 ;
					$systemTotal = 0 ;
					$systemCnt = 0 ;
					$prevSystem = $system ;
				} 
				$systemCnt++ ;
				$systemTotal = $systemTotal + $durationSecs ;
				if ($dflag) {
					print "$filename $system $diff ($diffX)\n" ;
				}
			}
		}
	}
}
if ($systemCnt > 0) {
	$avg{$system} = sprintf("%.2f", $systemTotal / $systemCnt)  ;
	my $theAvg = "no avg" ;
	if (exists($avg{$system})) {
		$theAvg = convert_time($avg{$system}) ;
	}
	my $theMax = "no max" ;
	my $theMaxTimeStamp = "no time stamp" ;
	if (exists($max{$system})) {
		$theMax = convert_time($max{$system}) ;
	}
	if (exists($maxTimeStamp{$system})) {
		$theMaxTimeStamp = $maxTimeStamp{$system} ;
	}
	if (defined($system) && defined($theAvg) && defined($theMax) && defined($theMaxTimeStamp)) {
		printf("%30s: average is %s max value is %s for %s\n",$system, $theAvg, $theMax, $theMaxTimeStamp)  ;
	} else {
		print STDERR "theAvg not defined for $system\n" if ! defined($theAvg) ;
		print STDERR "theMax not defined for $system\n" if ! defined($theMax) ;
		print STDERR "theMaxTimeStamp not defined for $system\n" if ! defined($theMaxTimeStamp) ;
		print STDERR "variable not defined for $system\n" ;
	}
}
