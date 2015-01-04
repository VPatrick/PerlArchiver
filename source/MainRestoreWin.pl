use RestoreWin;

$c = Restore->new();

$c->addSource('C:\Users\Kasikci\Desktop\Perl Programme\Archiv');
$c->addDestination('C:\Users\Kasikci\Desktop\Perl Programme\Test');
$c->addSourceName('SOURCE');
$c->addUserTime('2015_12_12_12_12_13');
$c->addPartial('test_0.txt');

$c->restore_rp();