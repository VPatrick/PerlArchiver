use strict;
use warnings;

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

sub setVerbosity {
	my ($self, $Verbosity) = @_;
	$self->{isVerbose} = $Verbosity;
};

sub create {
	my $self = shift;
	$self->verbose("create");
};

sub restore {
	my $self = shift;
	$self->verbose("restore");
};

sub del {
	my $self = shift;
	$self->verbose("delete");
};

sub list {
	my $self = shift;
	$self->verbose("list");
};

sub help {
	my $self = shift;
	$self->verbose("help");
};

sub verbose {
	my ($self, $message) = @_;
	if ($self->{isVerbose}) {
		print "$message\n";
	}
};

1;
__END__