#!/usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . "/PerlArchiver/source";

use Getopt::Long;
use Pod::Usage qw(pod2usage);
use FindBin;
use Invoker;
use Message;

my $message = Message->new;
my $i = Invoker->new;

foreach (@ARGV) {
	if ($_ =~ m/-(cr|cd|cl|cp|rc|rd|rl|rs|dc|dr|dl|dp|ds|lc|lr|ld|lp|ls)/i) {
		print $message->error("The combination of $_ is not valid.");
		exit;
	}
}

Getopt::Long::Configure("bundling");
GetOptions (
	"verbose|v"  => sub { $i->setVerboseLevel(1) },
	"create|c|cs" => sub { $i->create(@ARGV) },
	"restore|r" => sub { $i->restore(@ARGV) },
	"partial|p" => sub { $i->partial(@ARGV) },
	"slim|s" => sub { $i->slim(@ARGV) },
	"delete|d" => sub { $i->del(@ARGV) },
	"list|l" => sub { $i->list(@ARGV) },
	"help|h" => sub { help() }
) or die("Error in command line arguments\n");

sub help() {
	pod2usage(-verbose => 2, -input => $FindBin::Bin . "/help.pod");
};