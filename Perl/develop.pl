#!/usr/bin/perl

#########################################

use strict;
use warnings;
use File::Find;
use File::Copy;
use File::Basename;
use Cwd;
use Text::CSV;
use Math::Round;

#use Cwd  qw(abs_path);
#use lib dirname(dirname abs_path $0) . '/lib';

use Latex::service;

my ($CWD,$ConfigFile,$line,$csv);
my (@vals);
$ConfigFile = 'C:\Data\tex_tags.csv';
my %param;

read_tags("$ConfigFile");

while(my ($key, $value) = each %param)
{	
	 print "$key ===> $value\n";	
}





#########################################
sub read_tags
{
	my ($file) = shift(@_);
	if(-f $file)
	{
		$csv = Text::CSV->new({ sep_char => ',' });
		open(TEXFILE, "<$file") or die "Cannot open tex file $file";
		while ($line = <TEXFILE>)
		{
			if($csv->parse($line))
			{
				push @vals, $csv->fields();
			}
		}
		%param = @vals;
	}
}

