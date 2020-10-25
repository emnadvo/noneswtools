#!/usr/bin/perl

#########################################
#
#	filename: 		config_service.pl
#	author:			Michal Nadvornik
#	description:	Usefull script for manipulation with configuration file. It's based on key=value background.
#
#########################################


package Latex::service;
require 5.008;

use strict;
use warnings;
use File::Find;
use File::Copy;
use File::Basename;
use Cwd;
use Text::CSV;
use Math::Round;
use base 'Exporter';

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

our %EXPORT_TAGS = (
 		'all' => [ qw(read_tags
 					  get_tags 
 					  %param ) ],
        'action' => [ qw(read_tags
 					  	 get_tags) ],
        'manipulation' => [ qw() ],		
	);
	
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(read_tags get_tags %param);
our @ISA = qw(Exporter);
$VERSION = '1.00';
 
our (%param,$file,$csv,$line,@vals);


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

sub get_tags
{	
	return ((keys %param)>0 ? %param : qw());
}



1;

__END__