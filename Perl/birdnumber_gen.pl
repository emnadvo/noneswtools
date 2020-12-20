#!C:\NDAT\bin\Perl\bin\perl.exe

use strict;
use warnings;

#to get execute file path
use File::Basename;
my $dirname = dirname(__FILE__);

#@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
#@days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$tempVal);
my ($startNum,$additionalFour,$i,$j,$k,$m,$maxiter,$outfile,$lcYear,$oldmon);
my @results;
my @accnumbs;
my @initYears = (73,82,85,95,99,5);

$maxiter=50;
$additionalFour=2542;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year-=2000-1900;

#print "Year: ".$year." Month: ".$mon." Day: ".$mday;

if($mon < 10){ $mon = "0".$mon; }
if($mday < 10){ $mday = "0".$mday; }

$outfile="$dirname\\$year$mon$mday"."_RCgenerat.txt";
$oldmon = $mon;
foreach $lcYear (@initYears)
{
	$mon = $oldmon;
	
	if($lcYear < 10){$lcYear = "0".$lcYear;}

	$j = "$lcYear$mon$mday$additionalFour";
	$k = "2200032559";
	$mon += 50;
	$m = "$lcYear$mon$mday$additionalFour";

#	print "Init year (M) is".$j;
#	print "Init year (F) is".$m;

	for($i=0;$i<$maxiter;$i++)
	{
		if($j%11 != 0)
		{
			do
			{
				$j++;
			}while($j%11 != 0)
			
		}

		if($k%11 != 0)
		{
			do
			{
				$k++;
			}while($k%11 != 0)
		}

		if($m%11 != 0)
		{
			do
			{
				$m++;
			}while($m%11 != 0)
		}

		if($j%11 == 0 && $k%11 == 0 && $m%11 == 0)
		{
			$tempVal = $j."\t".$m."\t".$k;
			if(length($tempVal) < 10){$tempVal = "0".$tempVal;}
			push @results,($tempVal."\n");
			$k++,$j++,$m++;
		}

	}
}

open(OUTFILE,">>$outfile") or die "Error with open file $outfile";

foreach (@results){
	print $_;
	print OUTFILE $_;
}

close(OUTFILE);
