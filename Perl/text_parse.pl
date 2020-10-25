#!/usr/bin/perl

#########################################
#
#	filename: 		text_parse.pl
#	author:			Michal Nadvornik
#	description:	Script parse content of file 
#					
#
#########################################

# important modules
use strict;
use warnings;

use File::Find;
use File::Basename;
use File::Copy "cp";
use Cwd;
use Text::CSV "csv";
use Data::Dumper qw(Dumper);

sub ltrim($);

my $sourcedir="C:\\SPWRData\\Doopex_LSN0\\EXPORT_DOOPEX";

my (@allcases,@allParseData,@parseLine,$filename,@radiusline);
my ($line,@items,$it,$radID,$secID);
my ($pattern, $template, $delimiter,$resdir,$key,$subkey);
my $header = "#ID;X;Y;Z\n";
my $emptyline = "\n";
my $commentline = "# ".$emptyline;
my $lookforPattern = "[0-9]+_polomer_[0-9]+";
my $filenametempl = "OrderData_ID-(%s).dat";
my %allradius;
my %section;

# find all ini case file
find(\&look_for_asc_file, "$sourcedir");

sub look_for_asc_file 
{	
	# find all ini case file
	push @allcases, $File::Find::name if (/\.asc$/i);	
}

if ($#allcases == -1)
{
	print "Program don\'t find any asc file!\nProgram finished.";
	exit 0;
}

#parse all cases to separate blocks
foreach(@allcases)
{
	print "PROCESS FILE $_\n";
	
	open(NEWSOURCEFILE,"<$_") or die "Unknown file $allcases[0]!\nProgram aborted!";
	
	while ($line = <NEWSOURCEFILE>)
	{
		chomp($line);
		$line =~ tr/,/./;
		@parseLine = split(/\;/,$line);
#		print Dumper \@parseLine;
#		print $#parseLine."\n";
		
		if($#parseLine>0){
			@radiusline = split(/_/,$parseLine[0]);
			
			if($#radiusline != -1){
				$radID = $radiusline[0];
				$secID = $radiusline[$#radiusline];
			}
			else{
				$radID = $secID = 777;
			}
		}
		
		if(defined $allradius{$radID}{$secID})
		{
			@allParseData = @{$allradius{$radID}{$secID}};
		}
		
		push(@allParseData,($parseLine[($#parseLine-2)].";".$parseLine[($#parseLine-1)].";".$parseLine[$#parseLine]."\n"));
		
		$allradius{$radID}{$secID} = [@allParseData];	
		@allParseData = (); 

	}
	
}

#finally export filter data to new file
#@items = sort {$a <=> $b} keys %allradius;
#foreach(@items)
for $key (sort {$a <=> $b} keys %allradius)
{
#	print $key."\n";
	$filename = $sourcedir."\\".sprintf($filenametempl,$key);
	
	print "EXECUTE FILE $filename\n";
	open(FINALOUTPUT,">$filename") or die "Problem with new file creation!\nProgram aborted";	
	print FINALOUTPUT $header;
	
	for $subkey ( sort {$a <=> $b} keys %{$allradius{$key}} )
	{
		foreach(@{$allradius{$key}{$subkey}})
		{
			print FINALOUTPUT $subkey.";".$_;	
		}
		#print FINALOUTPUT $emptyline;
		
	};
	close FINALOUTPUT;
}

print "FINISHED OK\n";
exit 0;

sub ltrim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}