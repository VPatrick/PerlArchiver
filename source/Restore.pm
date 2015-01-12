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
use Utils;


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
        verbosity => Verbosity->new(0),
    };
    bless ($self, $class);
    $self->{verbosity}->verbose("New","OK");
    return $self;
}

sub addSource{
    my ($self,$Source) = @_;
    $self->{source}=$Source;
    $self->{verbosity}->verbose("New source added: $self->{source}");
}
sub addDestination{
    my ($self, $Destination) = @_;
    $self->{destination} = $Destination;
    $self->{verbosity}->verbose("New destination added: $self->{destination}");
}
sub addSourceName{
    my ($self, $Sourcename) = @_;
    $self->{sourcename} = $Sourcename;
    $self->{verbosity}->verbose("New source name added: $self->{sourcename}");
}
sub addUserTime{
    my ($self, $Usertime) = @_;
    die "The given time is not a valid format!" if (!$Usertime  =~ m/^\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}/);
    $self->{usertime} = $Usertime;
    $self->{verbosity}->verbose("New usertime added: $self->{usertime}");
}
sub addPartial{
    my($self,$Partial) = @_;
    $self->{partial} = $Partial;
    $self->{verbosity}->verbose("New partial added: $self->{partial}");
}
sub setVerboseLevel{
    my ($self,$level) =@_;
    $self->{verbosity}->setVerboseLevel($level);
}

sub restore_r
{
    my $self = shift;
    $self->{verbosity}->verbose("Start Restore r.\n","OK");
	$tmp = Utils->new();
	$SourceArchiv = $tmp->findLastValidArchive
	(
	$self->{source},
	$self->{usertime},
	);
    chop($SourceArchiv);
    $self->{verbosity}->verbose("Find Source Directory: $SourceArchiv.\n","OK");
    $self->{verbosity}->verbose("The given path is not a directory!\n","WARNING");
    die if(!(-d $SourceArchiv));
    RestoreDirectory
    (
    $self,
    $SourceArchiv,
    );
}

sub restore_rp
{
    my $self = shift;
    $self->{verbosity}->verbose("Start Restore rp.","OK");
	$tmp = Utils->new();
	$SourceArchiv = $tmp->findLastValidArchive
	(
	$self->{source},
	$self->{usertime},
	);
    chop($SourceArchiv);
    my $partial = $self->{partial};
    $FileorArchivSource = Find_source_rp
    (
    $SourceArchiv,
    $partial,
    );
    $self->{verbosity}->verbose("The given Subdirectory or File does not exist!","WARNING");
    die if (!(-f $FileorArchivSource || -d $FileorArchivSource));
    my $destination = $self->{destination};
    $FileorArchivDestination = Find_source_rp
    (
    $destination,
    $partial,
    );
    
    if(-d $FileorArchivSource)
    {
        File::Path::make_path("$self->{destination}/$self->{partial}");
        $FileorArchivDestination = "$self->{destination}/$self->{partial}";
    }
    elsif(-f $FileorArchivSource)
    {
        $self->{verbosity}->verbose("There is no file with the given name.\nThe file will be restored in the destination folder!","WARNUNG");
        $FileorArchivDestination = $self->{destination};
    }
    
    $self->{verbosity}->verbose("The given destination path does not exist!\nPlease set a directory or file with the given name!","WARNING");
    die if(!(-f $FileorArchivDestination||-d $FileorArchivDestination));
    if(-d $FileorArchivSource){
        $self->{verbosity}->verbose("Find source directory path: $FileorArchivSource.","OK");
        $self->{verbosity}->verbose("Find destination directory path: $FileorArchivDestination.","OK");
        RestoreSubDirectory
        (
        $FileorArchivSource,
        $FileorArchivDestination,
        $self,
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
        $self,
        );
    }
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
    my ($Directory,$partial) = @_;
    opendir Dir, $Directory || die "Can`t open Directory!";
    my @Files = readdir Dir;
    closedir Dir;
    return "${Directory}/${partial}" if(grep(/$partial/,@Files));
    foreach (@Files)
    {
        if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
        {
            if(-d "${Directory}/${_}")
            {
                return "${Directory}/${_}" if($_ eq $partial);
                return Find_source_rp("${Directory}/${_}",$partial);
            }
        }
    }
}


##########################################################################################
#									RestoreDirectory									 #
#				Hilfsfunktion um ein ganzes Verzeichnis wieder herzustellen				 #
##########################################################################################
sub RestoreDirectory{
    my($self,$SourceArchiv) = @_;
    $DestinationName = DestinationArchiv($self->{destination},$self->{sourcename});
    $self->{verbosity}->verbose("Remove $self->{destination}/${DestinationName}\n","OK");
    File::Path::remove_tree("$self->{destination}/${DestinationName}") if(-d "$self->{destination}/${DestinationName}");
    $self->{verbosity}->verbose("Make $self->{destination}/$self->{sourcename}}_<${FinalTime}>\n","OK");
    File::Path::make_path("$self->{destination}/$self->{sourcename}_<${FinalTime}>");
    $self->{verbosity}->verbose("Copy from $SourceArchiv to $self->{destination}}/$self->{sourcename}_<${FinalTime}>","OK");
    File::Copy::Recursive::dircopy($SourceArchiv,"$self->{destination}/$self->{sourcename}_<${FinalTime}>");
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
    my($Source,$Destination,$self)=@_;
    $FatherDir = DirectoryUp($Destination);
    $self->{verbosity}->verbose("Remove $Destination\n","OK")if(-d $Destination);
    File::Path::remove_tree($Destination) if(-d $Destination);
    $self->{verbosity}->verbose("Make Dir: ${FatherDir}/$self->{partial}\n","OK");
    File::Path::make_path("${FatherDir}/$self->{partial}");
    $self->{verbosity}->verbose("Copy Dir from $Source to ${FatherDir}/$self->{partial}\n","OK");
    File::Copy::Recursive::dircopy($Source, "${FatherDir}/$self->{partial}");
}


##########################################################################################
#									RestoreFile											 #
#				Hilfsfunktion um eine Datei wieder herzustellen							 #
##########################################################################################
sub RestoreFile{
    my($Source,$Destination,$self)=@_;
    if(-f $Destination)
    {
        my $FatherDir = DirectoryUp($Destination) if(-f $Destination);
        $self->{verbosity}->verbose("Delete Destinationfile: $Destination.\n");
        unlink($Destination);
        $self->{verbosity}->verbose("Copy File to $FatherDir\n");
        File::Copy::copy($Source,$FatherDir);
    }
    elsif(-d $Destination)
    {
        $self->{verbosity}->verbose("Copy file to $Destination","OK");
        File::Copy::copy($Source,$Destination);
    }
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