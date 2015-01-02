#!/usr/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib qw(dirname(dirname abs_path $0) . "/Archiver");
use del;


# my $test = del->new("D:/Dropbox/FH/ws14_15/Perl/github/Archiver/C_Users_Hein_Data_2014_12_20_11_30_58");
# my $test2 = del->new("D:/Dropbox/FH/ws14_15/Perl/github/Archiver/C_Users_Hein_Data_2014_12_20_11_30_58/test.txt");
 my $test3 = del->new("D:/Dropbox/FH/ws14_15/Perl/github/Archiver/C_Users_Hein_Data_2014_12_20_11_30_58/Unterordner");
