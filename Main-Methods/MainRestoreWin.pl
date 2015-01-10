use RestoreWin;

$c = RestoreWin->new();

$c->addSource('C:/Users/Kasikci/Desktop/Perl Programme/Archiv');
$c->addDestination('C:/Users/Kasikci/Desktop/Perl Programme/Test');
$c->addSourceName('C_Users_Kasikci_Desktop_Perl Programme_Test');
$c->addUserTime('2017_01_09_23_55_22');
$c->addPartial('/C_Users_Kasikci_Desktop_Perl Programme_Test/SOURCE_2015_01_02_17_04_14/test_0.txt');
$c->setVerboseLevel(0);

$c->restore_r();
#$c->restore_rp();