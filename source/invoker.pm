use strict;
use warnings;
use Verbosity;
use Message;
use Instances;

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
		verbosity => Verbosity->new,
		message => Message->new,
		instances => Instances->new,
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
		print $self->{message}->error("Wrong amount of parameters given: ");
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
		if (-d $arguments[1]) {
			$create->create_s();
		} else {
			$create->addDestination($arguments[0]);
			$create->addArchiveName($arguments[1]);
			$create->create_s();
		}
	} else {
		print $self->{message}->error("Wrong amount of paramters given: ");
		exit;
	}
};

# restore
# Beschreibung: Ruft die Funktion restore auf
# Parameter:	arguments	Parameter für restore
sub restore {
	my ($self, @arguments) = @_;
	if ($#arguments == 3) {
		my $restore = $self->{instances}->restore($self->{level});
		$restore->addSource($arguments[0]);
		$restore->addDestination($arguments[1]);
		$restore->addSourceName($arguments[2]);
		$restore->addUserTime($arguments[3]);
		$restore->restore_r();
	} else {
		print $self->{message}->error("Wrong amount of parameters given: ");
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
		print $self->{message}->error("Wrong amount of parameters given: ");
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
			#use del;
			#my $delete = del->new;
			#if ($self->{level} > 0) {
			#	$delete->setVerboseLevel($self->{level});
			#}
			#$delete->addDestination($arguments[0]);
			#$delete->delete_d();
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
		$list->list($arguments[0], $arguments[1]);
	} else {
		print $self->{message}->error("Wrong amount of paramters given: Path to an archive and a timestamp (yyyy_mm_dd_hh_ii_ss) needed.");
		exit;
	}
};

# Destruktor
sub DESTROY {
	my $self = shift;
	$self->{verbosity} = undef;
	$self->{message} = undef;
	$self->{instances} = undef;
};

1;
__END__
