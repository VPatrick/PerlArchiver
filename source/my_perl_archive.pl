#!/usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . "/PerlArchiver/source";

use Getopt::Long;
use Invoker;

my $i = Invoker->new();

Getopt::Long::Configure ("bundling");
GetOptions (
	"verbose|v"  => sub { $i->activateVerboseMode(1) },
	"create|c|cs" => sub { $i->create(@ARGV) },
	"restore|r|rp" => sub { $i->restore(@ARGV) },
	"slim|s" => sub { $i->slim(@ARGV) },
	"delete|d" => sub { $i->del(@ARGV) },
	"list|l" => sub { $i->list(@ARGV) },
	"help|h" => sub { $i->help() }
) or die("Error in command line arguments\n");