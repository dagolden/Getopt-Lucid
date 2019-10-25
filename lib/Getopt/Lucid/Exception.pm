use 5.008001;
use strict;
use warnings;
package Getopt::Lucid::Exception;
# ABSTRACT: Exception classes for Getopt::Lucid

our $VERSION = '1.11';

use Exporter;
our @ISA = qw/Exporter Exception::Class::Base/;
our @EXPORT = qw( throw_spec throw_argv throw_usage);

use Exception::Class 1.23 (
    "Getopt::Lucid::Exception" => {
        description => "Unidentified exception",
    },

    "Getopt::Lucid::Exception::Spec" => {
        description => "Invalid specification",
    },

    "Getopt::Lucid::Exception::ARGV" => {
        description => "Invalid argument on command line",
        fields => ['usage'],
    },

    "Getopt::Lucid::Exception::Usage" => {
        description => "Invalid usage",
    },

);

my %throwers = (
    throw_spec => "Getopt::Lucid::Exception::Spec",
    throw_argv => "Getopt::Lucid::Exception::ARGV",
    throw_usage => "Getopt::Lucid::Exception::Usage",
);

for my $t ( keys %throwers ) {
    no strict 'refs';
    *{$t} = sub { $throwers{$t}->throw(message => "$_[0]\n", @_[1..$#_]) };
}

1;

=for Pod::Coverage
description
throw_argv
throw_spec
throw_usage
