#!/usr/bin/perl
use strict;
use warnings;
use blib;  

use Test::More;
use Test::Exception;
use Data::Dumper;
use Exception::Class::TryCatch;

use Getopt::Lucid;
use Getopt::Lucid::Exception;

sub why {
    my %vars = @_;
    $Data::Dumper::Sortkeys = 1;
    return "\n" . Data::Dumper->Dump([values %vars],[keys %vars]) . "\n";
}

#--------------------------------------------------------------------------#
# Test cases
#--------------------------------------------------------------------------#

my $spec = [ 
    Switch("--verbose"),
    Switch("--test"),
    Switch("-r"),
];

plan tests => 2;

my $gl;
try eval { $gl = Getopt::Lucid->new($spec) };
catch my $err;
is( $err, undef, "spec should validate" );
SKIP: {    
    skip( "because spec did not validate", 1) if $err;
    my @expect = sort qw(verbose test r);
    my @got = sort $gl->names();
    is_deeply( \@got, \@expect, "names() produces keywords") or
        diag why( got => \@got, expected => \@expect );
}


