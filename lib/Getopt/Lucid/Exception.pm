package Getopt::Lucid::Exception;
use 5.006;
use strict;
use warnings;

our $VERSION = '0.19';
$VERSION = eval $VERSION;

use Exception::Class (
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

1; #this line is important and will help the module return a true value
__END__

# AUTHOR
# David A Golden (DAGOLDEN)
# dagolden@cpan.org
# http://dagolden.com/
#
# COPYRIGHT
#
# Copyright (c) 2005 by David A Golden
#
# This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.
#
# The full text of the license can be found in the
# LICENSE file included with this module.
