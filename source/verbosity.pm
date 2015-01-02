use strict;
use warnings;

package Verbosity;

sub new {
	my ($invocant, $level) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		level => $level
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
			print $self->colourise($state), "$message\n";
		} else {
			print "$message\n";
		}
	}
};

sub colourise {
	use Term::ANSIColor;
	my ($self, $state) = @_;
	if ($state eq "OK") {
		return color("bold green"), "[OK]\t", color("reset");
	} elsif ($state eq "WARNING") {
		return color("bold yellow"), "[WARNING]\t", color("reset");
	} elsif ($state eq "ERROR") {
		return color("bold red"), "[ERROR]\t", color("reset");
	} else {
		return "";
	}
};

1;
__END__