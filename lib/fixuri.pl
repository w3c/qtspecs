#!/usr/bin/perl -- # -*- Perl -*-

use strict;

my $fixcount = 0;

while (<>) {
    if (/^(.*?href=)([\"\'])(http:\/\/www\.w3\.org\/Bugs\/Public\/buglist.cgi.*?\2)(.*)$/s) {
	my $pre = "$1$2";
	my $uri = $3;
	my $post = "$4";

	if ($uri !~ /\&amp;/) {
	    $uri =~ s/\&/\&amp\;/sg;
	    $fixcount++;
	}
	print $pre, $uri, $post;
    } else {
	print $_;
    }
}
print STDERR "Fixed $fixcount URIs.\n";
