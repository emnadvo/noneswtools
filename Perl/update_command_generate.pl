#!C:\NDAT\bin\Perl\bin\perl.exe

use strict;
use warnings;
use Encode;

#my @encode_params = Encode->encodings();
#foreach(@encode_params)
#{
#	print $_."\n";
#}
#exit 0;

#to get execute file path
use File::Basename;
#my $dirname = dirname(__FILE__);

use Text::CSV;

my $csv_input = Text::CSV->new({ sep_char => ';' });

my $source_file = "A:\\DATA\\PROJECTS\\2017_2\\TSS-4317 Roèní výpis\\ic_productfee_JB_mapped.csv";
my $dirname = dirname($source_file);

my $table_name = "IC_PRODUCTFEE";
my $scheme_name = "TSS3";
my $updated_column = "SAZEBNIK_ID";
my $condition_column_1 = "POPIS";
my $equal = " = ";

my $update_cmd_templ = "UPDATE ".$scheme_name.".".$table_name."\nSET ".$updated_column.$equal;
my $conditional_sentence = "\nWHERE ".$condition_column_1.$equal;

my $column_id_desc = 0;
my $column_id_tariffid = 6;
my $column_id_value = 0;

my @outcmnd;
my $outstring;

#encoding(iso-8859-2)
open(my $data, '<', $source_file) or die "Could not open '$source_file' $!\n";
#decode('iso-8859-2',
while (my $line = <$data>) {
  chomp $line;

  &Encode::from_to($line,"utf8","iso-8859-16");
  if ($csv_input->parse($line)) {
 
      my @fields = $csv_input->fields();
	 
	 if(length($fields[$column_id_tariffid]) ne 0)
	 {
		 $outstring = ($update_cmd_templ.$fields[$column_id_tariffid].$conditional_sentence."'".$fields[$column_id_desc]."';"."\n\n");
#		 &Encode::from_to($outstring,"iso-8859-16","utf-8");
		 push @outcmnd, $outstring;
	 }
	 
#      print "POPIS: ".$fields[$column_id_desc]."\n";
#      print "ID SAZEBNIK: ".$fields[$column_id_tariffid]."\n";

  } else {
      warn "Line could not be parsed: $line\n";
  }
}

close($source_file);

if($#outcmnd gt 0)
{
	$source_file = "$dirname\\updated_script.sql";
	open(CMDOUT, '>',$source_file) or die "Unable to open $source_file: $!";
	foreach(@outcmnd)
	{	
		print CMDOUT $_;
	}

	close(CMDOUT);
}



exit 0;
