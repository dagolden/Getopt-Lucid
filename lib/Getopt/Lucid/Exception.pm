package Getopt::Lucid::Exception;
use 5.006;
use strict;
use warnings;
our $VERSION = '0.10';

# Required modules
use Carp;

#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

=head1 NAME

Getopt::Lucid::Exception - Put abstract here 

=head1 SYNOPSIS

  use Getopt::Lucid::Exception;
  blah blah blah

=head1 DESCRIPTION


=head1 USAGE

=cut

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

=head1 INSTALLATION

The following commands will build, test, and install this module:

 perl Build.PL
 perl Build
 perl Build test
 perl Build install

=head1 BUGS

Please report bugs using the CPAN Request Tracker at 
http://rt.cpan.org/NoAuth/Bugs.html?Dist=

=head1 AUTHOR

David A Golden (DAGOLDEN)

dagolden@cpan.org

http://dagolden.com/

=head1 COPYRIGHT

Copyright (c) 2005 by David A Golden

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut
