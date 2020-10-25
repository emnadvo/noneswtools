#################################################################################
#
# DATE: 01.03.2013
#
# USER:	MNADVORNIK
# 
# DESC:	Modul contains definition of all necessary functions for main project
#
################################################################################# 
package NFramework;

use strict;
use warnings;
use File::Find;
use File::Basename;

BEGIN {
	require Exporter;
	
	# set the version for version checking
 	our $VERSION = 1.00;

	# Inherit from Exporter to export functions and variables
 	our @ISA = qw(Exporter);

	# Functions and variables which are exported by default
 	our @EXPORT = qw($NEWLINE $SPACE $INLET $OUTLET %PLANES %BCPARAMS @findfiles @header @bclines datafile_transform_for_matlab find_files_by_ext get_bc_conditions_from_file);

	# Functions and variables which can be optionally exported
 	# our @EXPORT_OK = qw($Var1 %Hashit func3);
 	our @EXPORT_OK = qw($NEWLINE $SPACE $INLET $OUTLET %PLANES %BCPARAMS @findfiles @header @bclines datafile_transform_for_matlab find_files_by_ext get_bc_conditions_from_file);	
}

our $NEWLINE = "\n";
our $SPACE = " ";
our $INLET = "INLET";
our $OUTLET = "OUTLET";

our %PLANES = ( "$INLET","inlet",\
				"$OUTLET","outlet");
				
our %BCPARAMS = ( Reynolds => 0,
				  Mach => 0,
				  AbsPress_in => 0,
				  AbsTemp_in => 0,
				  StatPress_out => 0,
				  StatTemp_out => 0,
				  Cp => 0,
				  Eta => 0,
				  Molecul => 0,
				  Lambda => 0,
				  Density => 0,
				  TurbIntensity => 0,
				  TurbMyRatio => 0,
				  );

#Function transform input file data to compatible format with matlab importdata function. 
sub datafile_transform_for_matlab
{
	my ($const_name,$const_file,$status);
	
	# CONSTANTS DEFINITION
	$const_name = '\[Name\]';
	$const_file = 'Generated from';

	foreach (@_)
	{
		my ($line,$position_id,$file_id,$header_id);
		my (@DATA,@SOURCE,@TEXT,@VALUES);
		
		$status = 0;	
		my $filename = $_;
		open(FIRSTFILE, "<$filename") or return "Cannot open first template file $filename";
		$position_id = 0;
		$file_id = 0;
		$header_id = 0;
		@SOURCE = <FIRSTFILE>;
		close FIRSTFILE;
		
		foreach(@SOURCE)
		{
			if ($_ =~ /\d\d\d\d\d\d\d\d/)
			{
				push @DATA, $_;
		#		my @vals = split(/;/,$_);
		#		if ($#vals > 0)
		#		{
		#			print "length ".$#vals."\n";
		#			print @vals;
		#			push @VALUES, @vals;
		#		}	
			}
			else
			{
				push @TEXT, $_;
				if($_ =~ /$const_name/i)
				{
					$position_id = $#TEXT + 1;
				}
				
				if($_ =~ /$const_file/i)
				{
					$file_id = $#TEXT;
				}
			}	
		}
		
		if (($SOURCE[$#SOURCE] eq $DATA[$#DATA])&&($SOURCE[$#SOURCE-$#DATA] eq $DATA[0]))
		{	
			#print "\nProcess filtering OK\n";
			$status = 1;
			$header_id = $#TEXT;
		}
		
		if ($status)
		{
			open(SECFILE, ">$filename") or return "Cannot open first template file $filename";
			print SECFILE $TEXT[$file_id];
			print SECFILE "## PositionID: ".$TEXT[$position_id];
			print SECFILE $TEXT[$header_id];
			
			foreach(@DATA)
			{
				print SECFILE $_;
			}
			close SECFILE;
		}
		else
		{
			return "Status failed!"; 
		}
	}
}
# function for file finding with your extension processing
# export globals for finding functions
our @findfiles = ();
our @header = ();
our @bclines = ();

sub find_files_by_ext
{
	my $filesdir = shift(@_);
	our $search_expression = shift(@_);	
	find(\&find_it, "$filesdir");
	sub find_it
	{
		push @findfiles, $File::Find::name if ($_ =~ /$search_expression$/i);
	}
}


sub get_bc_conditions_from_file
{
	my ($filename) = @_;
	my ($_ln_);
	open(BCFILE,"<$filename") or return "Cannot open bcfiles $filename";
	while ($_ln_ = <BCFILE>)
	{
		#read bc file and header prepare
		if (!@header && $_ln_ =~ /Re_izo/)
		{
			@header = split(/\t/,$_ln_);
		}
		else
		{
			push @bclines, $_ln_;
		}
	}	
	
	if($#header > 0)
	{
		##find id's of important parameters
		for (my $i=0; $i!= $#header; $i++)
		{
			if ($header[$i] =~ /Re_izo/)
			{
				$BCPARAMS{"Reynolds"} = $i;
			};
			
			if ( $header[$i] =~ /Ma_izo/)
			{
				$BCPARAMS{"Mach"} = $i;
			};
			
			if ( $header[$i] =~ /P0_abs/)
			{
				$BCPARAMS{"AbsPress_in"} = $i;
			};
			
			if ( $header[$i] =~ /T0_abs/)
			{
				$BCPARAMS{"AbsTemp_in"} = $i;
			};
			
			if ( $header[$i] =~ /P2_stat/)
			{
				$BCPARAMS{"StatPress_out"} = $i;
			};
			
			if ( $header[$i] =~ /T2_stat/)
			{
				$BCPARAMS{"StatTemp_out"} = $i;
			};
			
			if ( $header[$i] =~ /Cp/)
			{
				$BCPARAMS{"Cp"} = $i;
			};
	
			if ( $header[$i] =~ /Eta/)
			{
				$BCPARAMS{"Eta"} = $i;
			};
	
			if ( $header[$i] =~ /Molecul\.Weight/)
			{
				$BCPARAMS{"MoleculW"} = $i;
			};
	
			if ( $header[$i] =~ /Lambda/)
			{
				$BCPARAMS{"Lambda"} = $i;
			};
	
			if ( $header[$i] =~ /rho_0/)
			{
				$BCPARAMS{"Density"} = $i;
			};

			if ( $header[$i] =~ /turb_intesity/)
			{
				$BCPARAMS{"TurbIntensity"} = $i;
			};
			
			if ( $header[$i] =~ /disip_ratio/)
			{
				$BCPARAMS{"TurbMyRatio"} = $i;
			};			
		}
	}
	else
	{
		return "Header array is empty!\nWithout header program not correct working!";		
	}

}

sub ltrim
{
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}
# # exported package globals go here
# our $Var1 = '';
# our %Hashit = ();
#
# # non-exported package globals go here
# # (they are still accessible as $Some::Module::stuff)
# our @more = ();
# our $stuff = '';
#
# # file-private lexicals go here, before any functions which use them
# my $priv_var = '';
# my %secret_hash = ();
#
# # here's a file-private function as a closure,
# # callable as $priv_func->();
# my $priv_func = sub {
# ...
# };
#
# # make all your functions, whether exported or not;
# # remember to put something interesting in the {} stubs
# sub func1 { ... }
# sub func2 { ... }
#
# # this one isn't exported, but could be called directly
# # as Some::Module::func3()
# sub func3 { ... }
#


END {} # module clean-up code here (global destructor)
# don't forget to return a true value from the file
1;
