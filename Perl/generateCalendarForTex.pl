#!C:\NDAT\bin\Perl\bin\perl.exe

#packages
use strict;
use warnings;

#to get execute file path
use File::Basename;
use DateTime qw();


###### PROPERTY ###### 
my $dirname = dirname(__FILE__);
my ($outfile);

#my $actualDate = DateTime->now;

my ($start_sec,$start_min,$start_hour,$start_day,$start_month,$start_year);
my ($stop_sec,$stop_min,$stop_hour,$stop_day,$stop_month,$stop_year);
my $timezone = 'Europe/Prague';

##### START DATE #####
$start_day = 1;
$start_month = 1;
$start_year = 2021;
$start_hour = 00;
$start_min = 00;

##### STOP DATE #####
$stop_day = 31;
$stop_month = 12;
$stop_year = 2021;
$stop_hour = 00;
$stop_min = 00;


###### MAIN START ######
my $startDate = DateTime->new(
	    year      => $start_year,
	    month     => $start_month,
	    day       => $start_day,
	    hour      => $start_hour,
	    minute    => $start_min,
	    time_zone => $timezone,
);


my $stopDate = DateTime->new(
	    year      => $stop_year,
	    month     => $stop_month,
	    day       => $stop_day,
	    hour      => $stop_hour,
	    minute    => $stop_min,
	    time_zone => $timezone,
);

$outfile="$dirname\\$start_year$start_month$start_day"."_calendar.tex";
open(OUTFILE,">>$outfile") or die "Error with open file $outfile";

do
{	
	print OUTFILE "\\newdate{den",$startDate->strftime('%d'),	#day
								  $startDate->strftime('%m'),	#month
								  $startDate->strftime('%y'),	#year 
								  "}{",
								  $startDate->strftime('%d'),	#day 
								  "}{",
								  $startDate->strftime('%m'),	#month 
								  "}{",
								  $startDate->year,
								  "} % ",
								  $startDate->strftime('%A %d %B %Y'),
								  "\n";
						  
	$startDate = $startDate + DateTime::Duration->new( days => 1 );
		
}while($startDate <= $stopDate);

close(OUTFILE);
	
print "Execute done!\n";


exit 0;


#open(OUTFILE,">>$outfile") or die "Error with open file $outfile";

#foreach (@results){
#	print $_;
#	print OUTFILE $_;
#}

#close(OUTFILE);