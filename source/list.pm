use strict;
use warnings;
use Cwd;
use Message;
use Utils;
use Verbosity;

# List
# Beschreibung: Dieses Modul listet die Inhalte eines Archivs auf
# Autor:		Patrick Vogt
# Datum:		Dezember 2014
package List;

# Konstruktor
sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		verbosity => Verbosity->new,
		message => Message->new,
		utils => Utils->new
	};
	bless ($self, $class);
	return $self;
};

# setVerboseLevel
# Beschreibung: Setzt das Verbose-Level
# Parameter: level	Verbose-Level
sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{verbosity}->setVerboseLevel($level);
};

# list
# Beschreibung: Durchforstet das aufzulistende Archiv
# Parameter: archive	Verzeichnis zu den Archiven
#			 timestamp	Zeitpunkt
sub list {
	use File::Find qw(find);
	my ($self, $archive, $timestamp) = @_;
	if ($timestamp !~ m/^\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}/i) {
		print $self->{message}->error("No valid timestamp: yyyy_mm_dd_hh_ii_ss");
		exit;
	}
	
	chdir $archive;
	$archive = Cwd::getcwd();
	
	if ($self->{verbosity}->getVerboseLevel() > 0) {
		$self->{utils}->setVerboseLevel($self->{verbosity}->getVerboseLevel());
	}
	
	my @list;
	find(sub {
		return if($_ eq '.' || $_ eq '..');
		push @list, $File::Find::name;
	}, $self->{utils}->findLastValidArchive($archive, $timestamp));
	
	$self->print_list(@list);
};

# print_list
# Beschreibung: Gibt den Archivinhalt auf STDOUT aus
# Parameter: list
sub print_list {
	my ($self, @list) = @_;
	foreach (@list) {
		if (-l $_ or $_ =~ m/.lnk$/i) {
			$_ =~ m|(/[^/]+?)$|;
			print "lnk\t$1\n";
		} elsif (-d $_) {
			$_ =~ m|(/[^/]+?)$|;
			print "dir\t$1\n";
		} else {
			$_ =~ m|(/[^/]+?)$|;
			print "\t$1\n";
		}
	}
};

# Destruktor
sub DESTROY {
	my $self = shift;
	$self->{verbosity} = undef;
	$self->{message} = undef;
	$self->{utils} = undef;
};

1;
__END__