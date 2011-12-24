# Getopt::Lucid::Exception
use strict;
use Test::More 0.62;
#--------------------------------------------------------------------------#
# Test cases
#--------------------------------------------------------------------------#

my (@exceptions, @throw_aliases);

BEGIN {
    @exceptions = qw(
        Getopt::Lucid::Exception
        Getopt::Lucid::Exception::Spec
        Getopt::Lucid::Exception::ARGV
    );
    @throw_aliases = qw(
        throw_spec
        throw_argv
    );
}


#--------------------------------------------------------------------------#
# Test script
#--------------------------------------------------------------------------#

plan tests => 2 + @exceptions;

# Work around win32 console buffering that can show diags out of order
Test::More->builder->failure_output(*STDOUT) if $ENV{HARNESS_VERBOSE};

use Getopt::Lucid::Exception;
use Getopt::Lucid ':all';

for my $e ( @exceptions ) {
    eval { $e->throw };
    ok ($@->isa($e), "throwing $e");
}

can_ok( "Getopt::Lucid$_", @throw_aliases ) for ( "::Exception", "" );


