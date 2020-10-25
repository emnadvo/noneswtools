#!/usr/bin/perl

#########################################
#
#	filename: 		Graphs_generation_tex.pl
#	author:			Michal Nadvornik
#	description:	Usefull script for generation output file with graphs for blade comparison
#
#########################################
my ($var,$nothing,$abc,$def,$xyz);
my (@DNA_codons);
    
#########################################

$on_a_tty = -t STDIN && -t STDOUT;
sub prompt { print "yes? " if $on_a_tty }
for ( prompt(); <STDIN>; prompt() ) {
	# do something
}

for ( prompt(); defined( $_ = <STDIN> ); prompt() ) {
	# do something
}

#Perl switch 
use v5.14;
for ($var) {
	$abc = 1 when /^abc/;
	$def = 1 when /^def/;
	$xyz = 1 when /^xyz/;
	default { $nothing = 1 }
}

#########################################
#####	HASHES

my %DNA_code = (
    'GCT' => 'A', 'GCC' => 'A', 'GCA' => 'A', 'GCG' => 'A', 'TTA' => 'L',
    'TTG' => 'L', 'CTT' => 'L', 'CTC' => 'L', 'CTA' => 'L', 'CTG' => 'L',
    'CGT' => 'R', 'CGC' => 'R', 'CGA' => 'R', 'CGG' => 'R', 'AGA' => 'R',
    'AGG' => 'R', 'AAA' => 'K', 'AAG' => 'K', 'AAT' => 'N', 'AAC' => 'N',
    'ATG' => 'M', 'GAT' => 'D', 'GAC' => 'D', 'TTT' => 'F', 'TTC' => 'F',
    'TGT' => 'C', 'TGC' => 'C', 'CCT' => 'P', 'CCC' => 'P', 'CCA' => 'P',
    'CCG' => 'P', 'CAA' => 'Q', 'CAG' => 'Q', 'TCT' => 'S', 'TCC' => 'S',
    'TCA' => 'S', 'TCG' => 'S', 'AGT' => 'S', 'AGC' => 'S', 'GAA' => 'E',
    'GAG' => 'E', 'ACT' => 'T', 'ACC' => 'T', 'ACA' => 'T', 'ACG' => 'T',
    'GGT' => 'G', 'GGC' => 'G', 'GGA' => 'G', 'GGG' => 'G', 'TGG' => 'W',
    'CAT' => 'H', 'CAC' => 'H', 'TAT' => 'Y', 'TAC' => 'Y', 'ATT' => 'I',
    'ATC' => 'I', 'ATA' => 'I', 'GTT' => 'V', 'GTC' => 'V', 'GTA' => 'V',
    'GTG' => 'V',);
    
for (@DNA_codons) {
  $DNA_codon_counters{$_}++;
}


while (my ($key, $value) = each %some_hash) {
  print "$key ===> $value\n";
  $reverse_hash{$value} = $key;
}

for (keys %some_hash) {
  print "$_ occurs $some_hash{$_} times\n";
} 

if (exists $DNA_code{'GUU'}) {
  print "GUU is a valid DNA codon\n";
}

delete $DNA_code{'GUU'}; 

# Array into hash and back
my %fields;
@fields{@header_line} = (0 .. $#header_line);


#other way
my %fields = map { $header_line[$_] => $_ } 0..$#header_line;

my %fields = ();
foreach my $field(@header_line)
{
  %fields{$field} = scalar(keys(%fields));
}

%hash = map { $_ => 1 } @array;

#########################################

		#Save slice to all slices array
		if ($#slice > 0)
		{
			push @{$allslices[$j]},@slice;
			$j += 1;
			@slice = ();			
			#exit;
		}
		
		
		for $j (0..$#{$allslices[$i]})
		{
			print BLADE $allslices[$i][$j];
			push @servarray, $allslices[$i][$j];
		}


########################################
#  You can also use a subroutine reference as a method:

      my $sub = sub {
          my $self = shift;
          $self->save();
      };
      $file->$sub();


    if(exists $data and length($data) gt 0)
    {
    	@lc_args = split(' ',$data);
    	for(my $i=0;$i<=$#lc_args;$i++)
    	{
    		if($lc_args[$i] =~ /name/i){}
    	}
    }
    else
    {
    	
    }