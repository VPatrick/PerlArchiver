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

my @params = grep(/^-[scrdlhmp]{1}$/, @ARGV);
if (!@params) {
	@params = grep(/^--(create|restore|delete|list|help|mapping|slim|partial){1}$/, @ARGV);
}
my $params = join " ", @params;
if (!$params) {
	$params = $ARGV[0];
}
checkParams($params, '^(-[crdlhmsp]{1})\\s{0,1}(-{0,1}[crdlhm]{1})');
checkParams($params, '^(-[rdlhmsp]{1})\\s{0,1}(-{0,1}s)');
checkParams($params, '^(-[cdlhmsp]{1})\\s{0,1}(-{0,1}p)');
checkParams($params, '^(--(?:create|restore|delete|list|help|mapping|slim|partial){1})\\s{0,1}(--(?:create|restore|delete|list|help|mapping){1})');
checkParams($params, '^(--(?:restore|delete|list|help|mapping|slim|partial){1})\\s{0,1}((?:--){0,1}slim)');
checkParams($params, '^(--(?:create|delete|list|help|mapping|slim|partial){1})\\s{0,1}((?:--){0,1}partial)');

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

# help
# Beschreibung:	Gibt die Hilfedatei auf STDOUT aus
sub help {
	pod2usage(-verbose => 2, -input => "./help.pod");
};

# checkParams
# Beschreibung:	Prüft die Switches gegen reguläre Ausdrücke
# Parameter:	params	Switches
#				regex	Regulärer Ausdruck
sub checkParams {
	my ($params, $regex) = @_;
	if ($params =~ m/$regex/s) {
		print $message->error("The combination of $1 and $2 is invalid.");
		exit;
	}
};