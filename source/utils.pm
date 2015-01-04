use strict;
use warnings;
use Verbosity;

package Utils;

sub new {
	my ($invocant) = @_;
	my $class = ref($invocant) || $invocant;
	my $self = {
		verbosity => Verbosity->new
	};
	bless ($self, $class);
	return $self;
};

sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{verbosity}->setVerboseLevel($level);
};

sub findLastValidArchive {
	my ($self, $source, $timestamp) = @_;
	opendir(my $dir, $source);
	my $finalSource = "";
	my $finalTimestamp = "";
	my $tmpTimestamp = "0000_00_00_00_00_00";
	while(readdir $dir)
	{
		if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
		{
			my ($archiveName, $archiveTimestamp) = split(/_/, $_, 2);
			$self->{verbosity}->verbose("Compare times:");
			if($archiveName)
			{
				if($self->compare_to($archiveTimestamp) <= $self->compare_to($timestamp))
				{
					$self->{verbosity}->verbose("Compare $archiveTimestamp with $timestamp");
					if($self->compare_to($archiveTimestamp) > $self->compare_to($tmpTimestamp))
					{
						$tmpTimestamp = $archiveTimestamp;
						$finalSource = "${source}/${_}";
						$finalTimestamp = $archiveTimestamp;
					}
				}
			}
		}
	}
	closedir($dir);
	return $finalSource;
};

sub compare_to {
	my ($self, $date) = @_;
	my($y,$m,$d,$H,$M,$S) = split(/_/,$date);
	return "$y$m$d$H$M$S";
};

sub get_os {
	my $self = shift;
	return $^O;
}

1;
__END__