#!/usr/bin/perl

#**************************************************************************************************+**
#                                       Create Archiv
#   Beschreibung:   Dieses Modul erstellt ein neues Archiv oder verschlankt ein bestehendes
#   Autor:          Ramunno, Michel Angelo
#   Erstellt:       08.01.2015
#*****************************************************************************************************

use warnings;
use strict;
use Verbosity;

package Create;

#*****************************************************************************************************
#                                         verbose
# Beschreibung: Erzeugt eine Ausgabe auf STDOUT, wenn das Flag gesetzt wurde
# Parameter:    $message = Ist die auszugebende Nachricht
#               $state = Gibt den Status der Nachtricht an {OK, WARNING, ERROR}
#*****************************************************************************************************
my $verbose = sub {
    my ($self,$message,$state)=@_;
    if($self->{flag} >= 1)
    {
        # Ausgabe der Nachricht
        if($^O eq "MSWin32")
        {
            $_=$message;
            s/\//\\/g;
            $message=$_;
        }
        $self->{verbosity}->verbose($message,$state);
    }
};

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
        verbosity => Verbosity->new($inFlag || 0),
    };
    bless ($self, $class);
    $verbose->($self,"New","OK");
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
    $verbose->($self,"New source added: $self->{source}","OK");
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
    $verbose->($self,"New destination added: $self->{destination}","OK");
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
    $verbose->($self,"New archive name added: $self->{archiveName}","OK");
}


#*****************************************************************************************************
#                                         setVerboseLevel
# Beschreibung: Setzt den Level der Verbose Ausgabe
# Parameter:    $level 0 = Keine Ausgabe
#                      1 = Normale Ausgabe
#                      2 ...8 = reserviert
#                      9 = Debug Ausgabe
#*****************************************************************************************************
sub setVerboseLevel {
    my ($self, $level) = @_;
    $self->{flag} = $level;
    $self->{verbosity}->setVerboseLevel($level);
}

#*****************************************************************************************************
#                                         create_c
# Beschreibung: Erzeugt eine Kopie des Quellverzeichnis im Zielverzeichnis
# Parameter:    Keine
#*****************************************************************************************************
sub create_c {
    use File::Copy;
    my $self=shift;
    $verbose->($self,"Start create c:\n***************\n");
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
    $verbose->($self,"Create Archive: $self->{destination}/$self->{archiveName}_$now\n","OK");
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
    $verbose->($self,"Start create s:\n***************\n");
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
        $verbose->($self,"Compare Archives:\nOlder:\t$folder[$i-1]\nNewer:\t$folder[$i]\n");
        # Vergleich von einem Archiv mit dem vorhergehenden
        $self->compareDir("$folder[$i-1]","$folder[$i]");

    }
    # Falls kein vorhergehendes Archiv vorhanden ist
    if(!$previousArchiveAvailable)
    {
        $verbose->($self,"No previous archive available","WARNING");
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
    $verbose->($self,"Create cs started\n****************\n");
    # Erstellen des neuen Archivs
    $self->create_c();
    # Verschlanken der Archive
    $self->create_s($self->{archiveName});
}

#*****************************************************************************************************
#                                        copyFile
# Beschreibung: Kopiert eine Datei Datei
# Parameter:    $self = Instanz von Create
#               $fileName = Name der Datei die gelöscht werden soll
#               $fileSource = Verzeichnis in dem sich die Datei befindet
#               $fileDestination = Verzeichnis in das die Datei kopiert wereden soll
#*****************************************************************************************************
my $copyFile = sub{
    my ($self,$fileName,$fileSource,$fileDestination)=@_;
    # Ausgabe auf der Konsole
    if($^O eq "MSWin32")
    {
        $verbose->($self,"Copy file:\nSource:\t\t$fileSource\\$fileName\nDestination:\t$fileDestination\\$fileName");
    }
    else
    {
        $verbose->($self,"Copy file:\nSource:\t\t\t$fileSource/$fileName\nDestination:\t$fileDestination/$fileName");
    }
    # Kopieren der Datei
    if(copy("$fileSource/$fileName","$fileDestination/$fileName"))
    {
        # Datei wurde kopiert
        $verbose->($self,"Copied!\n","OK");
    }
    else
    {
        # Datei konnte nicht kopiert werden
        $verbose->($self,"Can't copy file $fileName!\n","ERROR");
    }
};

#*****************************************************************************************************
#                                        createDir
# Beschreibung: Erzeugt einen neuen Verzeichnisses
# Parameter:    $self = Instanz von Create
#               $dirName = Name des Verzeichnisses
#               $dirPath = Path des Verzeichnisses
#*****************************************************************************************************
my $createDir = sub{
    my ($self,$dirName,$dirPath)=@_;
    # Ausgabe auf der Konsole
    if($^O eq "MSWin32")
    {
        $verbose->($self,"Create Directroy:\nDestination:\t$dirPath\\$dirName");
    }
    else
    {
        $verbose->($self,"Create Directroy:\nDestination:\t$dirPath/$dirName");
    }
    # Verzeichnis erstellen
    if(mkdir("$dirPath/$dirName"))
    {
        # Verzeichnis wurde ertellt
        $verbose->($self,"Created!\n","OK");
    }
    else
    {
        # Verzeichnis konnte nicht erstellt werden
        $verbose->($self,"Can't create directory $dirName!\n","ERROR");
    }
};

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
    $verbose->($self,"Open directory: $self->{source}$directory\n","OK");
    # Kopieren aller Dateien bzw. Erzeugen eines Unterverzeichnisses
    while(my $file=readdir $dsh) {
        if($file ne ".." and $file ne ".")
        {
            # Überprüfen ob es sich um eine Datei handelt
            if (-f "$self->{source}/$directory/$file")
            {
                # Kopieren der Datei
                $copyFile->($self,"$file","$self->{source}$directory","$self->{destination}/$destination$directory");
            }
            # Überprüfen ob es sich um ein Verzeichnis handelt
            elsif (-d "$self->{source}/$directory/$file")
            {
                # Erzeugen des Unterverzeichnisses
                $createDir->($self,"$file","$self->{destination}/$destination$directory");
                # Rekursiver Aufruf der Methode zum Kopieren des Unterverzeichnisses
                $self->copyDir("$directory/$file","$destination");
            }
        }
    }
    # Schließen des Quellverzeichnisses bzw. dessen Unterverzeichnisses
    closedir($dsh);
    $verbose->($self,"Leave directory: $self->{source}$directory\n","OK");
}

#*****************************************************************************************************
#                                        deleteFile
# Beschreibung: Erzeugt einen neuen symbolischen Link auf eine Datei
# Parameter:    $self = Instanz von Create
#               $fileName = Name der Datei die gelöscht werden soll
#               $filePath = Verzeichnis in dem sich die Datei befindet
#*****************************************************************************************************
my $deleteFile = sub{
    my ($self,$fileName,$filePath)=@_;
    # Ausgabe auf der Konsole
    if($^O eq "MSWin32")
    {
        $verbose->($self,"Delete file:\n$filePath\\$fileName");
    }
    else
    {
        $verbose->($self,"Delete file:\n$filePath/$fileName");
    }
    # Löschen der alten Datei
    if(unlink("$filePath/$fileName")>0)
    {
        # Datei wurde gelöscht
        $verbose->($self,"Deleted!\n","OK");
    }
    else
    {
        # Datei konnte nicht gelöscht werden
        $verbose->($self,"Can't delete file $fileName!\n","ERROR");
    }
};

#*****************************************************************************************************
#                                        createLink
# Beschreibung: Erzeugt einen neuen symbolischen Link auf eine Datei
# Parameter:    $self = Instanz von Create
#               $fileName = Name der Datei die verlinkt werden soll
#               $linkSource = Verzeichnis in dem sich die originale Datei befindet
#               $linkDestination = Verzeichnis in dem der Link erstellt werden soll
#*****************************************************************************************************
my $createLink = sub{
    my ($self,$fileName,$linkSource,$linkDestination)=@_;
    # Überprüfen um welches Betriebssystem es sich handelt
    my $result="false";
    if($^O eq "MSWin32")
    {
        # Falls Windows, erzeugen eines shortcuts
        $verbose->($self,"Link files:\nOriginal:\t$linkDestination\\$fileName\nLink:\t\t$linkSource\\$fileName");
        require Win32::Shortcut or die("Can't import Win32::Shortcut: $!");
        my $link = Win32::Shortcut->new();
        $link->{'Path'}="$linkSource\\$fileName";
        $link->{'File'}="$linkDestination\\$fileName.lnk";
        $result=$link->Save();
    }
    else
    {
        # Falls Unix basiertes Betriebssystem, erzeugen eines softlinks
        $verbose->($self,"Link files:\nOriginal:\t$linkDestination/$fileName\nLink:\t$linkSource/$fileName");
        $result=symlink("$linkSource/$fileName","$linkDestination/$fileName");
    }
    if($result)
    {
        # Datei wurde verlinkt
        $verbose->($self,"Linked!\n","OK");
    }
    else
    {
        # Datei konnte nicht verlinkt werden
        $verbose->($self,"Can't create link!\n","ERROR");
    }
};

#*****************************************************************************************************
#                                        updateLink
# Beschreibung: Erzeugt einen neuen symbolischen Link auf eine Datei
# Parameter:    $self = Instanz von Create
#               $linkName = Name der Linkdatei
#               $linkSource = Verzeichnis in dem sich die originale Datei befindet
#               $linkPath = Verzeichnis in dem sich der Link befindet
#*****************************************************************************************************
my $updateLink = sub{
    my ($self,$linkName,$linkSource,$linkPath)=@_;
    my $result="false";
    if($^O eq "MSWin32")
    {
        require Win32::Shortcut or die("Can't import Win32::Shortcut: $!");
        my $link = Win32::Shortcut->new();
        $link->Load("$linkPath\\$linkName");
        $verbose->($self,"Update link:\nOld Path:\t$link->{'Path'}\nNew Path:\t$linkSource");
        $link->{'Path'}="$linkSource";
        $result=$link->Save();
        $link->Close();
        if($result)
        {
            # Verlinkung wurde aktualisiert
            $verbose->($self,"Link updated!\n","OK");
        }
        else
        {
            # Verlinkung konnte nicht aktualisiert
            $verbose->($self,"Can't update link!\n","ERROR");
        }
    }
};

#*****************************************************************************************************
#                                        getLinkPath
# Beschreibung: Überpruft ob link gültig ist
# Parameter:    $self = Instanz von Create
#               $linkName = Name der Linkdatei
#               $linkPath = Verzeichnis in dem sich der Link befindet
#*****************************************************************************************************
my $getLinkPath = sub{
    my ($self,$linkName,$linkPath)=@_;
    my $result=0;
    my $path="";
    if($^O eq "MSWin32")
    {
        require Win32::Shortcut or die("Can't import Win32::Shortcut: $!");
        my $link = Win32::Shortcut->new();
        $result=$link->Load("$linkPath\\$linkName");
        $verbose->($self,"Get original file path from link:\nLink:\t$linkPath\\$linkName\nPath:\t$link->{'Path'}");
        $path=$link->{'Path'};
        $link->Close();
        if($result)
        {
            # Verlinkung wurde aktualisiert
            $verbose->($self,"Link found!\n","OK");
        }
        else
        {
            # Verlinkung konnte nicht aktualisiert
            $verbose->($self,"Can't find link!\n","ERROR");
        }
    }
    return $path;
};

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
    opendir(my $doh,"$self->{destination}/$newerDir") || die("Can't find directory $newerDir: $!");
    # Verglichen aller Dateien, inklusive Unterverzeichnisse
    while(my $newFile=readdir $doh) {
        if($newFile ne ".." and $newFile ne ".")
        {
            # Überprüfen ob es sich um eine Datei handelt
            if (!-d "$self->{destination}/$newerDir/$newFile")
            {
                # Entfernen von lnk-Endung
                $_=$newFile;
                s/.lnk//;
                my $newFileNoLink=$_;
                # Überprüfung der Dateien auf Gleichheit
                if($^O eq "MSWin32")
                {
                    # Überprüfung ob neue Datei ein Link ist
                    if($newFile=~/.lnk$/i)
                    {
                        # Überprüfung ob alte Datei als Link vorhanden ist
                        if(-e "$self->{destination}\\$olderDir\\$newFile")
                        {
                            # Hole Pfad der aktuellen Datei
                            my $path=$getLinkPath->($self,"$newFile","$self->{destination}\\$newerDir");
                            # Aktualisiere alten Link
                            $updateLink->($self,$newFile,$path,"$self->{destination}\\$olderDir");
                        }
                        # Überpüfung ob alte Datei als normale Datei vorhanden ist
                        elsif(-e "$self->{destination}\\$olderDir\\$newFileNoLink")
                        {
                            # Hole Pfad der aktuellen Datei
                            my $path=$getLinkPath->($self,"$newFile","$self->{destination}\\$newerDir");
                            # Überprüfe ob beide Dateien gleich sind
                            my $result=$self->compareFile("$self->{destination}\\$olderDir\\$newFileNoLink",$path);
                            if($result eq "true")
                            {
                                # Falls beide Dateien gleich sind
                                # Löschen der alten Datei
                                $deleteFile->($self,$newFileNoLink,"$self->{destination}/$olderDir");
                                # Entfernen des Dateinames
                                $_=$path;
                                s/\\$newFileNoLink//;
                                $path=$_;
                                # Erstellen eines Links zur neueren Datei
                                $createLink->($self,$newFileNoLink,$path,"$self->{destination}/$olderDir");
                            }
                        }
                    }
                    else # Neue Datei ist kein Link
                    {
                        # Überprüfe ob beide Dateien gleich sind
                        # Überpüfung ob alte Datei ein normale Datei ist
                        if(-e "$self->{destination}\\$olderDir\\$newFileNoLink")
                        {
                            my $result=$self->compareFile("$self->{destination}\\$olderDir\\$newFileNoLink","$self->{destination}\\$newerDir\\$newFile");
                            if($result eq "true")
                            {
                                # Falls beide Dateien gleich sind
                                # Löschen der alten Datei
                                $deleteFile->($self,$newFile,"$self->{destination}\\$olderDir");
                                # Erstellen eines Links zur neueren Datei
                                $createLink->($self,$newFile,"$self->{destination}\\$newerDir","$self->{destination}\\$olderDir");
                            }
                        }
                        # Überpüfung ob alte Datei ein link ist
                        elsif("$self->{destination}\\$olderDir\\$newFile"=~/.lnk$/i)
                        {
                            # Hole Pfad der aktuellen Datei
                            my $path=$getLinkPath->($self,"$newFile","$self->{destination}\\$olderDir");
                            # Überpüfung ob beide Dateien gleich sind
                            my $result=$self->compareFile($path,"$self->{destination}\\$newerDir\\$newFileNoLink",);
                            if($result eq "true")
                            {
                                # Falls beide Dateien gleich sind
                                # Entfernen des Dateinames
                                $_=$path;
                                s/\\$newFileNoLink//;
                                $path=$_;
                                # Aktualisiere alten Link
                                $updateLink->($self,$newFile,$path,"$self->{destination}\\$olderDir");
                            }
                        }
                    }
                }
                else
                {
                    # Falls Unix basiertes System
                    # Überpüfung ob beide Dateien gleich sind
                    my $result=$self->compareFile("$self->{destination}/$olderDir/$newFileNoLink","$self->{destination}/$newerDir/$newFile");
                    if($result eq "true")
                    {
                        # Falls beide Dateien gleich sind
                        # Löschen der alten Datei
                        $deleteFile->($self,$newFile,"$self->{destination}/$olderDir");
                        # Erstellen eines Links zur neueren Datei
                        $createLink->($self,$newFile,"$self->{destination}/$newerDir","$self->{destination}/$olderDir");
                    }
                }
            }
            # Überpüfung ob es sich um ein Verzeichnis handelt
            elsif (-d "$self->{destination}/$olderDir/$newFile")
            {
                $verbose->($self,"Compare Diretory:\nOlder Directory:\t$self->{destination}/$olderDir/$newFile\nNewer Directory:\t$self->{destination}/$newerDir/$newFile\n");
                # Rekursiver Aufruf der Methode zur Untesuchung des Unterverzeichnisses
                $self->compareDir("$olderDir/$newFile","$newerDir/$newFile");
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
# Return:       "true"  -> Files are equal
#               "false" -> Files are diffrent
#*****************************************************************************************************
sub compareFile {
    my ($self,$olderFile,$newerFile)=@_;
    # Ausgabe auf Konsole
    $verbose->($self,"Compare Files:\nOlder file:\t$olderFile\nNewer file:\t$newerFile");
    # Importieren des Core Module Digest
    use Digest;
    # Erzeugen eines MD5 Objekts
    my $md5=Digest->MD5;
    # Öffnen der älteren Datei zum Lesen
    open(my $foh, "<", "$olderFile") or return "false";
    # Öffnen der neueren Datei zum Lesen
    open(my $fnh, "<", "$newerFile") or return "false";
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
        $verbose->($self,"Files are equal!\n","OK");
        return "true";
    }
    else
    {
        if(-l $olderFile or $olderFile=~/.lnk$/)
        {
            # Falls ältere Datei bereits ein link ist => unverändert
            $verbose->($self,"Old file is already link!\n","OK");
            return "true";
            
        }
        # Falls beide Dateien nicht gleich sind => verändert
        $verbose->($self,"Files are diffrent!\n","OK");
        return "false";
    }
}

#*****************************************************************************************************
#                                        Destruktor
# Beschreibung: Zerstört das Objekt
# Parameter:    Keine
#*****************************************************************************************************
sub DESTROY {
    my $self = shift;
    $self->{verbosity}=undef;
}

1;
__END__
