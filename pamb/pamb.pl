#!/usr/bin/env perl
# file: simple cli url shortener for goo.gl service
#  
#    Copyright (C) 2011, Marcin Karpezo <sirmacik at gmail dot com>
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
#
use encoding 'utf8';
use 5.010;
use strict;
use warnings;
use JSON;
use Getopt::Long;
use HTTP::Request::Common;  
use LWP::UserAgent; 
use Config::Simple;
use Data::Validate::URI qw(is_uri);

my $decode = '';
my $apicode = 'AIzaSyAL1RxMlY6j-gKClaxkE4D2mSzRR6ThHTY';

GetOptions("d|decode" => \$decode,
           "h|help" => \&helpmsg);

sub info{
    print <<END;
pamb is a simple cli url shortener for goo.gl service

Copyright (C) 2011, Marcin Karpezo 
This program comes with ABSOLUTELY NO WARRANTY. 
This is free software, and you are welcome 
to redistribute it under certain conditions.
For details see COPYING file.

END
}

sub helpmsg {
    info();
    print <<EOM;
Usage: pamb [options] URL

    -h, --help      Displays this message
    -d, --decode    Decode shortened url

EOM
    exit 0;
}

until ( $ARGV[0] ) {
    helpmsg();
}

until ( $decode ) {
    if ( is_uri( $ARGV[0] ) ) {
	my $url = {
	    longUrl => $ARGV[0],
	};
	my $uri = 'https://www.googleapis.com/urlshortener/v1/url?key=' . $apicode;
	my $json_req = to_json( $url );
	my $request = HTTP::Request->new( 'POST', $uri );
	$request->header( 'Content-Type' => 'application/json' );
	$request->content( $json_req );
	
	my $lwp = LWP::UserAgent->new;
	my $res = $lwp->request( $request );
	
	if($res->is_success){
	    my @response = from_json( $res->decoded_content )->{id};
	    print @response, "\n";
	    exit 0;
	} else {
	    print STDERR $res->status_line, "\n";
	    exit 155;
	}
    } else {
	print STDERR "Error: ",$ARGV[0], " isn't valid url.\nUse --help for more informations.\n";
	exit 124;
    }
} 
if ( $decode ) {
    if ( is_uri( $ARGV[0] ) ) {
	my $shorturi = 'https://www.googleapis.com/urlshortener/v1/url?key=' . $apicode . '&shortUrl=' . $ARGV[0];
	my $longrequest = HTTP::Request->new( 'GET', $shorturi );
	
	my $lwp = LWP::UserAgent->new;
	my $res = $lwp->request( $longrequest );
	
	if($res->is_success){
	    my @response = from_json( $res->decoded_content )->{longUrl};
	    print @response, "\n";
	    exit 0;
	} else {
	    print STDERR $res->status_line, "\n";
	    exit 155;
	}
    } else {
	print STDERR "Error: ",$ARGV[0], " isn't valid url.\nUse --help for more informations.\n";
	exit 124;
    }
} else {
    helpmsg();
}

### TODO ###
#
# - authentication
# - history
#
############
