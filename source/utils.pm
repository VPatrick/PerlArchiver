use strict;
use warnings;
use Verbosity;

# Utils
# Beschreibung: Hilfsklasse
# Autor:		Patrick Vogt, Muhammed Kasikci
# Datum:		Januar 2015
package Utils;

# Konstruktor
sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		verbosity => Verbosity->new
	};
	bless ($self, $class);
	return $self;
};

# setVerboseLevel
# Beschreibung: Setzt das Verbose-Level
# Parameter:	level	Verbose-Level
sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{verbosity}->setVerboseLevel($level);
};

# findLastValidArchive
# Beschreibung: Findet das zuletzt gültige Archiv
# Parameter:	source		Verzeichnis für Archive
#				timestamp	Zeitpunkt
sub findLastValidArchive {
	my ($self, $source, $timestamp) = @_;
	opendir (my $dir, $source);
	my $finalSource = "";
	my $finalTimestamp = "";
	my $tmpTimestamp = "0000_00_00_00_00_00";
	while (readdir $dir) {
		if ($_ ne "." and $_ ne ".." and $_ ne ".DS_Store") {
			my @split1 = split(/_\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}$/, $_);
			my $archiveName = $split1[0];
			my @split2 = split(/$archiveName\_/, $_);
			my $archiveTimestamp = $split2[1];
            
			$self->{verbosity}->verbose("Compare times");
			if ($archiveName) {
				if ($self->compare_to($archiveTimestamp) <= $self->compare_to($timestamp)) {
					$self->{verbosity}->verbose("Compare $archiveTimestamp with $timestamp");
					if ($self->compare_to($archiveTimestamp) > $self->compare_to($tmpTimestamp)) {
						$tmpTimestamp = $archiveTimestamp;
						$finalSource = "${source}/${_}";
						$finalTimestamp = $archiveTimestamp;
					}
				}
			}
		}
	}
	closedir ($dir);
	return $finalSource;
};

# compare_to
# Beschreibung: Berechnet einen int-Wert aus einem Datum
# Parameter:	date	Datum
sub compare_to {
	my ($self, $date) = @_;
	my($y,$m,$d,$H,$M,$S) = split(/_/,$date);
	return "$y$m$d$H$M$S";
};

# Destruktor
sub DESTROY {
	my $self = shift;
	$self->{verbosity} = undef;
};

1;
__END__