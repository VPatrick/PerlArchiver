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


package Restore;

our $FinalTime;
our $_Verbose= "";

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
sub addVerbose{
	my ($self, $_verbose) = @_;
	$_Verbose = "0" if($_verbose eq "0");
	$_Verbose = "1" if($_verbose eq "1");
}


sub restore_r
{
	Verbose("Start Restore r.\n");
	my $self = shift;
	$SourceArchiv = Find_source_r
	(
		$self -> {source},
		$self -> {sourcename},
		$self -> {usertime},
	);
	chop($SourceArchiv);
	Verbose("Find Source Directory: $SourceArchiv.\n");
	die "The given path is not a directory!\n" if(!(-d $SourceArchiv));
	RestoreDirectory
	(
		$SourceArchiv,
		$self -> {destination},
		$self -> {sourcename},
	);
}

sub restore_rp
{
	Verbose("Start Restore rp.");
	my $self = shift;
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
	die "The given Subdirectory or File does not exist!" if (!(-f $FileorArchivSource || -d $FileorArchivSource));
	$FileorArchivDestination = Find_source_rp
	(
		$self -> {destination},
		$self -> {partial},
	);
	die "The given destination path does not exist!\nPlease set a directory or file with the given name!" if(!(-f $FileorArchivDestination||-d $FileorArchivDestination));
	if(-d $FileorArchivSource){
		Verbose("Find source directory path: $FileorArchivSource .");
		Verbose("Find destination directory path: $FileorArchivDestination .");
		RestoreSubDirectory
		(
			$FileorArchivSource,
			$FileorArchivDestination,
			$self->{partial},
		);
	}
	elsif(-f $FileorArchivSource)
	{
		Verbose("Find source file path: $FileorArchivSource\n.");
		Verbose("Find destination file path: $FileorArchivDestination\n.");
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
	my ($source,$sourcename,$Time) = @_;
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
			
			if($ArchivName eq $sourcename)
			{
				if(compare_to($ArchivTime) <= compare_to($Time))
				{
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
	my ($Directory,$Sourcename) = @_;
	opendir Dir, $Directory || die "Can`t open Directory!";
	my @Files = readdir Dir;
	closedir Dir;
	foreach (@Files)
	{
		if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
		{
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
	my($SourceArchiv,$Destination,$SourceName) = @_;
	$DestinationName = DestinationArchiv($Destination,$SourceName);
	if($_Verbose==1){
		File::Path::remove_tree("${Destination}/${DestinationName}",{ verbose=>1,});
	}
	else{
		File::Path::remove_tree("${Destination}/${DestinationName}");
	}
	File::Path::make_path("${Destination}/${SourceName}_<${FinalTime}>");
	Verbose("Make Dir: ${Destination}/${SourceName}_<${FinalTime}>");
	File::Copy::Recursive::dircopy($SourceArchiv,"${Destination}/${SourceName}_<${FinalTime}>");
	Verbose("Copy Dir");
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
	my($Source,$Destination,$SourceName)=@_;
	$FatherDir = DirectoryUp($Destination);
	File::Path::remove_tree($Destination,{verbose=>1}) if($_Verbose eq "1");
	File::Path::remove_tree($Destination) if ($_Verbose eq "0");
	Verbose("Make Dir: ${FatherDir}/${SourceName}\n");
	File::Path::make_path("${FatherDir}/${SourceName}");
	Verbose("Copy Dir\n");
	File::Copy::Recursive::dircopy($Source, "${FatherDir}/${SourceName}");
}


##########################################################################################
#									RestoreFile											 #
#				Hilfsfunktion um eine Datei wieder herzustellen							 #
##########################################################################################
sub RestoreFile{
	my($Source,$Destination)=@_;
	$FatherDir = DirectoryUp($Destination);
	Verbose("Delete Destinationfile: $Destination.\n");
	unlink($Destination);
	Verbose("Copy File to Destination\n");
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

sub Verbose{
	my $message=shift;
    if($_Verbose eq "1")
    {
        print $message . "\n" ;
    }
}

sub DESTROY{
    my $self = shift;
	$FinalTime ="";
	$_Verbose = "";
	Verbose("Destroy");
};
1;
__END__