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
#                1 => Ausgabe der Informationen
#*****************************************************************************************************
sub new {
    my ($invocant,$inFlag) = @_;
    my $class   = ref($invocant) || $invocant;
    my $self = {
        source  => "",
        destination   => "",
        flag  => $inFlag || 0,
        archiveName => "",
    };
    bless ($self, $class);
    $self->verbose("New","OK");
    return $self;
}

#*****************************************************************************************************
#                                           addSource
# Beschreibung: Fügt ein Quellverzeichnis hinzu
# Parameter:    Source = Pfad zum Quellverzeichnis
#*****************************************************************************************************
sub addSource{
    my ($self,$source) = @_;
    # Hinzufügen des Quellverzeichnisses
    $self->{source}=$source;
    $self->verbose("New source added: $self->{source}","OK");
}

#*****************************************************************************************************
#                                         addDestination
# Beschreibung: Fügt ein Zielverzeichnis hinzu
# Parameter:    destination = Pfad zum Zielverzeichnis
#*****************************************************************************************************
sub addDestination{
    my ($self,$destination) = @_;
    # Hinzufügen des Zielverzeichnisses
    $self->{destination}=$destination;
    $self->verbose("New destination added: $self->{destination}","OK");
}

#*****************************************************************************************************
#                                         addArchiveName
# Beschreibung: Fügt den Archivname hinzu, der für die Verschlankung benötigt wird
# Parameter:    archiveName = Pfad zum Zielverzeichnis
#*****************************************************************************************************
sub addArchiveName{
    my ($self,$archiveName) = @_;
    # Hinzufügen des Archivverzeichnisses
    $self->{archiveName}=$archiveName;
    $self->verbose("New archive name added: $self->{archiveName}","OK");
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
    # Überprüfen ob Quellverzeichnis vorhanden ist
    opendir(my $dsh,$self->{source}) || die("Can't find directory $self->{source}: $!");
    closedir($dsh);
    # Erzeugen des Verzeichnisnamens
    my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime();
    $year+=1900;
    $mon+=1;
    my $now=sprintf("%04d_%02d_%02d_%02d_%02d_%02d",$year,$mon,$day,$hour,$min,$sec);
    $_=$self->{source};
    # Überprüfen um welches Betriebssystem es sich handelt
    if($^O eq "MSWin32")
    {
        s/://;
        s/\\/_/g;
    }
    else
    {
        s/^\///;
        s/\//_/g;
    }
    my $sourceName=$_;
    $self->addArchiveName($sourceName);
    # Erstellen des Zielverzeichnisses
    mkdir($self->{destination}."/".$self->{archiveName}."_".$now);
    $self->verbose("Create Archive: $self->{destination}/$self->{archiveName}_$now\n","OK");
    # Kopieren der Daten
    $self->copyDir("",$self->{archiveName}."_".$now);
}

#*****************************************************************************************************
#                                         create_s
# Beschreibung: Verschlankt das Archiv im Zielverzeichnis
# Parameter:    Keine
#*****************************************************************************************************
sub create_s {
    my ($self)=shift;
    my $previousArchiveAvailable=0;
    $self->verbose("Start create s:\n***************\n");
    # Öffnen des Archivverzeichnisses
    opendir(my $dsh,$self->{destination}) || die("Can't find directory $self->{destination}: $!");
    # Alle Verzeichnisse des Archivverzeichnisses einlesen
    my @folder=readdir $dsh;
    my @seperateFolder=grep(/^$self->{archiveName}/,@folder);
    @folder=sort(@seperateFolder);
    # Schließen des Archivverzeichnisses
    closedir($dsh);
    # Durchlaufen aller Archivverzeichnisse und Suche nach unveränderten Dateien
    
    for(my $i=scalar(@folder)-1;$i>0;$i--)
    {
        # Falls vorhergehendes Archiv vorhanden
        $previousArchiveAvailable=1;
        $self->verbose("Compare Archives: $folder[$i-1] <=> $folder[$i]\n","OK");
        # Vergleich von einem Archiv mit dem vorhergehenden
        $self->compareDir("$folder[$i-1]","$folder[$i]");

    }
    # Falls kein vorhergehendes Archiv vorhanden ist
    if(!$previousArchiveAvailable)
    {
        $self->verbose("No previous archive available","WARNING");
    }
}

#*****************************************************************************************************
#                                         create_cs
# Beschreibung: Erzeugt eine Kopie des Quellverzeichnis im Zielverzeichnis und verschlankt es
#               anschließend
# Parameter:    Keine
#*****************************************************************************************************
sub create_cs {
    my $self=shift;
    $self->verbose("Create cs started\n****************\n");
    # Erstellen des neuen Archivs
    $self->create_c();
    # Verschlanken der Archive
    $self->create_s($self->{archiveName});
}

#*****************************************************************************************************
#                                         verbose
# Beschreibung: Erzeugt eine Ausgabe auf STDOUT, wenn das Flag gesetzt wurde
# Parameter:    message = Ist die auszugebende Nachricht
#               state = Gibt den Status der Nachtricht an {OK, WARNING, ERROR}
#*****************************************************************************************************
sub verbose {
    my ($self,$message,$state)=@_;
    if($self->{flag}==1)
    {
        # Ausgabe der Nachricht
        use Verbosity;
        my $v = Verbosity->new(1);
        $v->verbose($message,$state);
    }
}

#*****************************************************************************************************
#                                         copyDir
# Beschreibung: Kopiert alle Dateien in diesem und allen Unterverzeichnissen
# Parameter:    directory = Aktuelles Unterverzeichnis
#               destination = Ziel Unterverzeichnis
#*****************************************************************************************************
sub copyDir {
    my ($self,$directory,$destination)=@_;
    # Öffnen des Quellverzeichnisses bzw. dessen Unterverzeichnisses
    opendir(my $dsh,"$self->{source}/$directory") || die("Can't find directory $directory: $!");
    # Kopieren aller Dateien bzw. Erzeugen eines Unterverzeichnisses
    while(readdir $dsh) {
        if($_ ne ".." and $_ ne ".")
        {
            # Überprüfen ob es sich um eine Datei handelt
            if (-f "$self->{source}/$directory/$_")
            {
                $self->verbose("Copy file:\tSource = $self->{source}$directory/$_\n\t\t\tDestination = $self->{destination}/$destination$directory/$_\n","OK");
                # Kopieren der Datei
                copy("$self->{source}/$directory/$_","$self->{destination}/$destination/$directory/$_")or die "Can't copy file $_ : $!";
            }
            # Überprüfen ob es sich um ein Verzeichnis handelt
            elsif (-d "$self->{source}/$directory/$_")
            {
                $self->verbose("Create directory:\t$self->{destination}/$destination$directory/$_\n","OK");
                # Erzeugen des Unterverzeichnisses
                mkdir("$self->{destination}/$destination$directory/$_");
                $self->verbose("Change directory:\t$self->{source}$directory/$_\n","OK");
                # Rekursiver Aufruf der Methode zum Kopieren des Unterverzeichnisses
                $self->copyDir("$directory/$_","$destination");
            }
        }
    }
    $self->verbose("Leave directory:\t$self->{source}$directory\n","OK");
    # Schließen des Quellverzeichnisses bzw. dessen Unterverzeichnisses
    closedir($dsh);
}

#*****************************************************************************************************
#                                        compareDir
# Beschreibung: Vergleicht die Archive zur Verschlankung, ist eine Datei unverändert wird diese durch
#               eine Verlinkung auf das neue Archiv ersetzt
# Parameter:    olderDir = altes Archivverzeichnis
#               newerDir = neues Archivverzeichnis
#*****************************************************************************************************
sub compareDir {
    my ($self,$olderDir,$newerDir)=@_;
    # Öffnen des Archivverzeichnisses bzw. dessen Unterverzeichnisse
    opendir(my $doh,"$self->{destination}/$olderDir") || die("Can't find directory $olderDir: $!");
    # Verglichen aller Dateien, inklusive Unterverzeichnisse
    while(my $oldFile=readdir $doh ) {
        if($oldFile ne ".." and $oldFile ne ".")
        {
            # Überprüfen ob es sich um eine Datei handelt
            if (-f "$self->{destination}/$olderDir/$oldFile" )
            {
                $self->verbose("Compare File:\n$self->{destination}/$olderDir/$oldFile\n$self->{destination}/$newerDir/$oldFile","OK");
                # Überprüfung der Dateien auf Gleichheit
                my $result=$self->compareFile("$self->{destination}/$olderDir/$oldFile","$self->{destination}/$newerDir/$oldFile");
                if($result eq "true")
                {
                    # Falls beide Dateien gleich sind
                    $self->verbose("Delete file:\n$self->{destination}/$olderDir/$oldFile\n","OK");
                    # Löschen der alten Datei
                    unlink("$self->{destination}/$olderDir/$oldFile");
                    $self->verbose("Link file:\n$self->{destination}/$olderDir/$oldFile\n=> $self->{destination}/$newerDir/$oldFile\n","OK");
                    # Überprüfen um welches Betriebssystem es sich handelt
                    if($^O eq "MSWin32")
                    {
                        # Falls Windows, erzeugen eines shortcuts
                        require Win32::Shortcut or die("Can't import Win32::Shortcut: $!");
                        my $link = Win32::Shortcut->new();
                        $link->{'Path'}="$self->{destination}/$newerDir/$oldFile";
                        my ($fileName)=split('\.',$oldFile);
                        $fileName=$fileName.".lnk";
                        $link->{'File'}="$self->{destination}/$olderDir/$fileName";
                        $link->Save();
                        $link->Close();
                    }
                    else
                    {
                        # Falls Unix basiertes Betriebssystem, erzeugen eines softlinks
                        symlink("$self->{destination}/$newerDir/$oldFile","$self->{destination}/$olderDir/$oldFile");
                    }
                }
            }
            # Überprüfen ob es sich um ein Verzeichnis handelt
            elsif (-d "$self->{destination}/$olderDir/$oldFile")
            {
                $self->verbose("Compare Diretory:\n$self->{destination}/$olderDir/$oldFile\n$self->{destination}/$newerDir/$oldFile\n","OK");
                # Rekursiver Aufruf der Methode zur Untesuchung des Unterverzeichnisses
                $self->compareDir("$olderDir/$oldFile","$newerDir/$oldFile");
            }
            
        }
    }
    # Schließen des Archivverzeichnisses bzw. dessen Unterverzeichnisses
    closedir($doh);
}

#*****************************************************************************************************
#                                        compareFile
# Beschreibung: Vergleicht zwei Dateien aus unterschiedlichen Archiven auf Gleichheit
# Parameter:    olderFile = ältere Datei
#               newerFile = neuere Datei
#*****************************************************************************************************
sub compareFile {
    my ($self,$olderFile,$newerFile)=@_;
    # Importieren des Core Module Digest
    use Digest;
    # Erzeugen eines MD5 Objekts
    my $md5=Digest->MD5;
    # Öffnen der älteren Datei zum Lesen
    open(my $foh, "<", "$olderFile")
    or return "false";
    # Öffnen der neueren Datei zum Lesen
    open(my $fnh, "<", "$newerFile")
    or return "false";
    # Hinzufügen der älteren Datei
    $md5->addfile($foh);
    # Erzeugen des Hashwerts für die ältere Datei
    my $digestOldFile=$md5->hexdigest;
    $md5->reset;
    # Hinzufügen der neueren Datei
    $md5->addfile($fnh);
    # Erzeugen des Hashwerts für die neuere Datei
    my $digestNewFile=$md5->hexdigest;
    # Schießen der Dateien
    close($foh);
    close($fnh);
    # Vergleichen der beiden Hashwerte
    if($digestOldFile eq $digestNewFile)
    {
        # Falls beide Dateien gleich sind => unverändert
        $self->verbose("=> Files are equal!\n","OK");
        return "true";
    }
    else
    {
        if(-l $olderFile or $olderFile=~/.lnk$/)
        {
            # Falls ältere Datei bereits ein link ist => unverändert
            $self->verbose("=> Old file is already link!\n","OK");
            return "true";
            
        }
        # Falls beide Dateien nicht gleich sind => verändert
        $self->verbose("=> Files are diffrent!\n","OK");
        return "false";
    }
}

sub setVerboseLevel {
	my ($self, $level) = @_;
	$self->{flag} = $level;
}

#*****************************************************************************************************
#                                        Destruktor
# Beschreibung: Zerstört das Objekt
# Parameter:    Keine
#*****************************************************************************************************
sub DESTROY {
    my $self = shift;
    $self->verbose("Destroy","OK");
}

1;
__END__
