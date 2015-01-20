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
use File::Path qw(make_path remove_tree);
use Verbosity;
use Utils;


package RestoreWin;

our $Flag = "0";

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
    if(-e $Source){
        $self->{source}=$Source;
        $self->{verbosity}->verbose("New source added: $self->{source}");
    }
    else
    {
        $self->{verbosity}->verbose("Can't find Source: $Source","ERROR");
    }
    
}
sub addDestination{
    my ($self, $Destination) = @_;
    if(-e $Destination){
        $self->{destination}=$Destination;
        $self->{verbosity}->verbose("New destination added: $self->{destination}");
    }
    else
    {
        $self->{verbosity}->verbose("Can't find Source: $Destination","ERROR");
    }
}
sub addSourceName{
    my ($self, $Sourcename) = @_;
    $self->{sourcename}= $Sourcename;
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
    $self->{rel_path} = "0";
    $self->{rel_path} = "1" if($Partial =~ m/\\/);
    if(!($Partial =~ m/^\\/))
    {
        my @tmp1 = split(/\\/,$Partial);
        foreach(@tmp1)
        {
            $self->{partial} .= "\\$_";
        }
    }
    else{
        $self->{partial} = $Partial;
    }
    $self->{verbosity}->verbose("New partial added: $self->{partial}");
}
sub setVerboseLevel{
    my ($self,$level) =@_;
    $self->{verbosity}->setVerboseLevel($level);
}

sub restore_r{
    my $self = shift;
    $self->{verbosity}->verbose("Start Restore r.\n","OK");
    $self->{verbosity}->verbose("Call FindArchive\n","OK");
    my $SourceArchiv = $self->FindArchive();
    $self->{verbosity}->verbose("Find Source Directory: $SourceArchiv.\n","OK");
    $self->{verbosity}->verbose("The given path is not a directory!\n","ERROR") if(!(-d $SourceArchiv));
    die if(!(-d $SourceArchiv));
    $self->{verbosity}->verbose("Call Restore Directory!\n","OK");
    $self->RestoreDirectory
    (
		$SourceArchiv,
    );
}

sub restore_rp{
    my $self = shift;
    $self->{verbosity}->verbose("Start Restore rp.","OK");
    # Hier wird der genaue Pfad (d.h. mit datetime Ergänzung herausgefunden)
    $self->{verbosity}->verbose("Call FindArchive\n","OK");
    my $SourceArchiv = $self->FindArchive();
    # Falls ein relativer Pfad angegeben wurde werden die angegeben Pfade um den relative Pfad erweitert
    # Falls nicht wird die Datei oder das Unterverzeichnis gesucht
    my $FileorArchivSource = "";
    my $FileorArchivDestination = "";
    my $FileFolder = "";
    my $FileCopied = 0;
    my $IsLink = 0;
    if($self->{rel_path} eq "1"){
        $self->{verbosity}->verbose("Partial is a relative path\n","OK");
        $FileorArchivSource = "$SourceArchiv$self->{partial}";
        
        # Prüfen ob die Datei im Archiv ein Link ist oder nicht
        my @tmp1 = split(/\\/,$self->{partial});
        my $testpath = $SourceArchiv;
        for(my $i=0;$i<$#tmp1;$i++)
        {
            $testpath .= "$tmp1[$i]";
        }
        opendir my $Dir, $testpath or $self->{verbosity}->verbose("Can not open dir $testpath","ERROR");
        my @files = readdir $Dir;
        closedir $Dir;
        foreach(@files)
        {
            $IsLink = 1 if($_ =~ m/$tmp1[$#tmp1].lnk/);
        }
        # Falls es ein link ist muss die orginal Datei gefunden werden
        $FileorArchivSource = $self->getLinkPath("$tmp1[$#tmp1].lnk",$testpath) if($IsLink == 1);
        $FileorArchivDestination = "$self->{destination}$self->{partial}";
        
        if(!(-e $FileorArchivDestination))
        {
            $FileFolder = $self->{destination};
            my @tmp = split(/\\/,$self->{partial});
            for(my $i=0; $i<$#tmp-1;$i++)
            {
                $FileFolder .= "$tmp[$i]";
            }
        }
    }
    else{
        # Falls dies nicht der Fall ist muss die Datei oder das Unterverzeichnis gesucht werden dabei wird der erste Treffer ausgewertet
        $self->{verbosity}->verbose("Partial is not a relative path. The first match will be processed.\n","WARNING");
        $self->{verbosity}->verbose("Call Find_source_rp\n","OK");
        # Es wird rekursiv nach einem Match gesucht und der erste Treffer wird zurückgegeben
		my @tmp = split(/\\/,$self->{partial});
		my $Partial = "";
		foreach (@tmp)
		{$Partial = $_ if ($_ ne "");}
		$FileorArchivSource = $self->Find_source_rp
        (
			$SourceArchiv,
			$Partial,
        );
        $self->{verbosity}->verbose("The given source subdirectory or file does not exist!\n","ERROR") if(!(-f $FileorArchivSource || -d $FileorArchivSource));
        die if (!(-f $FileorArchivSource || -d $FileorArchivSource || $FileorArchivSource =~ m/.lnk$/i));
        # Falls der Pfad der zurückgegeben wurde ein Link ist muss zuerst die orginal Datei gefunden werden
        $FileorArchivSource = $self->getLinkPath("$self->{partial}".".lnk",$SourceArchiv) if($FileorArchivSource =~ m/.lnk$/i);
        my $destination = $self->{destination};
        $self->{verbosity}->verbose("Call Find_source_rp\n","OK");
        $FileorArchivDestination = $self->Find_source_rp
        (
        $destination,
        $Partial,
        );
        $self->{verbosity}->verbose("The given destination subdirectory or file does not exist!\n","ERROR") if(!(-f $FileorArchivSource || -d $FileorArchivSource));
    }
    # Falls das Zielverzeichnis nicht existiert wird ein Zielverzeichnis erstellt
    if(! (-e $FileorArchivDestination))
    {
        if($FileorArchivDestination eq "")
        {
            $FileorArchivDestination = $self->{destination};
            my @tmp1 = split(/\\/,$FileorArchivSource);
            my @tmp2 = split(/\\/,$SourceArchiv);
            my @difference = my @intersection =();
            my %count = ();
            foreach my $element (@tmp1, @tmp2) { $count{$element}++ }
            foreach my $element (keys %count) {
                push @{ $count{$element} > 1 ? \@intersection : \@difference }, $element;
            }
            foreach(@difference)
            {
                $FileorArchivDestination .= "\\$_";
            }
        }
        $self->{verbosity}->verbose("The destination file or directory does not exist! A new file or directory will be created!\n","WARNING");
        if(-d $FileorArchivSource)
        {
            $self->{verbosity}->verbose("Create new directory: $FileorArchivDestination\n","OK");
            mkdir("$FileorArchivDestination");
        }
        else
        {
            $self->{verbosity}->verbose("Create new file: $FileorArchivDestination\n","OK") if(-f $FileorArchivSource);
            File::Copy::copy $FileorArchivSource,$FileFolder if(-f $FileorArchivSource);
            $FileCopied = 1 if(-f $FileorArchivSource);
        }
    }
    die if(!(-f $FileorArchivDestination||-d $FileorArchivDestination));
    # Falls es ein Directory ist wird die RestoreSubDirectory- aufgerufen falls es ein File ist die RestoreFile Methode
    if(-d $FileorArchivSource){
        $self->{verbosity}->verbose("Find source directory path: $FileorArchivSource.","OK");
        $self->{verbosity}->verbose("Find destination directory path: $FileorArchivDestination.","OK");
        $self->{verbosity}->verbose("Call RestoreSubDirectory\n","OK");
        $self->RestoreSubDirectory
        (
        $FileorArchivSource,
        $FileorArchivDestination,
        );
    }
    elsif(-f $FileorArchivSource)
    {
        $self->{verbosity}->verbose("Find source file path: $FileorArchivSource.\n","OK");
        $self->{verbosity}->verbose("Find destination file path: $FileorArchivDestination.\n","OK");
        $self->{verbosity}->verbose("Call RestoreFile.\n","OK");
        if($FileCopied eq 0)
        {
            $self->RestoreFile
            (
            $FileorArchivSource,
            $FileorArchivDestination,
            $self->{partial},
            );
        }
    }
}


##########################################################################################
#									Find_source_rp										 #
#				Hilfsfunktion um eine bestimmte Datei oder Verzeichnis zu finden		 #
##########################################################################################
sub Find_source_rp{
    my ($self,$Directory,$partial) = @_;
    $self->{verbosity}->verbose("Open directory $Directory\n","OK");
    opendir Dir, $Directory || die "Can`t open Directory!";
    my @Files = readdir Dir;
    closedir Dir;
    $self->{verbosity}->verbose("Close directory $Directory\n","OK");
    return "${Directory}\\${partial}" if(grep(/$partial$/,@Files));
    foreach (@Files)
    {
        if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
        {
            if($_ =~ m/$partial$/ || $_ =~ m/$partial.lnk$/)
            {
                $self->{verbosity}->verbose("Found partial\n","OK");
                return "${Directory}\\${_}";
            }
        }
    }
    foreach(@Files)
    {
        if($_ ne "." and $_ ne ".." and $_ ne ".DS_Store")
        {
            if(-d "${Directory}\\${_}")
            {
                $self->{verbosity}->verbose("Found $Directory\\${_}") if($_ =~ m/$partial/);
                return "$Directory\\${_}" if($_ =~ m/$partial/);
                $self->{verbosity}->verbose("Call Find_source_rp");
                return $self->Find_source_rp("${Directory}\\${_}",$partial);
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
    # Falls es Probleme während dem Kopiervorgang entstehen sollten wird der alte Ordner umbennant und bei einem Fehler der neu erstellt Ordner gelöscht
    my @tmp = split (/\\/,$self->{destination});
    my $tmpdestination = "$tmp[0]";
    for(my $i=1; $i<=($#tmp-1);$i++)
    {
        $tmpdestination .= "\\$tmp[$i]";
    }
    my $NewDest = $tmpdestination."\\$tmp[$#tmp] 2";
    $self->{verbosity}->verbose("Rename $self->{destination} to $NewDest!","OK");
    rename $self->{destination}, $NewDest;
    
    $self->{verbosity}->verbose("Copy from $SourceArchiv to $self->{destination}}","OK");
    $self->RecusriveRestore($SourceArchiv,"$self->{destination}");
    
    if($Flag eq "0")
    {
        $self->{verbosity}->verbose("Remove $NewDest","OK") if(-d "$NewDest");
        File::Path::remove_tree("$NewDest")if(-d "$NewDest");
    }
    else
    {
        $self->{verbosity}->verbose("Copy failed!","ERROR");
        $self->{verbosity}->verbose("Remove $self->{destination}","WARNING");
        $self->{verbosity}->verbose("Rename $NewDest to $self->{destination}","WARNING");
        File::Path::remove_tree("$self->{destination}");
        rename $NewDest, $self->{destination};
    }
}


##########################################################################################
#									RecusriveRestore									 #
#				Hilfsfunktion um ein Verzeichnis wieder herzustellen					 #
##########################################################################################
sub RecusriveRestore{
    my ($self, $Source,$Destination) = @_;
    $self->{verbosity}->verbose("Make $self->{destination}\n","OK");
    mkdir $Destination;
    opendir my ($Dir), $Source;
    my @Files = readdir $Dir;
    closedir $Dir;
    foreach (@Files)
    {
        if($_ ne ".." and $_ ne "."){
            if (-l "$Source\\$_" or $_ =~ m/.lnk$/i)
            {
                my $SourceDatei = $self->getLinkPath($_,$Source);
                $self->RestoreFile($SourceDatei,$Destination,$_);
            }
            elsif(-f "$Source\\$_"){
                $self->RestoreFile("$Source\\$_",$Destination, $_);
            }
            elsif(-d "$Source\\$_")
            {
                mkdir("$Destination\\$_");
                $self->RecusriveRestore("$Source\\$_","$Destination\\$_");
            }
            else{
                $self->{verbosity}->verbose("This is not a file or a directory $Source\\$_");
                $Flag = "1";
            }
        }
    }
}


##########################################################################################
#									RestoreSubDirectory									 #
#				Hilfsfunktion um ein Unterverzeichnis wieder herzustellen				 #
##########################################################################################
sub RestoreSubDirectory{
    my($self,$Source,$Destination)=@_;
    $self->{verbosity}->verbose("Remove $Destination\n","OK")if(-d $Destination);
    File::Path::remove_tree($Destination) if(-d $Destination);
    $self->{verbosity}->verbose("Make Dir: ${Destination}\n","OK");
    mkdir("$Destination");
    $self->{verbosity}->verbose("Copy Dir from $Source to ${Destination}\n","OK");
    $self->RecusriveRestore($Source,$Destination);
}


##########################################################################################
#									RestoreFile											 #
#				Hilfsfunktion um eine Datei wieder herzustellen							 #
##########################################################################################
sub RestoreFile{
    my($self,$SourceFile,$Destination,$File)=@_;
    if(-e "$Destination\\$File"){
        $self->{verbosity}->verbose("Delete Destinationfile: $Destination.\n","OK");
        unlink "$Destination\\$File" or die "Can`t delete File $Destination!";
        $self->{verbosity}->verbose("Copy File $SourceFile to $Destination\n","OK");
        File::Copy::copy $SourceFile,$Destination;
    }
    else{
        $self->{verbosity}->verbose("Copy File $SourceFile to $Destination\n","OK");
        File::Copy::copy $SourceFile,$Destination;
    }
    
}


##########################################################################################
#									FindArchive                                          #
#				Hilfsfunktion um das zu wiederherstellende Archvi finden				 #
##########################################################################################
sub FindArchive{
    my $self = shift;
    use Utils;
    my $tmp = Utils->new();
    $self->{verbosity}->verbose("Call findLastValidArchive","OK");
    return $tmp->findLastValidArchive($self->{source}, $self->{usertime},$self->{sourcename});
}

##########################################################################################
#									getLinkPath											 #
#				Hilfsfunktion um die orginal Datei zu finden							 #
##########################################################################################
sub getLinkPath{
    my ($self,$linkName,$linkPath)=@_;
    my $result=0;
    my $path="";
    if($^O eq "MSWin32")
    {
        require Win32::Shortcut or die("Can't import Win32::Shortcut: $!");
        my $link = Win32::Shortcut->new();
        $result=$link->Load("$linkPath\\$linkName");
        $self->{verbosity}->verbose("Get original file path from link:\nLink:\t$linkPath\\$linkName\nPath:\t$link->{'Path'}","OK");
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

sub DESTROY{
    my $self = shift;
    $self->{verbosity}=undef;
    $Flag = undef;
};
1;
__END__
