#!/usr/bin/env perl
# file: Simple script for copying and synchronising Your packages to ArchRepo!  
#  
#   Copyright 2009 Marcin Karpezo <sirmacik at gmail dot com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
Please send any bug reports to <sirmacik at gmail dot com>
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

my $warning = <<END;
Copyright (C) 2010  Marcin Karpezo
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it 
under certain conditions; Read COPYING file for details.

END
print($warning);

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
