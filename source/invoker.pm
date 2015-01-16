use strict;
use warnings;
use Verbosity;
use Message;
use Instances;
use Utils;

# Invoker
# Beschreibung: Dieses Modul dient zum Aufruf der entsprechenden Funktionen von my_perl_archiver
# Autor:		Patrick Vogt
# Datum:		Dezember 2014
package Invoker;

# Konstruktor
sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		message => Message->new,
		instances => Instances->new,
		utils => Utils->new,
		level => 0
	};
	bless ($self, $class);
	return $self;
};

# setVerboseLevel
# Beschreibung: Setzt das Verbose-Level
# Parameter:	level	Verbose-Level
sub setVerboseLevel {
	my ($self, $level) = @_;
	if ($level =~ m/[0-9]/) {
		$self->{level} = ($level eq 0) ? 1 : $level;
	}
};

# create
# Beschreibung: Ruft die Funktion create auf
# Parameter:	arguments	Parameter für create
sub create {
	my ($self, @arguments) = @_;
	if ($#arguments >= 1) {
		my $create = $self->{instances}->create($self->{level});
		if ($arguments[0] eq "-s") {
			$create->addSource($arguments[1]);
			$create->addDestination($arguments[2]);
		} else {
			$create->addSource($arguments[0]);
			$create->addDestination($arguments[1]);
		}
		$create->create_c();
	} else {
		print $self->{message}->error("Wrong amount of parameters given: Path to source and destination directory needed.");
		exit;
	}
};

# slim
# Beschreibung: Ruft die Funktion slim auf
# Parameter:	arguments	Parameter für slim
sub slim {
	my ($self, @arguments) = @_;
	my $create = $self->{instances}->create($self->{level});
	if ($#arguments == 1) {
		$create->create_s();
	} elsif ($#arguments == 0) {
		my @split = split(/_\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}$/, $arguments[0]);
		my @split2 = undef;
		if ($^O eq "MSWin32") {
			@split2 = split(/\\/, $split[0]);
		} else {
			@split2 = split(/\//, $split[0]);
		}
		$create->addDestination($arguments[0]);
		$create->addArchiveName($split2[$#split2]);
		$create->create_s();
	} else {
		print $self->{message}->error("Wrong amount of paramters given: Path to destination direcotry needed.");
		exit;
	}
};

# restore
# Beschreibung: Ruft die Funktion restore auf
# Parameter:	arguments	Parameter für restore
sub restore {
	my ($self, @arguments) = @_;
	if ($#arguments >= 3) {
		my $restore = $self->{instances}->restore($self->{level});
		$restore->addSource($self->{utils}->getAbsPath($arguments[0]));
		$restore->addDestination($self->{utils}->getAbsPath($arguments[1]));
		$restore->addSourceName($arguments[2]);
		$restore->addUserTime($arguments[3]);
		$restore->restore_r();
	} else {
		print $self->{message}->error("Wrong amount of parameters given: Path to source directory, path to destination direcotry, source name and timestamp needed.");
		exit;
	}
};

# partial
# Beschreibung: Ruft die Funktion partial auf
# Parameter:	arugments	Parameter für partial
sub partial {
	my ($self, @arguments) = @_;
	if ($#arguments == 4) {
		my $restore = $self->{instances}->restore($self->{level});
		$restore->addPartial($arguments[4]);
		$restore->restore_rp();
	} else {
		print $self->{message}->error("Wrong amount of parameters given: Relative path to object for partial restoring needed.");
		exit;
	}
}

# del
# Beschreibung: Ruft die Funktion delete auf
# Parameter:	arguments	Parameter für delete
sub del {
	my ($self, @arguments) = @_;
	if ($#arguments == 0) {
		if ($^O eq "MSWin32") {
            require del;
			my $delete = del->new;
			if ($self->{level} > 0) {
				$delete->setVerboseLevel($self->{level});
			}
			$delete->addDestination($self->{utils}->getAbsPath($arguments[0]));
			$delete->delete_d();
		} else {
			$self->{message}->warning("The delete function is currently not supported.");
			exit;
		}
	} else {
		print $self->{message}->error("Wrong amount of parameters given: Path to an archive needed.");
		exit;
	}
};

# list
# Beschreibung: Ruft die Funktion list auf
# Parameter:	arguments	Parameter für list
sub list {
	my ($self, @arguments) = @_;
	if ($#arguments == 1) {
		use List;
		my $list = List->new;
		if ($self->{level} > 0) {
			$list->setVerboseLevel($self->{level});
		}
		$list->list($self->{utils}->getAbsPath($arguments[0]), $arguments[1]);
	} else {
		print $self->{message}->error("Wrong amount of paramters given: Path to an archive and a timestamp (yyyy_mm_dd_hh_ii_ss) needed.");
		exit;
	}
};

# printHashTable
# Beschreibung: Gibt die Zuweisungstabelle auf STDOUT aus
# Parameter:	arguments	Parameter für printHashTable
sub printHashTable {
	my ($self, @arguments) = @_;
	my $file = undef;
	my $path = $self->{utils}->getAbsPath($arguments[0]);
	if ($#arguments == 0) {
		open ($file, "$path/hashtable.txt");
	} elsif ($#arguments == 1) {
		open ($file, "$path/$arguments[1]");
	} else {
		print $self->{message}->error("Wrong amount of parameters given: Path to archive needed.");
		exit;
	}
	if (defined $file) {
		while (my $line = <$file>) {
			my @split = split(/\:/, $line, 2);
			my @split2 = split(/$split[0]\:/, $line, 2);
			my $pair = "$split[0] : $split2[1]";
			chomp $pair;
			print $pair, "\n";
		}
	}
};

# Destruktor
sub DESTROY {
	my $self = shift;
	$self->{message} = undef;
	$self->{instances} = undef;
};

1;
__END__