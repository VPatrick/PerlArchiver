use strict;
use warnings;
use Cwd;
use Message;
use Utils;
use Verbosity;

package List;

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

sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{verbosity}->setVerboseLevel($level);
};

sub list {
	use File::Find qw(find);
	my ($self, $archive, $timestamp) = @_;
	if ($timestamp !~ m/^\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}/i) {
		print $self->{message}->error("No valid timestamp: yyyy_mm_dd_HH_MM_SS");
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

sub print_list {
	my ($self, @list) = @_;
	foreach (@list) {
		if (-l $_) {
			$_ =~ m|(/[^/]+?)$|;
			print "link\t$1\n";
		} elsif (-d $_) {
			$_ =~ m|(/[^/]+?)$|;
			print "dir\t$1\n";
		} else {
			$_ =~m|(/[^/]+?)$|;
			print "\t$1\n";
		}
	}
};

1;
__END__