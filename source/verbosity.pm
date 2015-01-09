use strict;
use warnings;
use Message;

# Verbosity
# Beschreibung: Dieses Modul setzt das Verbose-Level und gibt Texte aus
# Autor:		Patrick Vogt
# Datum:		Dezember 2014
package Verbosity;

# Konstruktor
# Parameter: level			Verbose-Level
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

# setVerboseLevel
# Beschreibung: Setzt das Verbose-Level
# Parameter:	level		Verbose-Level
sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{level} = $level;
};

# getVerboseLevel
# Beschreibung: Liefert das Verbose-Level
sub getVerboseLevel {
	my $self = shift;
	return $self->{level};
}

# verbose
# Beschreibung: Wenn level größer als 0 ist, werden Nachricht ausgegeben
# Parameter:	message		Auszugebende Nachricht
#				[state]		Status (OK, WARNING, ERROR)
sub verbose {
	my ($self, $message, $state) = @_;
	if ($self->{level} == 1) {
		if ($state) {
			print $self->{message}->colourise($state), "$message\n";
		} else {
			print "$message\n";
		}
	} elsif ($self->{level} == 2) {
		print "[DEBUG]\t$message\n";
	}
};

1;
__END__
