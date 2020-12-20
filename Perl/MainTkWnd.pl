#!C:\NDAT\bin\Perl\bin\perl.exe

use strict;
use warnings;

require Tk;
use Tk;

#to get execute file path
use File::Basename;
my $dirname = dirname(__FILE__);


my $mainWnd = MainWindow->new();
#my $top = $mainWnd->Toplevel();
$mainWnd->title("Testovaci dialog");

my $frame = $mainWnd->Frame(-borderwidth => 2, -relief => "groove");
$mainWnd->Button(-text => "Ok", -command => sub{exit} )->pack;

Tk::MainLoop();

sub OnOk
{
  return;
}
