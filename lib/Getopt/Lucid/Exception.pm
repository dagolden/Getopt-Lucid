use 5.006;
use strict;
use warnings;
package Getopt::Lucid::Exception;
# ABSTRACT: Exception classes for Getopt::Lucid
# VERSION

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
    },

    "Getopt::Lucid::Exception::Usage" => {
        description => "Invalid usage",
    },

);

sub throw_spec {
    Getopt::Lucid::Exception::Spec->throw("$_[0]\n");
}

sub throw_argv {
    Getopt::Lucid::Exception::ARGV->throw("$_[0]\n");
}

sub throw_usage {
    Getopt::Lucid::Exception::Usage->throw("$_[0]\n");
}

1;

