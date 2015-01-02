use strict;
use warnings;
use Verbosity;

package Invoker;

sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		verbosity => Verbosity->new(0)
	};
	bless ($self, $class);
	return $self;
};

sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{verbosity}->setVerboseLevel($level);
};

sub create {
	my ($self, @arguments) = @_;
	# Aufruf der entsprechenden Create-Methoden
};

sub slim {
	my ($self, @arguments) = @_;
	# Aufruf der entsprechenden Slim-Methoden
}

sub restore {
	my ($self, @arguments) = @_;
	# Aufruf der entsprechenden Restore-Methoden
};

sub del {
	my ($self, @arguments) = @_;
	# Aufruf der entsprechenden Delete-Methoden
};

sub list {
	use List;
	my ($self, @arguments) = @_;
	my $list = List->new();
	$list->list($arguments[0]);
};

sub help {
	my $self = shift;
};

1;
__END__