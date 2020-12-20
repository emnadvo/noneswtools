#!C:\NDAT\bin\Perl\bin\perl.exe

use strict;
use warnings;

#to get execute file path
use File::Basename;
my $scrptdirpath = dirname(__FILE__);

#Time block
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
my ($startNum,$additionalFour,$i,$j,$k,$m,$maxiter,$outfile,$lcYear,$oldmon);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year-=2000-1900;
if($mon < 10){ $mon = "0".$mon; }
if($mday < 10){ $mday = "0".$mday; }

my $PROCESS_LOG = "$scrptdirpath\\$year$mon$mday"."_process.log";
$PROCESS_LOG =~ s/\./A:/;
$PROCESS_LOG =~ s/\\/\\\\/g;
print $PROCESS_LOG."\n";
open(PRCLOG,">:encoding(UTF-8)",$PROCESS_LOG) or die "Unable to open $PROCESS_LOG: $!";


my $workdirectory = 'A:\\DATA\\plscripts';
#my $workdirectory = 'L:\\3r_Appn\\DB\\txns\\kbinsurancetxn'; 
my (@allcsfiles, @file,@alldirs,@allitems,@newcontent);
my ($commnetline,$filename);
my $autogenerateend_src = '</auto-generated>';

my %header = ( "STAT" => "///////////////////////////////////////////////////////////////////////////////\n",
			"TITLE" => "// Title       : FILENAME\n",
			"OTHER" => "// Summary     : #todo_summary\n// System      : TSS3\n//\n///////////////////////////////////////////////////////////////////////////////\n#region ClearCase comments\n// \$Revision: \$\n// \$Log:  \$\n//\n///////////////////////////////////////////////////////////////////////////////\n#endregion ClearCase comments\n");


sub lookFor_files {
	my ($path,$regexp,$deep) = @_;
	my (@files,@dirs);

#	print $path."\n";
#	print $regexp."\n";
	if( -d $path )
	{
		opendir (DIR, $path) or die "Unable to open $path: $!";
		@files = grep {!/^\.{1,2}$/} readdir (DIR);
		closedir (DIR);
	}
	else
	{
		print "Uvedena cesta neni validni!";
	}

	@files = map { $path.'\\'. $_ } @files;

	for(@files)
	{
		if( -d $_ && $deep > 0 )
		{
			$deep--;
			push @allcsfiles, lookFor_files($_,$regexp,$deep);
			$deep++;
		}
		
		if(/$regexp/){
			push(@allcsfiles,$_);
	     }
	}	
#	return @allcsfiles;
}

sub get_all_csfiles{
	@file = ();
	my ($path,$regexp) = @_;
	if( -d $path )
	{
		opendir (DIR, $path) or die "Unable to open $path: $!";
		@file = grep {/\.cs$/} readdir (DIR);	
		closedir (DIR);
	}
	else
	{
		print "Uvedena cesta neni validni!";
	}	
	@file = map { $path.'\\'. $_ } @file;	
}


lookFor_files($workdirectory,'\.cs$',0);

for(@allcsfiles)
{	
	push @newcontent, $header{"STAT"};
	$commnetline = $header{"TITLE"};
	$filename	= basename($_);
	$commnetline =~ s/FILENAME/$filename/g;
	push @newcontent,  $commnetline;
	push @newcontent, $header{"OTHER"};

	$filename = $_;

	open(FN,"<:encoding(UTF-8)",$_) or die "Unable to open $_: $!"; 
	my @content = readline(FN);
	close(FN);

	for($i = 0; $i < $#content; $i++)
	{
		if($content[$i] =~ /^\/\/\W/ && $content[$i] !~ /^\/\/\w/)
		{

		}
		elsif($content[$i] =~ /^ *\s\n/ && $i++ < $#content && $content[$i++] =~ /^ .\s\n/)
		{

		}
		else
		{
			push @newcontent,$content[$i];
		}
	}
}


for(@newcontent)
{
	print PRCLOG $_;
}
