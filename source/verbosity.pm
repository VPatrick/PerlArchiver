use strict;
use warnings;
use Message;

package Verbosity;

sub new {
	my ($invocant, $level) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		level => $level || 0,
		message => Message->new
	};
	bless ($self, $class);
	return $self;
};

sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{level} = $level;
};

sub verbose {
	my ($self, $message, $state) = @_;
	if ($self->{level} > 0) {
		if ($state) {
			print $self->{message}->colourise($state), "$message\n";
		} else {
			print "$message\n";
		}
	}
};

1;
__END__