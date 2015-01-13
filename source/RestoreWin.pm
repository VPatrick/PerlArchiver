##########################################################################################
#										Restore											 #
#Dieses Modul stellt eine ganzes Verzeichnis, Unterverzeichnis oder eine Datei wieder her#
#								Autor: Muhammed Kasikci									 #
#								Erstellt am 12.2014										 #
##########################################################################################

use strict;
use warnings;
use File::Find;
use File::Copy;
use File::Copy::Recursive;
use File::Path qw(make_path remove_tree);
use Verbosity;
use Utils;


package RestoreWin;

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
        rel_path => "",
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
    $self->{rel_path} = "0";
    $self->{rel_path} = "1" if($Partial =~ m/\//);
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
    my $tmp = Utils->new();
    $self->{verbosity}->verbose("Call findLastValidArchive\n","OK");
    my $SourceArchiv = $tmp->findLastValidArchive
    (
    $self->{source},
    $self->{usertime},
    );
    $self->{verbosity}->verbose("Find Source Directory: $SourceArchiv.\n","OK");
    $self->{verbosity}->verbose("The given path is not a directory!\n","ERROR") if(!(-d $SourceArchiv));
    die if(!(-d $SourceArchiv));
    $self->verbosity->verbose("Call Restore Directory!\n","OK");
    RestoreDirectory
    (
    $SourceArchiv,
    $self,
    );
}

sub restore_rp
{
    my $self = shift;
    $self->{verbosity}->verbose("Start Restore rp.","OK");
    my $tmp = Utils->new();
    # Hier wird der genaue Pfad (d.h. mit datetime Ergänzung herausgefunden)
    $self->{verbosity}->verbose("Call findLastValidArchive\n","OK");
    my $SourceArchiv = $tmp->findLastValidArchive
    (
    $self->{source},
    $self->{usertime},
    );
    # Falls ein relativer Pfad angegeben wurde werden die angegeben Pfade um den relative Pfad erweitert
    my $partial = $self->{partial};
    my $FileorArchivSource = "";
    my $FileorArchivDestination = "";
    my $FileCopied = 0;
    if($self->{rel_path} eq "1"){
        $self->{verbosity}->verbose("Partial is a relative path\n","OK");
        $FileorArchivSource = "$SourceArchiv$self->{partial}";
        my @tmp2 = split(/\//,$SourceArchiv);
        my $tmp2 = scalar(@tmp2)-1;
        my $tmp3 = $tmp2[$tmp2];
        my @split1 = split(/_\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}$/, $tmp3);
        my $archiveName = $split1[0];
        $FileorArchivDestination = "$self->{destination}/$archiveName$self->{partial}";
    }
    else{
        # Falls dies nicht der Fall ist muss die Datei oder das Unterverzeichnis gesucht werden dabei wird der erste Treffer ausgewertet
        $self->{verbosity}->verbose("Partial is not a relative path. The first match will be processed.\n","WARNING");
        $self->{verbosity}->verbose("Call Find_source_rp\n","OK");
        $FileorArchivSource = Find_source_rp
        (
        $SourceArchiv,
        $partial,
        $self,
        );
        $self->{verbosity}->verbose("The given source subdirectory or file does not exist!\n","ERROR") if(!(-f $FileorArchivSource || -d $FileorArchivSource));
        die if (!(-f $FileorArchivSource || -d $FileorArchivSource));
        my $destination = $self->{destination};
        $self->{verbosity}->verbose("Call Find_source_rp\n","OK");
        $FileorArchivDestination = Find_source_rp
        (
        $destination,
        $partial,
        $self,
        );
        $self->{verbosity}->verbose("The given destination subdirectory or file does not exist!\n","ERROR") if(!(-f $FileorArchivSource || -d $FileorArchivSource));
    }
    # Falls das Zielverzeichnis nicht existiert wird ein Zielverzeichnis erstellt
    if(! (-e $FileorArchivDestination))
    {
        $self->{verbosity}->verbose("The destination file or directory does not exist! A new file or directory will be created!\n","WARNING");
        $self->{verbosity}->verbose("Create new directory: $FileorArchivDestination\n","OK") if(-d $FileorArchivSource);
        mkdir("$FileorArchivDestination") if(-d $FileorArchivSource);
        $self->{verbosity}->verbose("Create new file: $FileorArchivDestination\n","OK");
        File::Copy::copy $FileorArchivSource,$FileorArchivDestination if(-f $FileorArchivSource);
        $FileCopied = 1 if(-f $FileorArchivSource);
    }
    die if(!(-f $FileorArchivDestination||-d $FileorArchivDestination));
    # Falls es ein Directory ist wird die RestoreSubDirectory- aufgerufen falls es ein File ist die RestoreFile Methode
    if(-d $FileorArchivSource){
        $self->{verbosity}->verbose("Find source directory path: $FileorArchivSource.","OK");
        $self->{verbosity}->verbose("Find destination directory path: $FileorArchivDestination.","OK");
        $self->{verbosity}->verbose("Call RestoreSubDirectory\n","OK");
        RestoreSubDirectory
        (
        $FileorArchivSource,
        $FileorArchivDestination,
        $self,
        );
    }
    elsif(-f $FileorArchivSource)
    {
        $self->{verbosity}->verbose("Find source file path: $FileorArchivSource.\n","OK");
        $self->{verbosity}->verbose("Find destination file path: $FileorArchivDestination.\n","OK");
        $self->{verbosity}->verbose("Call RestoreFile.\n","OK");
        if($FileCopied eq 0)
        {
            RestoreFile
            (
            $FileorArchivSource,
            $FileorArchivDestination,
            $self,
            );
        }
    }
}


##########################################################################################
#									Find_source_rp										 #
#				Hilfsfunktion um eine bestimmte Datei oder Verzeichnis zu finden		 #
##########################################################################################
sub Find_source_rp
{
    my ($Directory,$partial,$self) = @_;
    $self->{verbosity}->verbose("Open directory $Directory\n","OK");
    opendir Dir, $Directory || die "Can`t open Directory!";
    my @Files = readdir Dir;
    closedir Dir;
    $self->{verbosity}->verbose("Close directory $Directory\n","OK");
    return "${Directory}/${partial}" if(grep(/$partial/,@Files));
    foreach (@Files)
    {
        if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
        {
            if(-d "${Directory}/${_}")
            {
                $self->{verbosity}->verbose("Found partial\n","OK"), if($_ eq $partial);
                return "${Directory}/${_}" if($_ eq $partial);
                $self->{verbosity}->verbose("Call Find_source_rp");
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
    my($SourceArchiv,$self) = @_;
    my $DestinationName = DestinationArchiv($self->{destination},$self->{sourcename});
    $self->{verbosity}->verbose("Remove $self->{destination}/${DestinationName}\n","OK") if(-d "$self->{destination}/${DestinationName}");
    File::Path::remove_tree("$self->{destination}/${DestinationName}") if(-d "$self->{destination}/${DestinationName}");
    $self->{verbosity}->verbose("Make $self->{destination}/$self->{sourcename}}\n","OK");
    File::Path::make_path("$self->{destination}/$self->{sourcename}");
    $self->{verbosity}->verbose("Copy from $SourceArchiv to $self->{destination}}/$self->{sourcename}","OK");
    File::Copy::Recursive::dircopy($SourceArchiv,"$self->{destination}/$self->{sourcename}");
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
    $self->{verbosity}->verbose("Remove $Destination\n","OK")if(-d $Destination);
    File::Path::remove_tree($Destination) if(-d $Destination);
    $self->{verbosity}->verbose("Make Dir: ${Destination}\n","OK");
    File::Path::make_path("$Destination");
    $self->{verbosity}->verbose("Copy Dir from $Source to ${Destination}/$self->{partial}\n","OK");
    File::Copy::Recursive::dircopy($Source, $Destination);
}

my $getLinkPath = sub{
    my ($self,$linkPathName)=@_;
    my $result=0;
    my $path="";
    if($^O eq "MSWin32")
    {
        require Win32::Shortcut or die("Can't import Win32::Shortcut: $!");
        my $link = Win32::Shortcut->new();
        $result=$link->Load($linkPathName);
        $path=$link->{'Path'};
        $link->Close();
        if($result)
        {
            # Verlinkung wurde aktualisiert
            $self->{verbosity}->verbose("Link found!\n","OK");
        }
        else
        {
            # Verlinkung konnte nicht aktualisiert
            $self->{verbosity}->verbose("Can't find link!\n","ERROR");
        }
    }
    return $path;
};

##########################################################################################
#									RestoreFile											 #
#				Hilfsfunktion um eine Datei wieder herzustellen							 #
##########################################################################################
sub RestoreFile{
    my($Source,$Destination,$self)=@_;
    if(-f $Destination)
    {
        $self->{verbosity}->verbose("Delete Destinationfile: $Destination.\n");
        unlink $Destination or die "Konnte nicht gelöscht werden!";
        $self->{verbosity}->verbose("Copy File to $Destination\n");
        my $path=$getLinkPath->($self,$Source);
        File::Copy::copy $path,$Destination;
        
    }
    elsif(-d $Destination)
    {
        $self->{verbosity}->verbose("Copy file to $Destination","OK");
        File::Copy::copy($Source,$Destination);
    }
}


sub DESTROY{
    my $self = shift;
    $FinalTime = undef;
    $self->{verbosity}=undef;
};
1;
__END__