use strict;
use Test::More;
use Data::Dumper;
use Exception::Class::TryCatch;

use Getopt::Lucid ':all';
use Getopt::Lucid::Exception;

# Work around win32 console buffering that can show diags out of order
Test::More->builder->failure_output(*STDOUT) if $ENV{HARNESS_VERBOSE};

#--------------------------------------------------------------------------#
# Test cases
#--------------------------------------------------------------------------#

my $spec = [
    Switch("--verbose|v")->doc("turn on verbose output"),
    Switch("--test")->doc("run in test mode"),
    Switch("--input"),
    Switch("-r")->doc("recursive"),
];

plan tests => 2;

my $gl;
try eval { $gl = Getopt::Lucid->new($spec) };
catch my $err;
is( $err, undef, "spec should validate" );
my $usage = $gl->usage;
my $nl_count =()= ( $usage =~ m{(\n)}g );
is( $nl_count, 5, "got four lines" ) or diag $usage;
