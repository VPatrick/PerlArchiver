#!/usr/bin/perl
# Author: Patrick Vogt
use strict;
use warnings;

# Erstellen des tiefsten Verzeichnisnamens
# Die Tiefe kann durch die Erhöhung des hinteren Wertes im Kopf der for-Schleife
#	erhöht werden.
my $dirname = "test";
for (0 .. 4) {
	$dirname = $dirname . "/test";
}

my @folders = split /\/|\\/, $dirname;
map {
	mkdir $_;
	# Erstellen von Dateien in den erstellten Verzeichnissen
	# Die Anzahl der Dateien kann durch die Erhöhung des hinteren Wertes im Kopf
	#    der for-Schleife erhöht werden.
	for (0 .. 499) {
		my $file = "test_" . $_ . ".txt";
		unless(open FILE, '>' . $file) {
			next;
		}
		print FILE "Test " . $_;
		close FILE;
	}
	chdir $_;
} @folders;