package del;
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib qw(dirname(dirname abs_path $0) . "/PerlArchiver/source");
#use lib qw(dirname(dirname abs_path $0) . "/Archiver");
use Win32::Shortcut;
use File::Find;
use File::Copy;
use File::Path;
use Verbosity;

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {
		 deleteFile     => "",                  #Zu loeschendes Objekt inkl Pfad
		 mainArchivpath => "",                  #Nur Pfad
		 archivFullName => "",                  #Archivname ohne Pfad mit Datum
		 archivName     => "",                  #Archivname ohne Datum
		 verbosity      => Verbosity->new(0),
	};
	bless $self, $class;
	return $self;
}

sub addDestination {
	my ( $self, $destination ) = @_;
	
	if ( !-e $destination ) {
		print "No such file or directory!";
		exit;
	}

		#Verzeichnispfad splitten
	my @DeleteDirectory;
	if($destination =~ m/\\/){
		@DeleteDirectory = split( /\\/, $destination );
	}
		
	elsif($destination =~ m/\//){
		@DeleteDirectory = split( /\//, $destination );
	}
	
	my $main;
	foreach (@DeleteDirectory) {
		if ( $_ =~ m/\d{4}\_\d{2}\_\d{2}\_\d{2}\_\d{2}\_\d{2}/i ) { last; }
		$main .= "$_/";
	}

	#Archivname mit Datum ohne Pfad finden
	my @dateVar =
	  grep( /\_\d{4}\_\d{2}\_\d{2}\_\d{2}\_\d{2}\_\d{2}$/, @DeleteDirectory );
	my $archivFullName = $dateVar[0];

	#Archivname ohne Datum
	my @tmp =
	  split( /\_\d{4}\_\d{2}\_\d{2}\_\d{2}\_\d{2}\_\d{2}/, $archivFullName );
	my $archivName = $tmp[0];
	
	$self->{deleteFile}     = $destination;
	$self->{mainArchivpath} = $main;             #Nur Pfad
	$self->{archivFullName} = $archivFullName;   #Archivname ohne Pfad mit Datum
	$self->{archivName}     = $archivName;		 #Archivname ohne Pfad ohne Datum
	
	$self->{verbosity}->verbose("Added new path to delete: $self->{deleteFile}");
}

sub setVerboseLevel {
	my ( $self, $level ) = @_;
	$self->{verbosity}->setVerboseLevel($level);
}

#--------------------------Loeschvorgang-------------------------------------------------------
sub delete_d {
	my $inself = shift;
	my @foundDir;
	my @allFoundLink;
	my %vipFoundLink;
	$inself->{verbosity}->verbose( "Start Delete d.\n", "OK" );

	#Nachfrage loeschen
	$inself->{verbosity}->verbose( "Start Delete-Check.\n", "OK" );
	$inself->check();
	$inself->{verbosity}
	  ->verbose( "Searching for the previous folder.\n", "OK" );

	#PreArchiv finden
	@foundDir = $inself->findPreDir();

	#Es muss nur verlinkt werden wenn es PreArchiv gibt
	if (@foundDir) {
		my $newCheckdir = "$foundDir[0]";
		my @tmp         = split( /\_\d{4}\_\d{2}\_\d{2}\_\d{2}\_\d{2}\_\d{2}/,
						 $inself->{'deleteFile'} );

		#Erstelle Pfad mit PreDir zu DelFile
		if ( $#tmp > 0 ) {
			$newCheckdir = "$foundDir[0]$tmp[1]";
		}
		$inself->{verbosity}
		  ->verbose( "Searching for linked files in previous folder.\n", "OK" );

		#Übergebe PreDir, suche nach Links
		@allFoundLink = $inself->findLinksPreDir($newCheckdir);

   # übergibt alle gefundenen Links, erhält Link mit Verknüpfung auf DelFiles
		if (@allFoundLink) {
			%vipFoundLink = $inself->checkLink(@allFoundLink);
		}

#gefundene Dateien müssen in PreDir kopiert werden und in allen Archiven neu verknüpft
		if ( keys %vipFoundLink ) {
			$inself->{verbosity}->verbose(
"Found linked files in previous folder with links to current directory.\n",
				"OK"
			);

			#gefundene Dateien in PreArchiv umkopieren
			foreach my $lnk ( sort keys %vipFoundLink ) {
				my @LinkPath = split( /\./, $lnk );
				my @DatEnd  = split( /\./, $vipFoundLink{$lnk} );
				my $newDat = "$LinkPath[0].$DatEnd[1]";
				$inself->{verbosity}->verbose(
"Copying files from current directory in previous folder.\n",
					"OK"
				);
				copy( $vipFoundLink{$lnk}, $newDat );
				$inself->{verbosity}
				  ->verbose( "Delete unnecessary links in previous folder.\n",
							 "OK" );
				unlink($lnk);

				#Verknüpfungen erneuern
				$inself->{verbosity}
				  ->verbose( "Updating Links to other relevant directories.\n",
							 "OK" );
				$inself->changeLinks( $lnk, $newDat, @foundDir );
			}
		}
	}
	$inself->{verbosity}->verbose( "Delete $inself->{'deleteFile'}!\n", "OK" );

	#loeschen
	$inself->del();
}

#----------------------Nachfrage, ob wirklich geloescht werden soll --------------------------
sub check {
	my $inself = shift;
	print
"Do you really want to delete this file or directory: $inself->{'deleteFile'} ? (Y/N) \n";
	while (1) {
		my $eingabe = <STDIN>;
		chomp $eingabe;
		if (    $eingabe =~ m/^j$/i
			 || $eingabe =~ m/^ja$/i
			 || $eingabe =~ m/^yes$/i
			 || $eingabe =~ m/^y$/i )
		{
			$inself->{verbosity}
			  ->verbose( "Start delete: $inself->{deleteFile}.\n", "OK" );
			last;
		}
		elsif (    $eingabe =~ m/^n$/i
				|| $eingabe =~ m/^nein$/i
				|| $eingabe =~ m/^no$/i )
		{
			$inself->{verbosity}
			  ->verbose( "Stop: aborted delete.\n", "WARNING" );
			exit;
		}
		else {
			print "ERROR: It was not answered by \"yes\" (Y) or \"no\" (N)!\n";
		}
	}
}

#----------------------Vorgaengerarchiv finden-------------------------------------------------
sub findPreDir {
	my $inself    = shift;
	my $preArchiv = "";
	my @foundArchives;

	#Archive mit dem selben Namen finden
	opendir( my $dh, $inself->{'mainArchivpath'} )
	  || die "Archiv kann nicht geöffnet werden!";
	while ( readdir $dh ) {
		if (    $_ =~ m/$inself->{'archivName'}/i
			 && $_ ne $inself->{'archivFullName'}
		  )    # hat gleiche source ist aber nicht delOrdner
		{
			push( @foundArchives, $_ );
		}
	}
	closedir $dh;
	if (@foundArchives) {
		my @sortFoundArchives = reverse(@foundArchives);

		#Neuere Verzeichnisse aussortieren
		while (    @sortFoundArchives
				&& $sortFoundArchives[0] ge $inself->{'archivFullName'} )
		{
			shift(@sortFoundArchives);
		}
		$inself->{verbosity}->verbose( "Found previous folder.\n", "OK" );
		return @sortFoundArchives;
	}
	$inself->{verbosity}->verbose( "No previous directory found.\n", "OK" );
	return @foundArchives;
}

#----------------------Verknuepfungen pruefen bei Archiv-------------------------------------------------
sub findLinksPreDir {
	my ( $inself, $preDir ) = @_;
	my $fullPreDir;
	my @allLinkFiles;    #Alle Verlinkungen im PreArchiv
	if ( $preDir =~ m/\./ )    #ist es einzelne Datei
	{
		my @datName = split( /\./, $preDir );
		my $datNameLink = "$datName[0].lnk";
		$fullPreDir = "$inself->{'mainArchivpath'}$datNameLink";
	}
	else                       #oder Ordner
	{
		$fullPreDir = "$inself->{'mainArchivpath'}$preDir";
	}

	#finde im vorhergehenden PreArchiv .lnk-Dateien
	my %options = (
		wanted => sub {
			my @files;
			my $file = $File::Find::name;
			if ( $file =~ m/.lnk$/i ) {
				push( @allLinkFiles, $file );
			}
		},
		no_chdir => 1,
	);

	#Prüfen, ob Ordner oder Datei in PreArchiv existiert
	if ( -e $fullPreDir ) {
		find( \%options, $fullPreDir );
	}
	return @allLinkFiles;
}

#-----------------Prueft gefundene .lnk-Dateien auf verknüpfung mit aktuellem DelArchiv------------------
sub checkLink {
	my ( $inself, @allLinkFiles ) = @_;
	my @newLinkFiles;    #Verlinkungen mit Datei im DelArchiv
	my %newFiles;
	foreach (@allLinkFiles) {
		my $LINK = Win32::Shortcut->new();
		$LINK->Load($_);

		# Alle Verknuepfungen auf das zu loeschende Verzeichnis finden
		if ( $LINK->{'Path'} =~ m/$inself->{archivFullName}/i ) {
			$newFiles{$_} = $LINK->{'Path'};
			push( @newLinkFiles, $_ );
		}
		$LINK->Close();
	}
	return %newFiles;
}

#------------------------------Verknuepfungen suchen ------------------------------
sub changeLinks {
	my ( $inself, $newLink, $newDat, @foundDir ) = @_;

	#alle restlichen Archive nach lnk-Datei durchsuchen
	foreach my $dir (@foundDir) {

		#letze Predir schon oben geprüft
		if ( $dir eq $foundDir[0] ) { next; }
		my $newCheckdir = "$dir";
		my @tmp         =
		  split( /\_\d{4}\_\d{2}\_\d{2}\_\d{2}\_\d{2}\_\d{2}/, $newLink );
		if ( $#tmp > 0 ) {
			$newCheckdir = "$dir$tmp[1]";
		}
		my @foundFiles = $inself->findLinksPreDir($newCheckdir);
		if (@foundFiles) {

			#Prüfe ob link auf DelDatei
			my %newLinks = $inself->checkLink(@foundFiles);
			if ( keys %newLinks ) {

				#Gefunde Links neu verlinken
				$inself->newLink( $newDat, %newLinks );
			}
		}
	}
}

#----------------------Verknuepfung erneuern----------------------------------------------
sub newLink {
	my ( $inself, $newDat, %newLinks ) = @_;
	foreach ( keys %newLinks ) {
		my $LINK = Win32::Shortcut->new();
		$LINK->Load($_);
		$LINK->{'Path'} = $newDat;
		$LINK->Save();
		$LINK->Close();
	}
}

#----------------------Endgueltig loeschen----------------------------------------------
sub del {
	my $inself = shift;
	rmtree( $inself->{'deleteFile'} );
}

sub DESTROY {
    my $self = shift;
    $self->{verbosity}=undef;
}

1;
