use RestoreWin;

$c = RestoreWin->new();

$c->addSource('C:/Users/Kasikci/Desktop/Perl Programme/Archiv');
$c->addDestination('C:/Users/Kasikci/Desktop/Perl Programme/Test');
$c->addSourceName('C_Users_Kasikci_Desktop_Perl Programme_Test');
$c->addUserTime('2017_12_12_12_12_13');
$c->addPartial('/SOURCE_2015_01_02_17_04_14/test/test_0.txt');
$c->setVerboseLevel(0);

$c->restore_rp();