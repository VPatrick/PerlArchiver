use strict;
use warnings;

# Instances
# Beschreibung: Dieses Modul erzeugt Instanzen von diversen Klassen
# Autor:		Patrick Vogt
# Datum:		Januar 2015
package Instances;

# Konstruktor
sub new {
	my ($invocant, $level) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	bless ($self, $class);
	return $self;
};

# get_create_instance
# Beschreibung: Erzeugt eine Instanz von Create
# Parameter: level	Verbose-Level
sub create {
	my ($self, $level) = @_;
	use Create;
	my $instance = undef;
	if (!$instance) {
		$instance = Create->new;
	}
	if ($level and $level > 0) {
		$instance->setVerboseLevel($level);
	}
	return $instance;
};

# get_restore_instance
# Beschreibung: Erzeugt systemabhängig eine Instanz von Restore oder RestoreWin
# Parameter: level	Verbose-Level
sub restore {
	my ($self, $level) = @_;
	my $instance = undef;
	if (!$instance) {
		if ($^O == "MSWin32") {
			use RestoreWin;
			$instance = RestoreWin->new;
		} else {
			use Restore;
			$instance = Restore->new;
		}
	}
	if ($level and $level > 0) {
		$instance->setVerboseLevel($level);
	}
	return $instance;
};

1;
__END__