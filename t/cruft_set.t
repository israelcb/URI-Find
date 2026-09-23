#!/usr/bin/perl
use strict;
use warnings;

use URI::Find;
use Test::More tests => 2;

my $callback = sub { $_[0] };
my $f = URI::Find->new($callback);
my $regex_str = $f->cruft_set;

is(
    ref $regex_str, ''
    , 'URI::Find::cruft_set returns a scalar value'
);

is(
    $regex_str, q/])},.'";/
    , 'URI::Find::cruft_set returns the expected regex'
);

done_testing();
1
