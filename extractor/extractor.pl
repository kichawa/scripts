#!/usr/bin/env perl
# file: extractor.pl - it will help You with unpacking many types of cmds
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = BSD 
#   All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, 
#       this list of conditions and the following disclaimer in the documentation 
#       and/or other materials provided with the distribution.
#     * Neither the name of the ArchRepo nor the names of its contributors may 
#       be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
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

