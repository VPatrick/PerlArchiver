use strict;
use warnings;
use Verbosity;
use Cwd;

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
		verbosity => Verbosity->new,
		message => Message->new
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
#				archiveName Name des Archivs
sub findLastValidArchive {
	my ($self, $source, $timestamp, $archiveName) = @_;
	opendir (my $dir, $source);
	my $finalSource = "";
	my $finalTimestamp = "";
	my $tmpTimestamp = "0000_00_00_00_00_00";
	my $lock = ($archiveName) ? 1 : 0;
	
	while (readdir $dir) {
		if ($_ ne "." and $_ ne ".." and $_ ne ".DS_Store") {
			my @split1 = split(/_\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}$/, $_);
			my $currentArchiveName = $split1[0];
			my @split2 = split(/$currentArchiveName\_/, $_);
			my $archiveTimestamp = $split2[1];
			
			if ($archiveName and $currentArchiveName eq $archiveName) {
				$self->{verbosity}->verbose("Compare times");
				$lock = 1;
				if ($self->compare_to($archiveTimestamp) <= $self->compare_to($timestamp)) {
					$self->{verbosity}->verbose("Compare $archiveTimestamp with $timestamp");
					if ($self->compare_to($archiveTimestamp) > $self->compare_to($tmpTimestamp)) {
						$tmpTimestamp = $archiveTimestamp;
						$finalSource = "${source}/${_}";
						$finalTimestamp = $archiveTimestamp;
					}
				}
			}
			if ($lock eq 0 and $currentArchiveName) {
				$self->{verbosity}->verbose("Compare times");
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
	if ($^O eq "MSWin32") {
		$finalSource =~ s/\//\\/g;
	}
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

# getPathFromHash
# Beschreibung: Liefert einen, zu einem Hash gehörenden, Pfad
# Parameter:	hash	MD5-Hash
#				path	Pfad zur Hash-Tabelle
# Rückgabewert: path	Pfad zu einem Verzeichnis
sub getPathFromHash {
	my ($self, $hash, $path) = @_;
	open (my $file, $path) or do {
		print $self->{message}->error("Can't open hash table.");
		exit;
	};
	while (my $hashPathPair = <$file>) {
		if ($hashPathPair =~ /^$hash/) {
			my @split = split(/\:/, $hashPathPair, 2);
			return $split[1];
		}
	}
	return undef;
};

# Destruktor
sub DESTROY {
	my $self = shift;
	$self->{verbosity} = undef;
	$self->{message} = undef;
};

1;
__END__