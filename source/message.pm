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
	my ($self, $message) = @_;
	if ($^O eq "MSWin32") {
		return ($message) ? "[OK]\t$message\n" : "[OK]\t";
	} else {
		use Term::ANSIColor;
		if ($message) {
			return color("bold green"), "[OK]\t", color("reset"), "$message\n";
		} else {
			return color("bold green"), "[OK]\t", color("reset");
		}
	}
};

sub warning {
	my ($self, $message) = @_;
	if ($^O eq "MSWin32") {
		return ($message) ? "[WARNING]\t$message\n" : "[WARNING]\t";
	} else {
		use Term::ANSIColor;
		if ($message) {
			return color("bold yellow"), "[WARNING]\t", color("reset"), "$message\n";
		} else {
			return color("bold yellow"), "[WARNING]\t", color("reset");
		}
	}
};

sub error {
	my ($self, $message) = @_;
	if ($^O eq "MSWin32") {
		return ($message) ? "[ERROR]\t$message\n" : "[ERROR]\t";
	} else {
		use Term::ANSIColor;
		if ($message) {
			return color("bold red"), "[ERROR]\t", color("reset"), "$message\n";
		} else {
			return color("bold red"), "[ERROR]\t", color("reset");
		}
	}
};

sub colourise {
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