#!C:\NDAT\bin\StrwPerl\perl\bin\perl.exe

use strict;
use DBI;

my @ary = DBI->available_drivers();
print join("\n", @ary), "\n";
