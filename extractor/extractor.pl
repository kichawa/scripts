#!/usr/bin/env perl
# file: extractor.pl - it will help You with unpacking many types of cmds
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = GPLv3 
#   version = 0.8
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http:orwww.gnu.org/licenses/>.
use encoding 'utf8';

use strict;
use warnings;
use Getopt::Long;

GetOptions( "h|help" => \&help);

sub help {
    print "To extract Your cmd You have to add name of file as an argument. \nExample: \n\textractor archive.tar.gz\n";
}

sub extract {
    my ($name) = $ARGV[0];
    my ($cmd);
    
    if ($name) {
        if ( $name =~ m/.tar.bz2$/ or $name =~ m/.tbz2$/) {
            $cmd = 'tar -xjf';
        } elsif ($name =~ m/.tar.gz$/ or $name =~ m/.tgz$/) {
            $cmd = 'tar -xzf';
        } elsif ($name =~ m/.bz2$/) {
            $cmd = 'bunzip2';
        } elsif ($name =~ m/.gz$/) {
            $cmd = 'gunzip';
        } elsif ($name =~ m/.tar$/) {
            $cmd = 'tar -xf'
        } elsif ($name =~ m/.Z$/) {
            $cmd = 'uncompress';
        } elsif ($name =~ m/.zip$/ or $name =~ m/.ZIP$/) {
            $cmd = 'unzip';
        } elsif ($name =~ m/.rar$/ or $name =~ m/.RAR$/) {
            $cmd = 'unrar x';
        } elsif ($name =~ m/.tar.lzma$/) {
            $cmd = 'tar -x --lzma';
        } elsif ($name =~ m/.lzma$/) {
            $cmd = 'lzma -d';
        } elsif ($name =~ m/.tar.7z$/) {
            $cmd = 'tar -x --use-compress-program=7za ';
        } elsif ($name =~ m/.7z$/) {
            $cmd = '7za x';
        } else {
            $cmd = undef;
        }
    } else {
        print STDERR "Error: Add name of archive!\n";
        help();
        exit 1;
    }

    if ($cmd) { 
        system("$cmd $name") and die "Error:\tUnknown or invalid type of archive: \n$!";
        exit 2;
    } else {
        print STDERR "Error: Unknown or invalid type of cmd";
        mime( $name );
        exit 1;
    }
}

sub mime {
    my ($_) = @_;
    my ($cmd) = q/file -Ls/;
    system("$cmd $_");
}

extract();
exit 0;

