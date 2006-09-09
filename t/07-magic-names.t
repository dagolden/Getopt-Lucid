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

sub why {
    my %vars = @_;
    $Data::Dumper::Sortkeys = 1;
    return "\n" . Data::Dumper->Dump([values %vars],[keys %vars]) . "\n";
}

#--------------------------------------------------------------------------#
# Test cases
#--------------------------------------------------------------------------#

sub _invalid_argument   {sprintf("Invalid argument: %s",@_)}
sub _param_ambiguous    {sprintf("Ambiguous value for %s could be option: %s",@_)}

my ($num_tests, @good_specs);

BEGIN {
    
    push @good_specs, { 
        label => "magic bare names in spec",
        spec  => [
            Counter("verbose|v"),
            Counter("test|t"),
            Counter("r"),
            Param("f"),
        ],
        cases => [
            { 
                argv    => [ qw( --verbose v -rtvf=test --r test -- test ) ],
                result  => { 
                    "verbose" => 3, 
                    "test" => 2, 
                    "r" => 2, 
                    "f" => "test",
                },
                after   => [qw( test )],
                desc    => "all three types in command line"
            },            
            { 
                argv    => [ qw( -test ) ],
                exception   => "Getopt::Lucid::Exception::ARGV",
                error_msg => _invalid_argument("-e"),
                desc    => "single dash with word" 
            },            
            { 
                argv    => [ qw( f --test ) ],
                exception   => "Getopt::Lucid::Exception::ARGV",
                error_msg => _param_ambiguous("f", "--test"),
                desc    => "ambiguous param" 
            },            
        ]
    };


} #BEGIN 

for my $t (@good_specs) {
    $num_tests += 1 + 2 * @{$t->{cases}};
}

plan tests => $num_tests;

#--------------------------------------------------------------------------#
# Test good specs
#--------------------------------------------------------------------------#

my ($trial, @cmd_line);

while ( $trial = shift @good_specs ) {
    try eval { Getopt::Lucid->new($trial->{spec}, \@cmd_line) };
    catch my $err;
    is( $err, undef, "$trial->{label}: spec should validate" );
    SKIP: {    
        if ($err) {
            my $num_tests = 2 * @{$trial->{cases}};
            skip "because $trial->{label} spec did not validate", $num_tests;
        }
        for my $case ( @{$trial->{cases}} ) {
            my $gl = Getopt::Lucid->new($trial->{spec}, \@cmd_line);
            @cmd_line = @{$case->{argv}};
            my %opts;
            try eval { %opts = $gl->getopt };
            catch my $err;
            if (defined $case->{exception}) { # expected
                ok( $err && $err->isa( $case->{exception} ), 
                    "$trial->{label}: $case->{desc} should throw exception" )
                    or diag why( got => ref($err), expected => $case->{exception});
                is( $err, $case->{error_msg}, 
                    "$trial->{label}: $case->{desc} error message correct");
            } elsif ($err) { # unexpected
                fail( "$trial->{label}: $case->{desc} threw an exception")
                    or diag "Exception is '$err'";
                pass("$trial->{label}: skipping \@ARGV check");
            } else { # no exception
                is_deeply( \%opts, $case->{result}, 
                    "$trial->{label}: $case->{desc}" ) or
                    diag why( got => \%opts, expected => $case->{result});
                my $argv_after = $case->{after} || [];
                is_deeply( \@cmd_line, $argv_after,
                    "$trial->{label}: \@cmd_line correct after processing") or
                    diag why( got => \@cmd_line, expected => $argv_after);
            }
        }
    }
}


