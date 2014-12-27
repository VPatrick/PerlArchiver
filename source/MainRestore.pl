use Restore;

$C = Restore->new();

$C->addSource("/Users/muhammedkasikci/Documents/Perl/Projektarbeit/Archiv");
$C->addDestination("/Users/muhammedkasikci/Documents/Perl/Projektarbeit/Übung");
$C->addSourceName("Verzeichnis 1");
$C->addUserTime("2014_12_12_12_12_13");
$C->addVerbose("1");


##################################################################################
# 					Um ein Unterverzeichnis wiederherzustellen:					 #
#																				 #
# $C->addPartial("Unterverzeichnis 1"); 										 #
# $C->restore_rp();																 #
##################################################################################

##################################################################################
#					Um eine Datei wieder wiederherzustellen:					 #
# $C->addPartial("Test2.rtf");													 #
# $C->restore_rp();																 #
##################################################################################

##################################################################################
#					Um das ganze Verzeichnis wiederherzustellen					 #
# $C->restore_r;																 #
##################################################################################