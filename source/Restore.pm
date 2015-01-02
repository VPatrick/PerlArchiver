##########################################################################################
#										Restore											 #
#Dieses Modul stellt eine ganzes Verzeichnis, Unterverzeichnis oder eine Datei wieder her#
#								Autor: Muhammed Kasikci									 #
#								Erstellt am 12.2014										 #
##########################################################################################

use warnings;
use File::Find;
use File::Copy;
use File::Copy::Recursive;
use File::Path qw(make_path remove_tree);
use Verbosity;


package Restore;

our $FinalTime;

sub new
{
    my $invocant = shift;
    my $class   = ref($invocant) || $invocant;
    my $self = {
        source  => "",
		sourcename => "",
        destination   => "",
		usertime => "",
		partial => "",
        verbosity => Verbosity->new(0);
    };
    return bless ($self, $class);
}

sub addSource{
    my ($self,$Source) = @_;
    $self->{source}=$Source;
}
sub addDestination{
	my ($self, $destination) = @_;
	$self->{destination} = $destination;
}
sub addSourceName{
	my ($self, $sourcename) = @_;
	$self->{sourcename} = $sourcename;
}
sub addUserTime{
	my ($self, $usertime) = @_;
	die "Angegeben Zeit entspricht nicht dem Format!" if $self -> {usertime}  =~ m/^\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}/;
	$self->{usertime} = $usertime;
}
sub addPartial{
	my($self,$partial) = @_;
	$self->{partial} = $partial;
}
sub setVerboseLevel{
    my ($self,$level) =@_;
    $self->{verbosity}->setVerboseLevel($level);
}

sub restore_r
{
	my $self = shift;
    $self->{verbosity}->verbose("Start Restore r.\n","OK");
	$SourceArchiv = Find_source_r
	(
		$self -> {source},
		$self -> {sourcename},
		$self -> {usertime},
	);
	chop($SourceArchiv);
    $self->{verbosity}->verbose("Find Source Directory: $SourceArchiv.\n","OK");
    $self->{verbosity}->verbose("The given path is not a directory!\n","WARNING");
	die if(!(-d $SourceArchiv));
	RestoreDirectory
	(
		$SourceArchiv,
		$self -> {destination},
		$self -> {sourcename},
	);
}

sub restore_rp
{
    my $self = shift;
    $self->{verbosity}->verbose("Start Restore rp.","OK");
	$SourceArchiv = Find_source_r
	(
		$self -> {source},
		$self -> {sourcename},
		$self -> {usertime},
	);
	chop($SourceArchiv);
	$FileorArchivSource = Find_source_rp
	(
		$SourceArchiv,
		$self -> {partial},
	);
    $self->{verbosity}->verbose("The given Subdirectory or File does not exist!","WARNING");
	die if (!(-f $FileorArchivSource || -d $FileorArchivSource));
	$FileorArchivDestination = Find_source_rp
	(
		$self -> {destination},
		$self -> {partial},
	);
    $self->{verbosity}->verbose("The given destination path does not exist!\nPlease set a directory or file with the given name!","WARNING");
	die if(!(-f $FileorArchivDestination||-d $FileorArchivDestination));
	if(-d $FileorArchivSource){
        $self->{verbosity}->verbose("Find source directory path: $FileorArchivSource.","OK");
        $self->{verbosity}->verbose("Find destination directory path: $FileorArchivDestination.","OK");
		RestoreSubDirectory
		(
			$FileorArchivSource,
			$FileorArchivDestination,
			$self->{partial},
		);
	}
	elsif(-f $FileorArchivSource)
	{
        $self->{verbosity}->verbose("Find source file path: $FileorArchivSource\n.","OK");
        $self->{verbosity}->verbose("Find destination file path: $FileorArchivDestination\n.","OK");
		RestoreFile
		(
			$FileorArchivSource,
			$FileorArchivDestination,
		);
	}
}


##########################################################################################
#									Find_source_r										 #
#			Hilfsfunktion um das passenste Verzeichnis zu finden (angegebene Zeit)		 #
##########################################################################################
sub Find_source_r
{
	my ($self,$source,$sourcename,$Time) = @_;
	my $FinalSource = "";
	my $FileTime= "";
	my $TmpTime="0000_00_00_00_00_00";
	opendir(my $dir, $source);
	while(readdir $dir)
	{
		if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
		{
			@tmp = split(/[<>]/, $_);
			@tmp1 = split(/_/,$tmp[0]);
			$ArchivName = $tmp1[0];
			$ArchivTime = $tmp[1];
			
            $self->{verbosity}->verbose("Compare times:\n","OK");
            
			if($ArchivName eq $sourcename)
			{
				if(compare_to($ArchivTime) <= compare_to($Time))
				{
                    $self->{verbosity}->verbose("Compare $ArchivTime with $Time");
					if(compare_to($ArchivTime) > compare_to($TmpTime))
					{
						$tmpTime = $ArchivTime;
						$FinalSource = "${source}/${_}";
						$FinalTime = $ArchivTime;
					}
				}
			}
		}
	}
	closedir($dir);
	return "$FinalSource\n";
}


##########################################################################################
#									compare_to											 #
#				Hilfsfunktion zum vergleichen von zwei Daten							 #
##########################################################################################
sub compare_to
{
	my $date = shift;
	my($y,$m,$d,$H,$M,$S) = split(/_/,$date);
	return "$y$m$d$H$M$S";
}


##########################################################################################
#									Find_source_rp										 #
#				Hilfsfunktion um eine bestimmte Datei oder Verzeichnis zu finden		 #
##########################################################################################
sub Find_source_rp
{
	my ($self,$Directory,$Sourcename) = @_;
	opendir Dir, $Directory || die "Can`t open Directory!";
	my @Files = readdir Dir;
	closedir Dir;
	foreach (@Files)
	{
		if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
		{
            $self->{verbosity}->verbose("Search in $Directory\n");
			if(-f "${Directory}/${_}")
			{
				return "${Directory}/${_}" if ($_ eq $Sourcename)
			}
			elsif(-d "${Directory}/${_}")
			{
				return "${Directory}/${_}" if($_ eq $Sourcename);
				return Find_source_rp("${Directory}/${_}",$Sourcename);
			}
		}
	}
}


##########################################################################################
#									RestoreDirectory									 #
#				Hilfsfunktion um ein ganzes Verzeichnis wieder herzustellen				 #
##########################################################################################
sub RestoreDirectory{
	my($self,$SourceArchiv,$Destination,$SourceName) = @_;
	$DestinationName = DestinationArchiv($Destination,$SourceName);
    $self->{verbosity}->verbose("Remove ${Destination}/${DestinationName}\n","OK");
    File::Path::remove_tree("${Destination}/${DestinationName}");
    $self->{verbosity}->verbose("Make ${Destination}/${SourceName}_<${FinalTime}>\n","OK");
	File::Path::make_path("${Destination}/${SourceName}_<${FinalTime}>");
    $self->{verbosity}->verbose("Copy from $SourceArchiv to ${Destination}/${SourceName}_<${FinalTime}>","OK");
	File::Copy::Recursive::dircopy($SourceArchiv,"${Destination}/${SourceName}_<${FinalTime}>");
}


##########################################################################################
#									DestinationArchiv									 #
#				Hilfsfunktion um die genau Adresse des Zielverzeichnis zu erhalten		 #
##########################################################################################
sub DestinationArchiv{
	my ($Destination,$SourceName) = @_;
	opendir DIR,$Destination;
	my @DestinationFiles = readdir DIR;
	closedir DIR;
	foreach (@DestinationFiles)
	{
		if ($_ =~ m/${SourceName}*/){
			return $_;
		}
	}
}


##########################################################################################
#									RestoreSubDirectory									 #
#				Hilfsfunktion um ein Unterverzeichnis wieder herzustellen				 #
##########################################################################################
sub RestoreSubDirectory{
	my($self,$Source,$Destination,$SourceName)=@_;
	$FatherDir = DirectoryUp($Destination);
    $self->{verbosity}->verbose("Remove $Destination\n","OK");
	File::Path::remove_tree($Destination) if ($_Verbose eq "0");
    $self->{verbosity}->verbose("Make Dir: ${FatherDir}/${SourceName}\n","OK");
	File::Path::make_path("${FatherDir}/${SourceName}");
    $self->{verbosity}->verbose("Copy Dir from $Source to ${FatherDir}/${SourceName}\n","OK");
	File::Copy::Recursive::dircopy($Source, "${FatherDir}/${SourceName}");
}


##########################################################################################
#									RestoreFile											 #
#				Hilfsfunktion um eine Datei wieder herzustellen							 #
##########################################################################################
sub RestoreFile{
	my($self,$Source,$Destination)=@_;
	$FatherDir = DirectoryUp($Destination);
    $self->{verbosity}->verbose("Delete Destinationfile: $Destination.\n");
	unlink($Destination);
    $self->{verbosity}->verbose("Copy File to $FatherDir\n");
	File::Copy::copy($Source,$FatherDir);
}


##########################################################################################
#									DirectoryUp											 #
#				Hilfsfunktion um ein Verzeichnis hoch zu wechseln						 #
##########################################################################################
sub DirectoryUp{
	@tmp = split(/\//,shift);
	$Return ="";
	for(my $i = 1;$i < scalar(@tmp)-1; $i++)
	{
		$Return .= "/${tmp[$i]}";
	}
	return $Return;
}


sub DESTROY{
    my $self = shift;
	$FinalTime ="";
    $self->{verbosity}->verbose("Destroy");
};
1;
__END__