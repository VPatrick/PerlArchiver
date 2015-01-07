#!/usr/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib qw(dirname(dirname abs_path $0) . "/Archiver");
use del;

 my $d = del->new();
 

#*****************************
#       Create -c
#*****************************

$d->addDestination("D:/Dropbox/FH/ws14_15/Perl/github/Archiver/C_Users_Hein_Data_2014_12_20_11_30_58/Unterordner");   # TestArchive ist das Zielverzeichnis, muss angepasst werden
# $d->addDestination("D:/Dropbox/FH/ws14_15/Perl/github/Archiver/C_Users_Hein_Data_2014_12_20_11_30_58");
# $d->addDestination("D:/Dropbox/FH/ws14_15/Perl/github/Archiver/C_Users_Hein_Data_2014_12_20_11_30_58/test.txt");

$d->delete_d();                    # Aufruf von Delete d
