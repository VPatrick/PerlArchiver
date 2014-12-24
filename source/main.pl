use Create;

$c = Create->new();
#$c->verbose("Debug");

#*****************************
#       Create -c
#*****************************
$c->addSource("Test");              # Test ist das Quellverzeichnis, muss angepasst werden
$c->addDestination("TestArchiv");   # TestArchive ist das Zielverzeichnis, muss angepasst werden
#$c->create_c();                    # Aufruf von Create c

##*****************************
##       Create -s
##*****************************
$c->create_s();                     # Aufruf von Create s

##*****************************
##       Create -s
##*****************************
#$c->create_cs();                   # Aufruf von Create cs