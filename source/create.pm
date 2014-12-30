#!/usr/bin/perl

#**************************************************************************************************+**
#                                       Create Archiv
#   Beschreibung:   Dieses Modul erstellt ein neues Archiv oder verschlankt ein bestehendes
#   Autor:          Ramunno, Michel Angelo
#   Erstellt:       12.2014
#*****************************************************************************************************

use warnings;
use strict;

package Create;

#*****************************************************************************************************
#                                         Konstruktor
# Beschreibung: Erzeugt ein neues Objekt der Create Klasse
# Parameter:    inFlag = Ansteuerung der Ausgabe von Programminformationen (optional)
#                true => Ausgabe der Informationen
#*****************************************************************************************************
sub new {
    my ($invocant,$inFlag) = @_;
    my $class   = ref($invocant) || $invocant;
    my $self = {
        source  => "",
        destination   => "",
        flag  => $inFlag,
    };
    bless ($self, $class);
    $self->verbose("New");
    return $self;
}

#*****************************************************************************************************
#                                           addSource
# Beschreibung: Fügt eine Quellverzeichnis hinzu
# Parameter:    Source = Pfad zum Quellverzeichnis
#*****************************************************************************************************
sub addSource{
    my ($self,$Source) = @_;
    $self->{source}=$Source;
    $self->verbose("New source added: $self->{source}");
}

#*****************************************************************************************************
#                                         addDestination
# Beschreibung: Fügt eine Zielverzeichnis hinzu
# Parameter:    Destination = Pfad zum Zielverzeichnis
#*****************************************************************************************************
sub addDestination{
    my ($self,$Destination) = @_;
    $self->{destination}=$Destination;
    $self->verbose("New destination added: $self->{destination}");
}

#*****************************************************************************************************
#                                         create_c
# Beschreibung: Erzeugt eine Kopie des Quellverzeichnis im Zielverzeichnis
# Parameter:    Keine
#*****************************************************************************************************
sub create_c {
    use File::Copy;
    my $self=shift;
    $self->verbose("Start create c:\n***************\n");
    opendir(my $dsh,$self->{source}) || die("Can't find directory $self->{source}: $!");
    my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime();
    $year+=1900;
    $mon+=1;
    my $now=sprintf("%02d_%02d_%02d_%02d_%02d_%02d",$year%100,$mon,$day,$hour,$min,$sec);
    mkdir($self->{destination}."/SOURCE_".$now);
    $self->verbose("Create Archive: $self->{destination}/SOURCE_$now\n");
    $self->copyDir("","SOURCE_$now");
    closedir($dsh);
};

#*****************************************************************************************************
#                                         create_s
# Beschreibung: Verschlankt das Archiv im Zielverzeichnis
# Parameter:    Keine
#*****************************************************************************************************
sub create_s {
    my $self=shift;
    my $previousArchiveAvailable=0;
    $self->verbose("Start create s:\n***************\n");
    opendir(my $dsh,$self->{destination}) || die("Can't find directory $self->{destination}: $!");
    my @folder=readdir $dsh;
    for(my $i=0;$i<scalar(@folder)-1;$i++)
    {
        if($folder[$i] ne "." and $folder[$i] ne ".." and $folder[$i] =~ /^SOURCE/)
        {
            $previousArchiveAvailable=1;
            $self->verbose("Compare Archives: $folder[$i] <=> $folder[$i+1]\n");
            $self->compareDir("$folder[$i]","$folder[$i+1]");
        }
    }
    if(!$previousArchiveAvailable)
    {
        $self->verbose("No previous archive available");
    }
    closedir($dsh);
};

#*****************************************************************************************************
#                                         create_cs
# Beschreibung: Erzeugt eine Kopie des Quellverzeichnis im Zielverzeichnis und verschlankt es
#               anschließend
# Parameter:    Keine
#*****************************************************************************************************
sub create_cs {
    my $self=shift;
    $self->verbose("Create cs started\n****************\n");
    $self->create_c();
    $self->create_s();
};

#*****************************************************************************************************
#                                         verbose
# Beschreibung: Erzeugt eine Ausgabe auf STDOUT, wenn das Flag gesetzt wurde
# Parameter:    message = Ist die auszugebende Nachricht
#*****************************************************************************************************
sub verbose {
    my ($self,$message)=@_;
    if($self->{flag})
    {
        print $message . "\n" ;
    }
};

#*****************************************************************************************************
#                                         copyDir
# Beschreibung: Kopiert alle Dateien in diesem und allen Unterverzeichnisen
# Parameter:    diectory = Aktuell Unterverzeichnis
#               destination = Ziel Unterverzeichnis
#*****************************************************************************************************
sub copyDir {
    my ($self,$directory,$destination)=@_;
    opendir(my $dsh,"$self->{source}/$directory") || die("Can't find directory $directory: $!");
    while(readdir $dsh) {
        
        if($_ ne ".." and $_ ne ".")
        {
            if (-f "$self->{source}/$directory/$_")
            {
                $self->verbose("Copy file:\tSource = $self->{source}$directory/$_\n\t\t\tDestination = $self->{destination}/$destination$directory/$_\n");
                copy("$self->{source}/$directory/$_","$self->{destination}/$destination/$directory/$_")or die "Can't copy file $_ : $!";
            }
            elsif (-d "$self->{source}/$directory/$_")
            {
                $self->verbose("Create directory:\t$self->{destination}/$destination$directory/$_\n");
                mkdir("$self->{destination}/$destination$directory/$_");
                $self->verbose("Change directory:\t$self->{source}$directory/$_\n");
                $self->copyDir("$directory/$_","$destination");
            }
        }
    }
    $self->verbose("Leave directory:\t$self->{source}$directory\n");
    closedir($dsh);
};

#*****************************************************************************************************
#                                        compareDir
# Beschreibung: Vergleicht die Archive zur Verschlankung, ist eine Datei unverändert wird diese durch
#               eine Verlinkung auf das neuer Archive ersetzt
# Parameter:    olderDir = Älter Archive
#               newerDir = Neuer Archive
#*****************************************************************************************************
sub compareDir {
    my ($self,$olderDir,$newerDir)=@_;
    opendir(my $doh,"$self->{destination}/$olderDir") || die("Can't find directory $olderDir: $!");
    while(my $oldFile=readdir $doh ) {
        
        if($oldFile ne ".." and $oldFile ne ".")
        {
            
            if (-f "$self->{destination}/$olderDir/$oldFile" )
            {
                $self->verbose("Compare File:\n$self->{destination}/$olderDir/$oldFile\n$self->{destination}/$newerDir/$oldFile");
                my $result=$self->compareFile("$self->{destination}/$olderDir/$oldFile","$self->{destination}/$newerDir/$oldFile");
                if($result eq "true")
                {
                    $self->verbose("Delete file:\n$self->{destination}/$olderDir/$oldFile\n");
                    unlink("$self->{destination}/$olderDir/$oldFile");
                    $self->verbose("Link file:\n$self->{destination}/$olderDir/$oldFile\n=> $self->{destination}/$newerDir/$oldFile\n");
                    if($^O eq "MSWin32")
                    {
                        require Win32::Shortcut->import or die("Can't import Win32::Shortcut: $!");
                        my $link = Win32::Shortcut->new();
                        $link->{'Path'}="$self->{destination}/$newerDir/$oldFile";
                        $link->Save("$self->{destination}/$olderDir/$oldFile.Ink");
                        $link->close();
                    }
                    else
                    {
                        symlink("$self->{destination}/$newerDir/$oldFile","$self->{destination}/$olderDir/$oldFile");
                    }
                }
            }
            elsif (-d "$self->{destination}/$olderDir/$oldFile")
            {
                $self->verbose("Compare Diretory:\n$self->{destination}/$olderDir/$oldFile\n$self->{destination}/$newerDir/$oldFile\n");
                $self->compareDir("$olderDir/$oldFile","$newerDir/$oldFile");
            }
            
        }
    }
    closedir($doh);
};

#*****************************************************************************************************
#                                        compareFile
# Beschreibung: Vergleicht zwei Dateien aus unterschiedlichen Archiven auf Gleichheit
# Parameter:    olderFile = Älter Datei
#               newerFile = Neuer Datei
#*****************************************************************************************************
sub compareFile {
    my ($self,$olderFile,$newerFile)=@_;
    use Digest;                                     # Importieren des Core Module Digest
    my $md5=Digest->MD5;
    open(my $foh, "<", "$olderFile")
    or die "cannot open < $olderFile: $!";          # Öffnen der Datei zum Lesen
    open(my $fnh, "<", "$newerFile")
    or return "false";                              # Öffnen der Datei zum Lesen
    $md5->addfile($foh);                            # Hinzufügen der Datei
    my $digestOldFile=$md5->hexdigest;
    $md5->reset;
    $md5->addfile($fnh);                            # Hinzufügen der Datei
    my $digestNewFile=$md5->hexdigest;
    close($foh);
    close($fnh);
    if($digestOldFile eq $digestNewFile)
    {
        $self->verbose("=> Files are equal!\n");
        return "true";
    }
    else
    {
        if(-l $olderFile)
        {
            $self->verbose("=> Files are equal links!\n");
            return "true";
            
        }
        $self->verbose("=> Files are diffrent!\n");
        return "false";
    }
};

#*****************************************************************************************************
#                                        Destruktor
# Beschreibung: Zerstört das Objekt
# Parameter:    Keine
#*****************************************************************************************************
sub DESTROY {
    my $self = shift;
    $self->verbose("Destroy");
};

1;
__END__
