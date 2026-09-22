#!/usr/bin/perl
use strict;
use warnings;

use URI::Find;
use URI::Find::Schemeless;
use Test::More tests => 4;

my $callback = sub { $_[0] };
my $f = URI::Find->new($callback);
my $uri_re = $f->schemeless_uri_re;

is(
    ref $uri_re, 'Regexp'
    , 'URI::Find::schemeless_uri_re returns a regex'
);

is(
    $uri_re, qr/\b\B/
    , 'URI::Find::schemeless_uri_re'
    . ' returns a useless regex'
);

$f = URI::Find::Schemeless->new($callback);
$uri_re = $f->schemeless_uri_re;

is(
    ref $uri_re, 'Regexp'
    , 'URI::Find::Schemeless::schemeless_uri_re'
    . ' returns a regex'
);

isnt(
    $uri_re, qr/\b\B/
    , 'URI::Find::Schemeless::schemeless_uri_re'
    . ' DO NOT return a useless regex'
);

done_testing();
1
