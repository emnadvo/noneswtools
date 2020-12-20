#!C:\NDAT\bin\Perl\perl\bin\perl.exe

use strict;
use warnings;

use DateTime;
use Cwd;

my ($dtToday,$logname,$logrecord,$user,$pcid,$info);
my %LOG_STATES = (
                    INFO => 'INFO',
                    DBDEV => 'DBA_DEVEL',
                    CDEV => 'CPP_DEVEL',
                    LNCH => 'LUNCH',
                    OTHERS => 'NONDETERMINE' );

$dtToday = DateTime->now();


print $dtToday;
