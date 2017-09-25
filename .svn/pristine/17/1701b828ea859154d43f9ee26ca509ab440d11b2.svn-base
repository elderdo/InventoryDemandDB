#!/usr/bin/perl

# Akadia AG, Arvenweg 4, CH-3604 Thun                 send_attachment.pl
# ----------------------------------------------------------------------
#
# File:       send_attachment.pl
#
# Autor:      Martin Zahn / 05.01.2003
#
# Purpose:    Email attachments in Perl
#
# Location:   $ORACLE_HOME\Database
#
# Certified:  Perl 5.6.1, MIME-Lite-2.117 on Cygwin / Windows 2000
# ----------------------------------------------------------------------

use MIME::Lite;
use Net::SMTP;
use Getopt::Std;

my %Options;
my $ok = getopts('a:f:s:m:o:',\%Options);

my $message_body = "Attached is the bad qty file." ;
if ($Options{'m'} != "") {
 $message_body = $Options{'m'} ;
}

my $subject = "PRIMSA bad data" ;
if ($Options{'s'} != "") {
 $subject = $Options{'s'} ;
}

### Adjust sender, recipient and your SMTP mailhost
my $from_address = 'primsa@unixserver.com';
my $to_address = 'Douglas.S.Elder@boeing.com';
my $mail_host = 'mail.boeing.com';


### Adjust the filenames
my $my_file = '/tmp/bad.txt';
if ($Options{'f'} != "") {
	$my_file = $Options{'f'} ;
}
my $your_file = 'badQty.txt';
if ($Options{'o'} != "") {
	$your_file = $Options{'o'} ;
}

### Create the multipart container
$msg = MIME::Lite->new (
  From => $from_address,
  To => $to_address,
  Subject => $subject,
  Type =>'multipart/mixed'
) or die "Error creating multipart container: $!\n";

### Add the text message part
$msg->attach (
  Type => 'TEXT',
  Data => $message_body
) or die "Error adding the text message part: $!\n";

### Add the GIF file
$msg->attach (
   Type => 'text/plain',
   Path => $my_file,
   Filename => $your_file,
   Disposition => 'attachment'
) or die "Error adding $file: $!\n";

### Send the Message
MIME::Lite->send('smtp', $mail_host, Timeout=>60);
$msg->send; 


