#!/usr/bin/perl
use strict;
use warnings;

use URI::Find;
use Test::More tests => 2;

my $callback = sub { $_[0] };
my $f = URI::Find->new($callback);
my $regex_str = $f->uri_re;

is(
    ref $regex_str, ''
    , 'URI::Find::uri_re returns a scalar value'
);

my $scheme_re = '(?-xism:[a-zA-Z][a-zA-Z0-9\\+]*)';
my $uric_re   = $f->uric_set;
(my $uric_cheat_re = $uric_re) =~ s/\\://;

my $expected = sprintf
    '%s:[%s][%s#]*'
    , $scheme_re
    , $uric_cheat_re
    , $uric_re;

is(
    $regex_str, $expected
    , 'URI::Find::uri_re returns the expected regex'
);

done_testing();
1
