use strict;
use warnings;

package Message;

sub new {
	my ($invocant, $level) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	bless ($self, $class);
	return $self;
};

sub message {
	my ($self, $message, $state) = @_;
	if ($state) {
		print $self->colourise($state), "$message\n";
	} else {
		print "$message\n";
	}
};

sub ok {
	use Term::ANSIColor;
	my ($self, $message) = @_;
	if ($message) {
		return color("bold green"), "[OK]\t", color("reset"), "$message\n";
	} else {
		return color("bold green"), "[OK]\t", color("reset");
	}
};

sub warning {
	use Term::ANSIColor;
	my ($self, $message) = @_;
	if ($message) {
		return color("bold yellow"), "[WARNING]\t", color("reset"), "$message\n";
	} else {
		return color("bold yellow"), "[WARNING]\t", color("reset");
	}
};

sub error {
	use Term::ANSIColor;
	my ($self, $message) = @_;
	if ($message) {
		return color("bold red"), "[ERROR]\t", color("reset"), "$message\n";
	} else {
		return color("bold red"), "[ERROR]\t", color("reset");
	}
};

sub colourise {
	use Term::ANSIColor;
	my ($self, $state) = @_;
	if ($state eq "OK") {
		return $self->ok();
	} elsif ($state eq "WARNING") {
		return $self->warning();
	} elsif ($state eq "ERROR") {
		return $self->error();
	} else {
		return "";
	}
};

1;
__END__