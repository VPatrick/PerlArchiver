use strict;
use warnings;
use Verbosity;

package List;

sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		verbosity => Verbosity->new(0)
	};
	bless ($self, $class);
	return $self;
};

sub list {
	use File::Find qw(find);
	my ($self, $archive, $timestamp) = @_;
	
	if ($timestamp =~ m/^\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}/) {
		die $self->{verbosity}->error("Der übergebene Zeitstempel entspricht nicht dem vorgegebenen Format: yyyy_mm_dd_HH_MM_SS");
	}
	
	my @list;
	find(sub {
		return if($_ eq '.' || $_ eq '..');
		push @list, $File::Find::name;
	}, $archive || ".");
	$self->print_list(@list);
};

sub print_list {
	my ($self, @list) = @_;
	foreach (@list) {
		if (-d $_) {
			print "d\t$_\n";
		} else {
			print "\t$_\n";
		}
	}
};

1;
__END__