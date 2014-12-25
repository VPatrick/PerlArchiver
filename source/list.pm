use strict;
use warnings;

package List;

sub new {
	my ($invocant, $source) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		source => $source
	};
	bless ($self, $class);
	return $self;
};

sub list {
	my ($self, $directory) = @_;
	$self->traverse($directory || ".", "");
};

sub traverse {
	my ($self, $dir, $margin) = @_;
	print "[DIR]\t$dir\n";
	chdir ($dir) || die "Cannot chdir to $dir\n";
	local (*DIR);
	opendir (DIR, ".");
	while (my $f = readdir(DIR)) {
		next if ($f eq "." or $f eq "..");
		print "$margin$f\n";
		if (-d $f) {
			print "[REC]\t$f\n";
			&traverse($f, $margin."    ");
		}
	}
	closedir (DIR);
	chdir("..");
};

1;
__END__