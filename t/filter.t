#!/usr/bin/perl -w

# Test the filter function

use strict;

use Test::More 'no_plan';

use URI::Find;

my @replacements = (
    # Simple cases
    qw/xx& &&&* URL/
    , '&&* *&&'
    , '{CENSORED}'
    , '^CENSORED^'
    , '     &&* *&& '
    , ' <<!!>> CENSORED <<!!>> '

    # Special cases (Perl, PHP, PostgreSQL & others)
    , qw/$1 $0 $_ \1 \\1 \\\1 \\\\1/
    , '${$url $str $input} ${exit 0;} $${die}'

    # URL's
    , qw{www.x.com nsa.gov https://nsa.gov http://yahoo.com}
    , qw{https://www.nsa.gov http://perl.org file:///:C/users/ronald}
    , 'Broken, please report this at https://nsa.gov?report=broken-link'

    # Emojis
    , qw/😖 ⚠️ ‼️ ⚡️ 🚨 😲 🤓 ☣️ ☠️ 💀 🏴‍☠️ ⛓️‍💥 😡 🔴 😩 💻 👨🏻‍💻/
    , '⛓️‍💥 Sorry, broken link ⛓️‍💥'
    , '🚫🚫🚫🚫 CENSORED 😕⚠️⚠️⚠️⚠️'

    # HTML
    , qw/&amp; &AMP; &num;&num;&num;CENSORED/
    , '<strong style="color: red !important">CENSORED</strong>'

    # Multiline
    , qq/
        Curabitur sodales, neque non posuere rhoncus, libero
        faucibus ligula eget imperdiet aliquet. Vivamus sed.

        Curabitur lorem nisl, viverra non sollicitudin a, 
        eget, faucibus est. Quisque at ex id augue blandit.
    /
    , qq^
        <session class="censored-content-banner">
            <img class="angry-bird" src="assets/img/angry-eagle.gif"/>
            <h4 class="censorship-title">🚨🚨 Censored</h4>
            <p class="last-warning">
                😰 ###You have reached the 'limits' of insanity inside the internet.&nbsp;
                🔥 **We believe that you are under too much stress.&NonBreakingSpace;
                😎☀️ (((Please, stop programming and relax a little on the links bellow.&amp;&AMP;
            </p>

            <!-- A comment,, because why not 🤷🏻
                    -->
        </session>
    ^

    # , undef ERROR
    , 0, 1, -1
    , 1_001.00
    , 1_001, -1_001
    , 1_001.0606965
    , -1_001.2342
    , do { "" . \(my $ref) }
    , do { "" . \(my %ref) }
    , do { "" . \(my @ref) }
);

my %tasks;
add_simple_tests(\%tasks, @replacements);
add_simple_non_rep_tests(\%tasks, @replacements);
add_standard_tests(\%tasks);

foreach my $msg (keys %tasks) {
    my $task = $tasks{$msg};
    my ($input, $r, $excepted) = @$task;
    
    my $f = URI::Find->new(sub { $r });
    $f->find(\(my $str = $input), \&simple_escape);
    is($str, $excepted, "$msg (input: '$input')")
}

sub simple_escape {
    my($toencode) = @_;
    $toencode =~ s{&}{&amp;}gso;
    return $toencode;
}

sub add_simple_tests {
    my ($tasks, @r) = @_;
    
    my @tests;
    push @tests, [
        "Simple URL filtering, 'www.' included"
        , "http://www.perl.com"
    ],[
        "Simple URL filtering, 'www.' included, small URL"
        , "http://www.x.com"
    ],[
        "Simple URL filtering, small URL"
        , "https://x.com",   
    ],[
        "Simple URL filtering, schema http://"
        , "http://perl.org"
    ],[
        "Simple URL filtering, schema ftp://"
        , "ftp://old-is-cool.net/update"
    ],[
        "Simple URL filtering, schema https://"
        , "https://google.com"
    ],[
        "Simple URL filtering, with &amp;"
        , "ftp://perl.org&amp;"
    ],[
        "Simple URL filtering, with params"
        , "https://www.vim.org/users/trust-me-bro"
    ],[
        "Simple URL filtering, with query params"
        , "https://www.kali.org?foo=bar"
    ],[
        "Simple URL filtering, with multiple query params"
        , "https://zed.dev?foo=bar&baz=quxxxx"
    ],[
        "Simple URL filtering, with param + query params"
        , "https://www.vim.org/users/george?foo=bar&baz=qux"
    ],[
        "Simple file path filtering (Windows .txt)"
        , "file:///C:/suggestions/movies.txt"
    ],[
        "Simple file path filtering (Windows .exe)"
        , "file:///C:/folder/32034499absolute-safe_executable.exe"
    ],[
        "Simple file path filtering (Mac .crash)"
        , "file://Users/gerald/cheese.crash"
    ],[
        "Simple file path filtering (Linux .pl)"
        , "file:///home/ronald/perl/absolute-perl/main.pl"
    ];

    foreach my $t (@tests) {
        my ($msg, $url) = @$t;
        
        $$tasks{"$msg (replacement: '$_')"}
            = [$url, $_, $_ ]
        foreach @r
    }
}

sub add_simple_non_rep_tests {
    my ($tasks, @r) = @_;
    
    my @tests;
    push @tests
        , ["Zero", 0]
        # , ["Undef", undef]
        , ["Empty string", ""]
        , ["Simple quote", "'"]
        , ["Double quote", q/'/]
        , ["Double quote", q/"/]
        , ["Not a number", "NaN"]

        , ["&", "&", "&amp;"]
        , ["&amp;", "&amp;", "&amp;amp;"]
        , ["&AMP;", "&AMP;", "&amp;AMP;"]

        , ["Emoji", "😎"]
        , ["Emoji + &", "‼️&", "‼️&amp;"]
        , ["Emoji + &amp;", "🌞&amp;", "🌞&amp;amp;"]
        
        , ["Emojis", " 🔥 ☀️ 💻 🏁 🤡 ⛓️‍💥"]
        , [
            "Emojis + &"
            , " 🔥 & ☀️& 💻 & 🏁 🤡 ⛓️‍💥"
            , " 🔥 &amp; ☀️&amp; 💻 &amp; 🏁 🤡 ⛓️‍💥"
        ]
        
        , ["Text with Emojis", " 👨🏻‍💻 A job well done  "]
        
        , ["Perl ref", do { "" . \(my $ref) }]
        , ["Perl hash ref", do { "" . \(my %ref) }]
        , ["Perl array ref", do { "" . \(my @ref) }]
        
        , ["One", 1]
        , ["One one one", 111]
        , ["One one one, dot one", 111.1]
        , ["One one one, dot one one one", 111.111]
        , ["One underline one one one, dot one one one", 1_111.111]
        
        , ["Minus one", -1]
        , ["Minus one one one", -111]
        , ["Minus one one one, dot one", -111.1]
        , ["Minus one one one, dot one one one", -111.111]
        , ["Minus one underline one one one, dot one one one", -1_111.111]
        
        , ["Number (string)", "42"]
        , ["High Number (string)", "42343334"]
        , ["Negative Number (string)", "-42"]
        , ["High negative Number (string)", "-42"]
        
        , ["Money, no space", "\$42"]
        , ["Money, with space", "\$ 42"]
        , ["Money, cents", "\$ 42,67"]
        , ["Money, 4 cents digits", "\$ 42,6732"]
        , ["Money, high value", "\$ 42 032"]
        , ["Money, high value, cents", "\$ 426 329 404,88"]

        , [
            "Simple URL filtering, 'www.' included, no schema"
            , "www.perl.com"
        ]
        
        , [
            "Simple URL filtering, 'www.' included, small URL, no schema"
            , "www.x.com"
        ]
        
        , [
            "Thing which looks like a URL but isn't"
            , "noturi:&amp; should also be escaped"
            , "noturi:&amp;amp; should also be escaped"
        ]

        , [
            "Thing which looks like a URL inside brackets, but isn't"
            , "Something & <foo://bar&.com> whatever"
            , "Something &amp; <foo://bar&amp;.com> whatever"
        ]

        , [
            "Non-URL nested inside brackets"
            , q{<a href="foo://example&.com">}
            , q{<a href="foo://example&amp;.com">}
        ]
    ;

    foreach my $t (@tests) {
        my ($msg, $str, $expected) = @$t;
        $expected = $str unless defined $expected;
        
        $$tasks{"$msg (replacement: '$_')"}
            = [$str, $_, $expected ]
        foreach @r
    }
}

sub add_standard_tests {
    my $tasks = shift;

    my @tests;
    push @tests, 
        ["Foo&Bar http://abc.com.", "Foo&amp;Bar xx&."],
        ["http://abc.com. http://abc.com.", "xx&. xx&."],
        ["http://abc.com?foo=bar&baz=foo", "xx&"],
        ["& http://abc.com?foo=bar&baz=foo", "&amp; xx&"],
        ["http://abc.com?foo=bar&baz=foo &", "xx& &amp;"],
        ["Foo&Bar http://abc.com", "Foo&amp;Bar xx&"],
        ["http://abc.com. Foo&Bar", "xx&. Foo&amp;Bar"],
        ["Foo&Bar http://abc.com. Foo&Bar", "Foo&amp;Bar xx&. Foo&amp;Bar"],
        ["Foo&Bar\nhttp://abc.com.\nFoo&Bar", "Foo&amp;Bar\nxx&.\nFoo&amp;Bar"],
        ["Foo&Bar\nhttp://abc.com. http://def.com.\nFoo&Bar", 
        "Foo&amp;Bar\nxx&. xx&.\nFoo&amp;Bar"]
    ;

    foreach my $t (@tests) {
        my ($str, $expected) = @$t;
        $$tasks{"escape $str"} = [$str, 'xx&', $expected ]
    }
}

1
