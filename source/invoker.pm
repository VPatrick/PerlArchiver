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

sub activateVerboseMode {
	my ($self, $level) = @_;
	$self->{verbosity}->setVerboseLevel($level);
};

sub create {
	my ($self, @arguments) = @_;
	$self->{verbosity}->verbose("create");
};

sub slim {
	my ($self, @arguments) = @_;
	$self->{verbosity}->verbose("slim");
}

sub restore {
	my ($self, @arguments) = @_;
	$self->{verbosity}->verbose("restore");
};

sub del {
	my ($self, @arguments) = @_;
	$self->{verbosity}->verbose("delete");
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