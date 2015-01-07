use Create;

$c = Create->new(1);
#$c->verbose("Debug");

#*****************************
#       Create -c
#*****************************
$c->addSource('/Users/michelangeloramunno/Documents/Studium/Semester 6/Perl/Projektarbeit/Test');              # Test ist das Quellverzeichnis, muss angepasst werden
$c->addDestination("/Users/michelangeloramunno/Documents/Studium/Semester 6/Perl/Projektarbeit/TestArchiv");   # TestArchive ist das Zielverzeichnis, muss angepasst werden
#$c->create_c();                    # Aufruf von Create c

##*****************************
##       Create -s
##*****************************
$c->addArchiveName('Users_michelangeloramunno_Documents_Studium_Semester 6_Perl_Projektarbeit_Test');
$c->create_s();                     # Aufruf von Create s

##*****************************
##       Create -s
##*****************************
#$c->create_cs();                   # Aufruf von Create cs