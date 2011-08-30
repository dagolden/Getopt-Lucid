use 5.006;
use strict;
use warnings;
package Getopt::Lucid::Exception;
# ABSTRACT: Exception classes for Getopt::Lucid
# VERSION

use Exception::Class 1.23 (
    "Getopt::Lucid::Exception" => {
        description => "Unidentified exception",
    },

    "Getopt::Lucid::Exception::Spec" => {
        description => "Invalid specification",
        alias => "throw_spec"
    },

    "Getopt::Lucid::Exception::ARGV" => {
        description => "Invalid argument on command line",
        alias => "throw_argv"
    },

    "Getopt::Lucid::Exception::Usage" => {
        description => "Invalid usage",
        alias => "throw_usage"
    },

);

sub import {
    my $caller = caller(0);
    {
        no strict 'refs';
        *{$caller."::$_"} = *{__PACKAGE__."::$_"}
            for qw( throw_spec throw_argv throw_usage);
    }
}

1;

