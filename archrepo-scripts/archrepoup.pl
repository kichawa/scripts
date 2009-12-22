#!/usr/bin/env perl
# file: Simple script for copying and synchronising Your packages to ArchRepo!  
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#   license = BSD 
#   version = 20091028   
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
use IO::Handle;
use Net::SSH qw(sshopen3);
use Net::SCP qw(scp);

my $user = "";
my $pkg2up = $ARGV[2];

GetOptions( "h|help" => \&help,
            "u|user=s" => \$user,
            "sync" => \&sync,);

# Directories:
my $login = "archrepo\@archrepo.net";
my $onserv = "/usr/home/archrepo/$user/";
my $dest = "$login:$onserv";

my($reader, $writer, $error) = (new IO::Handle, new IO::Handle, new IO::Handle);
$writer->autoflush(1);  
$error->autoflush(1);

sub help {
    my $helpmsg = <<EOM;
Simple script for copying and synchronising Your packages to ArchRepo! 
Usage: $0 [option] [pkg dir/file]

    -h, --help      Displays this message
        --sync      Synchronize package database 
    -u, --user      Set developer nickname 
    
WARNING: To run this script successfully Your RSA pub key has to be added on repository server.
Please send any bug reports to sirmacik at archrepo dot net
EOM
    print($helpmsg);
    exit 0;
}

sub lock {
    # Lock
    print("Locking for upload time... ");
    my $pid = &sshopen3($login, $writer, $reader, $error, "touch $onserv/lock") or die "Can't lock! $!";
    waitpid $pid, 0;
    print("[OK!]\n");
}

sub unlock {
    # Unlock
    print("Unlocking... ");
    my $pid = &sshopen3($login, $writer, $reader, $error, "rm $onserv/lock") or die "Can't unlock! $!";
    waitpid $pid, 0;
    print("[OK!]\n");
    }

sub files {
    # Checks if there are packages in pkgdir
    opendir(my $pkgdir, $pkg2up) or &unlock and die "Can't open $pkg2up! $!";
    my @files = grep( /\.pkg\.tar\.gz$/, readdir($pkgdir));
    closedir $pkgdir; 
    foreach my $file (@files) {
        if (-e "$pkg2up/$file" ) {
            return 1;
        } else {
            return 0;
        }
    }
}

sub copy {
    # Upload files to the server
    if (-d $pkg2up and &files) {
        # Copy all packages from direcrory
        opendir(my $pkgdir, $pkg2up) or &unlock and die "Can't open $pkg2up! $!";
        my @files = grep( /\.pkg\.tar\.gz$/, readdir($pkgdir));
        closedir $pkgdir; 
        # Print packages to upload
        print("Files to upload:\n");
        foreach my $tocopy (@files) {
            print("$tocopy\n");
        }
        print("Proceed? [Y/n] "); my $reply=<STDIN>; chomp $reply;
        if ($reply eq "n") {
            print("Stopped!\n");
            &unlock;
            exit 1;
        } else {
           print("Copying... \n");
            foreach my $file (@files) {
                print("$file... ");
                &scp("$pkg2up/$file", $dest) or &unlock and die "Can't upload to the server! $!";
                print("[OK!]\n");
            }
        }
    } elsif ( $pkg2up =~ m/.pkg.tar.gz$/ and -e $pkg2up) {
        # Copy selected package
        print("Package to upload: $pkg2up\n");
        print("Proceed? [Y/n] "); my $reply=<STDIN>; chomp $reply;
        if ($reply eq "n") {
            print("Stopped!\n");
            &unlock;
            exit 1;
        } else {
            print("Copying... ");
            &scp("$pkg2up", $dest) or &unlock and die "Can't upload to the server! $!";
            print("[OK!]\n");
        }
    } else {
        print("Error: Define package or directory with packages to upload!\n");
        &unlock;
        exit 1;
    }
}

sub sync {
    print("Synchronizing...\n");
    my $pid = &sshopen3($login, $writer, $reader, $error, "archrepo_manage.py") or die "Can't synchronize! $!";
    waitpid $pid, 0;
    while (<$reader>) {
        chomp();
        print "$_\n";
    }
    print("[OK!]\n");
}

sub rmpkg {
    if (-d $pkg2up and &files) {
        # Remove all packages from direcrory
        opendir(my $pkgdir, $pkg2up) or die "Can't open $pkg2up! $!";
        my @files = grep( /\.pkg\.tar\.gz$/, readdir($pkgdir));
        closedir $pkgdir; 
        print("Remove local packages? [y/N] "); my $reply=<STDIN>; chomp $reply;
        if ($reply eq "y") {
            print("Removing... ");
            foreach my $file (@files) {
                print("$file... ");
                unlink("$pkg2up/$file") or die "Can't remove file! $!";
                print("[OK!]\n");
            } 
        } else {
            exit 0;
        }
    } elsif ( $pkg2up =~ m/.pkg.tar.gz$/ and -e $pkg2up) {
        # Remove selected package
        print("Remove local package? [y/N] "); my $reply=<STDIN>; chomp $reply;
        if ($reply eq "y") {
            print("Removing... ");
            unlink("$pkg2up") or die "Can't remove file! $!";
            print("[OK!]\n");
        } else {
            exit 0;
        }
    }
}

# If started without arguments run help
unless ($ARGV[0]) {
        &help;
    }
if ($user eq "dziq" or $user eq "sirmacik" or $user eq "virhilo") {
    &lock;
    &copy;
    &unlock;
    &sync;
    &rmpkg;
    exit 0;
} else {
    print "Error: You are not ArchRepo developer!\n";
    &help;
    exit 1;
}
