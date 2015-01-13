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

my $create_instance = undef;

# get_create_instance
# Beschreibung: Erzeugt eine Instanz von Create
# Parameter: level	Verbose-Level
sub create {
	my ($self, $level) = @_;
	use Create;
	if (! defined $create_instance) {
		$create_instance = Create->new;
	}
	if ($level and $level > 0) {
		$create_instance->setVerboseLevel($level);
	}
	return $create_instance;
};

my $restore_instance = undef;

# get_restore_instance
# Beschreibung: Erzeugt systemabhängig eine Instanz von Restore oder RestoreWin
# Parameter: level	Verbose-Level
sub restore {
	my ($self, $level) = @_;
	if (! defined $restore_instance) {
		if ($^O == "MSWin32") {
			use RestoreWin;
			$restore_instance = RestoreWin->new;
		} else {
			use Restore;
			$restore_instance = Restore->new;
		}
	}
	if ($level and $level > 0) {
		$restore_instance->setVerboseLevel($level);
	}
	return $restore_instance;
};

1;
__END__