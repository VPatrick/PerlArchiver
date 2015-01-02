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
	my ($self, $directory) = @_;
	my @list;
	find(sub {
		return if($_ eq '.' || $_ eq '..');
		push @list, $File::Find::name;
	}, $directory || ".");
	$self->print_list(@list);
};

sub print_list {
	my ($self, @list) = @_;
	foreach (@list) {
		if (-d $_) {
			print "Directory\n";
		} else {
			print "File\n";
		}
	}
};

1;
__END__