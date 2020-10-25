package Config_service;

use strict;
use warnings;
use Text::CSV 'csv';
  
sub new {
	my $class = shift;
    my ($path,@data) = @_;
    
    my ($lc_val,@lc_args);
    my @cfg_keys = (
    	'name',
    	'path',
    	'version',
    	);
    
    my %fields;
    @fields{@data} = (0 .. $#data);
    
#    if(exists @data and $#data gt 0)
#    {
#    	
#    }
#    else
#    {
#    	
#    }

    my $self = bless{
    	path => $path,
    	data => @data,
    	}, $class;
    	
    return $self;	
}


sub DESTROY {
	my $self = shift;
}


#return undef if not defined $sect;
#$self->_caseify(\$sect);
#return ((exists $self->{e}{$sect}) ? 1 : 0);