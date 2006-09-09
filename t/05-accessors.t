#!/usr/bin/perl
use strict;
use warnings;
use blib;  

use Test::More;
use Test::Exception;
use Data::Dumper;
use Exception::Class::TryCatch;

use Getopt::Lucid ':all';
use Getopt::Lucid::Exception;

# Work around win32 console buffering that can show diags out of order
Test::More->builder->failure_output(*STDOUT) if $ENV{HARNESS_VERBOSE};

sub why {
    my %vars = @_;
    $Data::Dumper::Sortkeys = 1;
    return "\n" . Data::Dumper->Dump([values %vars],[keys %vars]) . "\n";
}

#--------------------------------------------------------------------------#
# Test cases
#--------------------------------------------------------------------------#

my $spec = [
    Switch("-t"),
    Counter("-v"),
    Param("-f"),
    List("-I"),  
    Keypair("-d"),
];

my $case = { 
    argv    => [ qw( -tvvf=passwd -I /etc -I /lib -d os=linux ) ],
    result  => { 
        t => 1, 
        v => 2, 
        f => "passwd", 
        I => [qw(/etc /lib)],
        d => { os => "linux" },
    },
    desc    => "getopt accessors"
};

my $replace = { 
    t => 2, 
    v => 3, 
    f => "group", 
    I => [qw(/var /tmp)],
    d => { os => "win32" },
};

my $num_tests = 11 ;
plan tests => $num_tests ;

my ($gl, @cmd_line);
try eval { $gl = Getopt::Lucid->new($spec, \@cmd_line) };
catch my $err;
is( $err, undef, "spec should validate" );
SKIP: {    
    if ($err) {
        skip "because spec did not validate", $num_tests - 1;
    }
    @cmd_line = @{$case->{argv}};
    my $expect = $case->{result};
    my %opts;
    try eval { %opts = $gl->getopt->options };
    catch my $err;
    if ($err) {
        fail( "$case->{desc} threw an exception")
            or diag "Exception is '$err'";
        skip "because getopt failed", $num_tests - 2;
    } else {
        for my $key (keys %{$case->{result}}) {
            no strict 'refs';
            my $result = $case->{result}{$key};
            if ( ref($result) eq 'ARRAY' ) {
                is_deeply( [eval "\$gl->get_$key"], $result, 
                    "accessor for '$key' correct");
                &{"Getopt::Lucid::set_$key"}($gl,@{$replace->{$key}});
                is_deeply( [eval "\$gl->get_$key"], $replace->{$key}, 
                    "mutator for '$key' correct");
            } elsif ( ref($result) eq 'HASH' ) {
                is_deeply( {eval "\$gl->get_$key"}, $result, 
                    "accessor for '$key' correct");
                &{"Getopt::Lucid::set_$key"}($gl,%{$replace->{$key}});
                is_deeply( {eval "\$gl->get_$key"}, $replace->{$key}, 
                    "mutator for '$key' correct");
            } else {
                is( (eval "\$gl->get_$key") , $result,
                    "accessor for '$key' correct");
                &{"Getopt::Lucid::set_$key"}($gl,$replace->{$key});
                is( eval "\$gl->get_$key", $replace->{$key}, 
                    "mutator for '$key' correct");
            }
        }
    }
}


