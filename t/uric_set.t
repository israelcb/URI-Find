#!/usr/bin/perl
use strict;
use warnings;

use URI::Find;
use Test::More tests => 2;

my $callback = sub { $_[0] };
my $f = URI::Find->new($callback);
my $regex_str = $f->uric_set;

is(
    ref $regex_str, ''
    , 'URI::Find::uric_set returns a scalar value'
);

my $reserved   = '\;\/\?\:\@\&\=\+\$\,\[\]';
my $mark       = '\-_\.\!\~\*\\\'\(\)';
my $unreserved = "A-Za-z0-9$mark";

is(
    qr/$regex_str/
    , "(?-xism:$reserved\\p{isAlpha}$unreserved%)"
    , 'qr/URI::Find::uric_set/ results in the expected regex'
);

1
