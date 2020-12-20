#!C:\NDAT\bin\Perl\perl\bin\perl.exe

use strict;
use warnings;

use Cwd;
use DateTime;

my ($rcgen,$year,$month,$day,$i,$j,$k,$startVal,$nowDT,$const_fourAddNum,$maxIter,$male,$female,
   $currentDir,$filename);
my (@allRCs,@allAccNmb);

my @usrYears = (75,82,88,92,99,98,2011);
$const_fourAddNum = "4215";
$maxIter = 100;

$nowDT = DateTime->now();
$currentDir = getcwd();

$year = $nowDT->year;
$month = $nowDT->month;
$day = $nowDT->day;
$k = $month+50;

$filename = $currentDir."\\"."$year$month$day"."_rcgenerated.txt";


foreach $year (@usrYears)
{
	  $male = "$year$month$day"."$const_fourAddNum";
	  $female = "$year$k$day"."$const_fourAddNum";

	  for($i=0;$i<$maxIter;$i++)
	  {
			 do
			 {
					$male++;
			 }while($male%11 != 0);

			 do
			 {
					$female++;
			 }while($female%11 != 0);
	  
			 push @allRCs,$male."\t".$female."\n";

	  }
}

open(FINALFL,">>$filename") or die "File $filename coudn't create";
foreach(@allRCs)
{
	  print FINALFL $_;
}
