use strict;
use warnings;
use Verbosity;
use Message;

package Invoker;

sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		verbosity => Verbosity->new,
		message => Message->new
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
	my ($self, @arguments) = @_;
	if ($#arguments == 1) {
		use List;
		my $list = List->new();
		$list->list($arguments[0], $arguments[1]);
	} else {
		print $self->{message}->error("Die Anzahl der Parameter stimmt nicht.");
		exit;
	}
};

sub help {
	my $self = shift;
};

1;
__END__