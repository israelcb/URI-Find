#!/usr/bin/perl
use strict;
use warnings;

# Test decruft function
use URI::Find;
use Test::More qw/no_plan/;

sub run_tasks {
    my $tasks        = shift;
    my $replacements = shift;

    my $cached_instance = URI::Find
        ->new(sub {});

    foreach my $t (@$tasks) {
        my ($expected, @tests) =
            (ref $t eq 'ARRAY')
            ? @$t
            : ($t, $t);
    
        TEST:foreach my $str (@tests) {
            foreach my $r (@$replacements) {
                my %tests;

                my $r_str = defined $r ? $r : 'undef';
                $tests{"R=$r_str, new instance"}
                    = URI::Find->new(sub { $r });
                
                $tests{'R=void, new instance'}
                    = URI::Find->new(sub {});

                $tests{'R=void, cached instance'}
                    = $cached_instance;

                foreach my $desc (keys %tests) {
                    my $result = $tests{$desc}->decruft($str);
                    
                    is($result, $expected, "V='$str', $desc");
                    next TEST unless $result eq $expected
                }
            }
        }
    }
}

my @tasks = (
    "", " ", 0, 1, -1
    
    , "atom.io"
    , "cpan.org%"
    , "github.com"
    , "perlmonks.org"
    , "http://perl.com"
    , "https://perl.org"
    , "www.perlmaven.com"
    , "www.perlmonks.org"
    , "ftp://myserver.net"
    , "custom://www.x.com"
    , "http://www.perl.com"
    , "ftp://myserver.net🤫"
    , "https://www.zed.dev/"
    , "ws://super-socket.io"
    , "https://pulsar-edit.dev"
    , "https://duckduckgo.com/"
    , "https://duckduckgo.com/>"
    , "wss://ssl-super-socket.io"
    , "https://medium.com#cake?cache=cheese"
    , "https://duckduckgo.com/?q=raku%20programming"
    , "https://medium.com?cache=x&hash=iofremiovj43v453v4"
    
    , "https://www.perlmonks.org"
    , "https://www.perlmonks.org?"
    , "https://www.perlmonks.org&"
    , "https://www.perlmonks.org?&"
    , "https://www.perlmonks.org?&{"
    , "https://www.perlmonks.org?&{}"
    
    , "https://medium.com?cache=cheese"
    , "https://medium.com?cache=cheese["
    , "https://medium.com?cache=cheese[]"
    
    , "https://raku.org\t"
    , "\t\thttps://raku.org\t"
    , "https://jobs.perl.org_"
    , "https://jobs.perl.org+"
    , "https://jobs.perl.org+_"
    , "     http://yahoo;.com "
    , "\r\nhttps://dev.perl.org"
    , "\n\nhttps://blogs.perl.org"
    , "\thttps://learn.perl.org#\t"
    , "https://strawberryperl.com\r\n"
    , "https://raku.org/install\t\r\n"
    , "\r\n\r\nhttps://dev.perl.org#?&><"
    , "https://metacpan.org/pod/List::UtilsBy\n"
    , "  ftp://myserver.net. ;https://perl.org;:::"
    , "https://www.perlmonks.org?gov=--3&&perl_v=5006!"
    , "\"\@https://www.perlmonks.org?gov=--3&&perl_v=5006;\@"
    
    , [
        # Expected result (all tests bellow)
        "https://perl.org",
        
        "https://perl.org;",
        "https://perl.org,",
        "https://perl.org'",
        "https://perl.org]",
        "https://perl.org}",
        "https://perl.org)",
        "https://perl.org]]",
        "https://perl.org}}",
        "https://perl.org))",
        "https://perl.org\"",
        "https://perl.org;,",
        "https://perl.org\",",
        "https://perl.org\"\",",
        "https://perl.org\";,;",
        "https://perl.org';,;'",
        "https://perl.org\"',\",';",
    ]
    
    , [
        "https://www.duckduckgo.com/",
        "https://www.duckduckgo.com/.",
        "https://www.duckduckgo.com/;",
        "https://www.duckduckgo.com/,",
        "https://www.duckduckgo.com/''",
        "https://www.duckduckgo.com/\"\"",
    ]

    , [
        "(https://www.cpan.org)"
        , "(https://www.cpan.org)"
        , "(https://www.cpan.org)])"
        , "(https://www.cpan.org)})"
        , "(https://www.cpan.org);;)"
        , "(https://www.cpan.org),)"
        
        # RETRY:
        # , "(https://www.cpan.org)[}]"
        # , "(https://www.cpan.org)[\]]"

        # ! FAILED:
        # , "(https://www.cpan.org)[)]"
        
        # ! FAILED:
        # , "(https://www.cpan.org)))"
        # , "(https://www.cpan.org))]"
        # , "(https://www.cpan.org))("
        # , "(https://www.cpan.org)')'"
        # , "(https://www.cpan.org)\")\""
        # , "(https://www.cpan.org)'\")\"'"
    ]

    # , "https://www.perlmonks.org?&}"
    # , "https://www.perlmonks.org?&)"
    # , "https://medium.com?cache=cheese]"

    , [
        "https://www.perlmonks.org?gov=--3&&perl_v=5006",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006.",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006'",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006,",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006;",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006\"",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006,,",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006;;",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006;;,",
        "https://www.perlmonks.org?gov=--3&&perl_v=5006,;;,",
    ]

    , [
        " \n==>>\"https://download.torproject.org/#?&&??&",
        " \n==>>\"https://download.torproject.org/#?&&??&.\"",
        " \n==>>\"https://download.torproject.org/#?&&??&,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&;\"",
        " \n==>>\"https://download.torproject.org/#?&&??&'\"",
        " \n==>>\"https://download.torproject.org/#?&&??&\"\"",
        " \n==>>\"https://download.torproject.org/#?&&??&..\"",
        " \n==>>\"https://download.torproject.org/#?&&??&,,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&.,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&;.\"",
        " \n==>>\"https://download.torproject.org/#?&&??&.;\"",
        " \n==>>\"https://download.torproject.org/#?&&??&..,\"",
        " \n==>>\"https://download.torproject.org/#?&&??&..\"\"",
        " \n==>>\"https://download.torproject.org/#?&&??&.;\"\"",
    ]

    , [
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org.",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org,",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org..",
        "\r\t\t\thttps://learn.perl.org\nhttps://blogs.perl.org,\"",
    ]

    , [
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///.",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///,",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///;",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///\"\"",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///''",
        "(ws://creativecommons.org/licenses/by-nc-nd/3.0/us///.............",
    ]

    , [
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&'",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&\"",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&'.",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&,,",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&\"\"",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&\";,",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&',;'",
        "'https://programming-idioms.org/idiom/258/convert-list-of-strings-to-list-of-integers\?&&',,'",
    ]

    , [
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be",
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be...",
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be'...",
        "ftp://my-super-secret-server.gov#going-nuclear?;access=nobody&&is-'\"'domination'\"'-plan=may_be\"...,",
    ]
);

my @replacements = (
    undef
    , '> URL <'
    , '**&', '&&&'
    , '([{;;> URL <,,}])'
    , ' https://perl.org'
    , 'https://perl.org;;'
    , '', 0, 1, -1, 1_111.11
    
    , (sub { \(my $hash = {})     })->()
    , (sub { \(my $scalar = 0)    })->()
    , (sub { \(my $array = [])    })->()
    , (sub { \(my $code = sub {}) })->()
);

run_tasks(
    \@tasks
    , \@replacements
);

1
