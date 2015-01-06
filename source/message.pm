use strict;
use warnings;

# Message
# Beschreibung: Dieses Modul gibt Texte abhängig vom Status aus
# Autor:		Patrick Vogt
# Datum:		Dezember 2014
package Message;

# Konstruktor
sub new {
	my ($invocant, $level) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	bless ($self, $class);
	return $self;
};

# message
# Beschreibung: Gibt eine Nachricht abhängig vom Status aus
# Parameter: message	Auszugebende Nachricht
#			 [state]	Gibt Nachrichten-Status an
sub message {
	my ($self, $message, $state) = @_;
	if ($state) {
		print $self->colourise($state), "$message\n";
	} else {
		print "$message\n";
	}
};

# ok
# Beschreibung: Gibt den Text [OK] und eine optionale Nachricht auf STDOUT aus
# Parameter: [message]	Optionale auszugebende Nachricht
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

# warning
# Beschreibung: Gibt den Text [WARNING] und eine optionale Nachricht auf STDOUT aus
# Parameter: [message]	Optionale auszugebende Nachricht
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

# error
# Beschreibung: Gibt den Text [ERROR] und eine optionale Nachricht auf STDOUT aus
# Parameter: [message]	Optionale auszugebende Nachricht
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

# colourise
# Beschreibung: Liefert [OK], [WARNING] oder [ERROR] zurück
# Parameter: state	Status
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