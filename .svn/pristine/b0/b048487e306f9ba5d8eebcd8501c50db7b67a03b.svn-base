#!/usr/bin/perl
# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

my $line = "" ;
my $cnt = 0 ;
while (defined($line = <STDIN>)) {
  $cnt++ ;
	my $qty = substr $line, 106,9;
	if (trim($qty) =~ /^\d+$/ && trim($qty) > 0) {
  	print $line
	} else {
		my $kit = substr $line,0,20;
		my $part = substr $line,86,20;
	  printf STDERR "record: %5d kit: $kit part: $part bad qty: <$qty>\n", $cnt  ;
	}
}
