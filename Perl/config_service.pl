#!/usr/bin/perl

#########################################
#
#	filename: 		config_service.pl
#	author:			Michal Nadvornik
#	description:	Usefull script for manipulation with configuration file. It's based on key=value background.
#
#########################################


package Config_service;

use vars qw($VERSION);
$VERSION = '1.00';

require 5.008;
use strict;
use warnings;
use parent 'Config::IniFiles';

sub new {
	my $class = shift;
	my %params = @_;
	my $err = 0;
	
	
	
}
sub DESTROY {
	my $self = shift;
}