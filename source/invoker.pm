use strict;
use warnings;
use Verbosity;
use Message;

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
	$self->{level} = $level;
	$self->{verbosity}->setVerboseLevel($level);
};

# create
# Beschreibung: Ruft die Funktion create auf
# Parameter:	arguments	Parameter für create
sub create {
	my ($self, @arguments) = @_;
	#if ($#arguments == 1) {
	#	use Create;
	#	my $create = Create->new;
	#	if ($self->{level} > 0) {
	#		$create->setVerboseLevel($self->{level});
	#	}
	#	$create->addSource($arguments[0]);
	#	$create->addDestination($arguments[1]);
	#	$create->create_c();
	#} else {
	#	print $self->{message}->error("Two parameters needed.");
	#	exit;
	#}
};

# slim
# Beschreibung: Ruft die Funktion slim auf
# Parameter:	arguments	Parameter für slim
sub slim {
	my ($self, @arguments) = @_;
	#if ($#arguments == 0) {
	#	use Create;
	#	my $create = Create->new;
	#	if ($self->{level} > 0) {
	#		$create->setVerboseLevel($self->{level});
	#	}
	#	$create->addDestination($arguments[0]);
	#	$create->create_s();
	#} else {
	#	print $self->{message}->error("One parameters needed.");
	#	exit;
	#}
}

# restore
# Beschreibung: Ruft die Funktion restore auf
# Parameter:	arguments	Parameter für restore
sub restore {
	my ($self, @arguments) = @_;
	if ($#arguments == 3) {
	#	if ($^O == "MSWin32") {
	#		use RestoreWin;
	#		my $restore_win = RestoreWin->new;
	#		if ($self->{level} > 0) {
	#			$restore_win->setVerboseLevel($self->{level});
	#		}
	#		$restore_win->addSource($arguments[0]);
	#		$restore_win->addDestination($arguments[1]);
	#		$restore_win->addSourceName($arguments[2]);
	#		$restore_win->addUserTime($arguments[3]);
	#		$restore_win->restore_r();
	#	} else {
	#		use Restore;
	#		my $restore = Restore->new;
	#		if ($self->{level} > 0) {
	#			$restore->setVerboseLevel($self->{level});
	#		}
	#		$restore->addSource($arguments[0]);
	#		$restore->addDestination($arguments[1]);
	#		$restore->addSourceName($arguments[2]);
	#		$restore->addUserTime($arguments[3]);
	#		$restore->restore_r();
	#	}
		print "restore\n";
	} else {
		print $self->{message}->error("Four parameters needed.");
		exit;
	}
};

# partial
# Beschreibung: Ruft die Funktion partial auf
# Parameter:	arugments	Parameter für partial
sub partial {
	my ($self, @arguments) = @_;
	print "partial\n";
}

# del
# Beschreibung: Ruft die Funktion delete auf
# Parameter:	arguments	Parameter für delete
sub del {
	my ($self, @arguments) = @_;
	if ($#arguments == 0) {
	#	use del;
	#	my $delete = del->new($arguments[0]);
	#	if ($self->{level} > 0) {
	#		# Verbose-Mode aktivieren
	#	}
		print "delete\n";
	} else {
		print $self->{message}->error("One parameter needed.");
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
		print $self->{message}->error("Two parameters needed.");
		exit;
	}
};

1;
__END__