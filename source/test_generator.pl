#!/usr/bin/perl
use strict;
use warnings;

my $dirname = "test";

for (0 .. 999) {
	$dirname = $dirname . "/test";
}

my @folders = split /\/|\\/, $dirname;
map {
	mkdir $_;
	for (0 .. 999) {
		my $file = "test_" . $_ . ".txt";
		unless(open FILE, '>'.$file) {
			next;
		}
		print FILE "Test " . $_;
		close FILE;
	}
	chdir $_;
} @folders;