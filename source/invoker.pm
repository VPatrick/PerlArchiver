use strict;
use warnings;
use Data::Dumper;

package Invoker;

sub new {
	my ($invocant, $verbose) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		isVerbose => $verbose
	};
	bless ($self, $class);
	return $self;
};

sub activateVerboseMode {
	my ($self, $Verbosity) = @_;
	$self->{isVerbose} = $Verbosity;
};

sub create {
	my ($self, @arguments) = @_;
	$self->verbose("create");
};

sub restore {
	my ($self, @arguments) = @_;
	$self->verbose("restore");
};

sub del {
	my ($self, @arguments) = @_;
	$self->verbose("delete");
};

sub list {
	my ($self, @arguments) = @_;
	use List;
	my $list = List->new();
	$list->list($arguments[0]);
};

sub help {
	my $self = shift;
	$self->verbose("help");
};

sub verbose {
	my ($self, $message, $state) = @_;
	if ($self->{isVerbose}) {
		if ($state) {
			use Term::ANSIColor;
			if ($state eq "OK") {
				print color("bold green"), "[OK]\t", color("reset"), "$message\n";
			} elsif ($state eq "WARNING") {
				print color("bold yellow"), "[WARNING]\t", color("reset"), "$message\n";
			} elsif ($state eq "ERROR") {
				print color("bold red"), "[ERROR]\t", color("reset"), "$message\n";
			} else {
				print "$message\n";
			}
		} else {
			print "$message\n";
		}
	}
};

1;
__END__