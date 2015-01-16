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
my $invoker = Invoker->new;

foreach (@ARGV) {
	if ($_ =~ m/-(cr|cd|cl|cp|cm|ch|rc|rd|rl|rs|rm|rh|dc|dr|dl|dp|ds|dm|dh|lc|lr|ld|lp|ls|lm|lh|mc|mr|md|ml|mh|hc|hr|hd|hl|hm|hv)/i) {
		print $message->error("The combination of $_ is not valid.");
		exit;
	}
}

Getopt::Long::Configure("bundling");
GetOptions (
	"verbose|v:i"  => sub { $invoker->setVerboseLevel($_[1]) },
	"create|c" => sub { $invoker->create(@ARGV) },
	"restore|r" => sub { $invoker->restore(@ARGV) },
	"partial|p" => sub { $invoker->partial(@ARGV) },
	"slim|s" => sub { $invoker->slim(@ARGV) },
	"delete|d" => sub { $invoker->del(@ARGV) },
	"list|l" => sub { $invoker->list(@ARGV) },
	"mapping|m" => sub { $invoker->printHashTable(@ARGV) },
	"help|h" => sub { help() }
) or do {
	print $message->error("Error in command line arguements.");
	exit;
};

sub help() {
	pod2usage(-verbose => 2, -input => "./help.pod");
};
