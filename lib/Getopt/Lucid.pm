package Getopt::Lucid;
use 5.006;
use strict;
use warnings;
our $VERSION = '0.10';

# Required modules
use Getopt::Lucid::Exception;
use Clone::Any qw(clone);
use Carp;

use base 'Exporter';

our @EXPORT_OK = qw(Switch Counter Param List Keypair);
our %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );

# Definitions
my $VALID_CHAR      = "a-zA-Z0-9";
my $VALID_LONG      = qr/--[$VALID_CHAR]+/;
my $VALID_SHORT     = qr/-[$VALID_CHAR]/;
my $VALID_BARE      = qr/[$VALID_CHAR]+/;
my $VALID_NAME      = qr/$VALID_LONG|$VALID_SHORT|$VALID_BARE/;
my $SHORT_BUNDLE    = qr/-[$VALID_CHAR]{2,}/;
my $NEGATIVE        = qr/(?:--)?no-/;

my @valid_keys = qw( name type required default nocase valid needs canon );
my @valid_types = qw( switch counter parameter list keypair);

our $STRICT = 0;

#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

=head1 NAME

Getopt::Lucid - Clear, readable syntax for command line processing

=head1 SYNOPSIS

  # simple option specifications with aliases
  
  @specs = (
    Switch("version|V"),    
    Counter("verbose|v"), 
    Param("config|C"), 
    List("lib|l|I"),
    Keypair("define"),
    Switch("help|h")
  );
  
  $opt = Getopt::Lucid->getopt( \@specs );
  
  $verbosity = $opt->get_verbose;
  @libs = $opt->get_lib;
  %defs = $opt->get_define;
  
  # advanced specification options

  @adv_spec = (
    Param("input")->required,       # required
    Param("mode")->default("tcp"),  # defaults
    Param("host")->needs("port"),   # dependencies
    Param("port", qr/\d+/ ),        # regex validation
    Param("config", sub { -r } ),   # custom validation
    Param("help")->anycase,         # case insensitivity
  );
  
  # example with additional defaults (with Config::Simple)

  if ( -r $opt->get_config ) {
    $config = Config::Simple->new($opt->get_config);
    $opt->merge_defaults( $config->vars ); 
  }


=head1 DESCRIPTION

The goal of this module is providing good code readability and clarity of
intent for command-line option processing.  While readability is a subjective
standard, Getopt::Lucid relies on a more verbose, plain-English option
specification as compared against the more symbolic approach of Getopt::Long.
Key features include:

=over

=item *
Five option types: switches, counters, parameters, lists, and keypairs

=item * 
Three option styles: long, short (including bundled), and bare (without
dashes)

=item *
Specification of defaults, required options and option dependencies

=item *
Validation of options with regexes or subroutines

=item *
Support for parsing any array, not just the default @ARGV

=item *
Incorporation of external defaults (e.g. from a config file) with
user control of precedence

=back

=head1 USAGE

=head2 Option Styles and "Strictness"

Getopt::Lucid support three kinds of option styles: long-style ("--foo"), 
short-style ("-f") and bareword style ("foo").  Short-style options
are automatically unbundled during command line processing if a single dash
is followed by more than one letter ("-xzf").

MORE TO BE WRITTEN

=head2 Options Names, Aliases, and Styles

Each option is identified with a string consisting of the option "name"
followed by zero or more "aliases", with an alias (and each subsequent alias)
separated by a vertical bar character.  E.g.:

 "libs|l|I"

Names and aliases must be valid perl words -- alphanumeric plus underscore.

MORE TO BE WRITTEN

=head2 Option Specification Constructors

Options specifications are given in an array.  Entries in the array must be
created with one of five special constructor functions that return a
specification object.  The form of the constructor is:

 Param( NAME_ARGUMENT, VALIDATION_ARGUMENTS );
 
=over

=item * C<Switch>

=item * C<Counter>

=item * C<Param>

=item * C<List>

=item * C<Keypair>

=back

=cut


sub Switch  { 
    return bless { name => shift, type => 'switch' },
                 "Getopt::Lucid::Spec"; 
}
sub Counter { 
    return bless { name => shift, type => 'counter' },
                 "Getopt::Lucid::Spec"; 
}
sub Param   { 
    my $self = { name => shift, type => 'parameter' };
    $self->{valid} = shift if @_;
    return bless $self, "Getopt::Lucid::Spec"; 
}
sub List    { 
    my $self = { name => shift, type => 'list' };
    $self->{valid} = shift if @_;
    return bless $self, "Getopt::Lucid::Spec"; 
}
sub Keypair { 
    my $self = { name => shift, type => 'keypair' };
    $self->{valid} = [ @_ ] if scalar @_;
    return bless $self, "Getopt::Lucid::Spec"; 
}

=pod 

Specification can be further modified with the following methods,
which can be chained as necessary:

=over

=item * C<default>

=item * C<required>

=item * C<needs>

=item * C<anycase>

=back

=cut

package Getopt::Lucid::Spec;

sub required { my $self = shift; $self->{required} = 1; return $self };

sub default {  
    my $self = shift;
    my $type = $self->{type};
    if ($self->{type} eq 'keypair') {
        if (ref($_[0]) eq 'HASH') {
            $self->{default} = shift;
        }
        elsif ( @_ % 2 == 0 ) {
            $self->{default} = { @_ };
        }
        else {
            $self->{default} = []; # will cause an exception later
        }
    }
    elsif ( $self->{type} eq 'list' ) {
        $self->{default} = [ @_ ];
    }
    else {
        $self->{default} = shift; 
    }
    return $self
};

sub anycase { my $self = shift; $self->{nocase}=1; return $self };

sub needs { my $self = shift; $self->{needs}=[@_]; return $self };

package Getopt::Lucid;

=head2 Validation

DETAILS TO BE WRITTEN

=head2 Parsing the Command Line

DETAILS TO BE WRITTEN

=head2 Accessors/Mutators

After reading and parsing an array containing options with a Getopt::Lucid
option, the values of the options may be read or modified using
accessors/mutators of the form "get_BARENAME" and "set_BARENAME", where
BARENAME represents the option name provided in the specification without any
leading dashes.  E.g.

 %spec = { "--test|-t" => { type => "switch" } };
 $gl = Getopt::Long->getopt( \%spec );
 print $gl->get_test ? "True" : "False";
 $gl->set_test(1);

=head2 Managing Defaults and Config Files

DETAILS TO BE WRITTEN

=head2 Exceptions and Error Handling

DETAILS TO BE WRITTEN

=head2 Ambiguous Cases and Gotchas

I<One-character aliases and anycase>

  @spec = (
    Counter("verbose|v")->anycase,
    Switch("version|V")->anycase,
  );

Consider the spec above.  By specifying C<anycase> on these, "verbose",
"Verbose", "VERBOSE" are all acceptable, as are "version", "Version" and so on.
(Including long-form versions of these, too.)  However, what if the command
line has "-v" or even "-v -V"?  In this case, the rule is that exact case
matches are used before case-insensitive matches are searched.  Thus, "-v" can
only match "verbose", despite the C<anycase> modification, and likewise "-V"
can only match "version".

=head1 METHODS

=cut

#--------------------------------------------------------------------------#
# new()
#--------------------------------------------------------------------------#

=head2 C<new()>

 $opt = Getopt::Lucid->new( \@option_spec );
 $opt = Getopt::Lucid->new( \@option_spec, \@option_array );

Creates a new Getopt::Lucid object.  An array reference to an option spec is
required as an argument.  (See L<USAGE> for a description of the object spec).
By default, objects will be set to read @ARGV for command line options. An
optional second argument with a reference to an array will use that array for
option processing instead.  For typical cases, users will likely prefer
to call C<getopt> instead, which creates a new object and parses the command
line with a single function call.

=cut

sub new {
    my ($class, $spec, $target) = @_;
    throw_usage("Getopt::Lucid->new() requires an option specification array reference")
        unless ref($spec) eq 'ARRAY';
    my $self = bless ({}, ref($class) ? ref($class) : $class);
    _parse_spec($self, $spec);
    _set_defaults($self);
    $self->{options} = {};
    $self->{parsed} = [];
    $self->{seen}{$_} = 0 for keys %{$self->{spec}};
    $self->{target} = $target || \@ARGV;
    return $self;
}

#--------------------------------------------------------------------------#
# append_defaults()
#--------------------------------------------------------------------------#

=head2 C<append_defaults()>

 %options = append_defaults( %config_hash );
 %options = append_defaults( \%config_hash );

Takes a hash or hash reference of new default values, modifies the stored
defaults, recalculates the result of processing the command line with the
revised defaults, and returns a hash with the resulting options.  Each
key/value pair in the passed hash is added to the stored defaults.  For switch
and parameter options, the value in the passed hash will overwrite any
pre-existing value.  For counter options, the value is added to any
pre-existing value.  For list options, the value (or values, if the value is an
array reference) will be pushed onto the end of the list of existing values.
For keypair options, the keypairs will be added to the existing hash,
overwriting existing key/value pairs (just like merging two hashes).  Keys
which are not valid "barewords" derived from the options specification will be
ignored.

=cut

sub append_defaults {
	my $self = shift;
    my %append = 
        ref $_[0] eq 'HASH' ? %{+shift} : 
        (@_ % 2 == 0) ? @_ : 
        throw_usage("Argument to append_defaults() must be a hash or hash reference");
    for my $name ( keys %{$self->{spec}} ) {
        my $strip = $self->{strip}{$name};
        next unless exists $append{$strip};
        for ( $self->{spec}{$name}{type} ) {
            /switch|parameter/ && do { 
                $self->{default}{$strip} = $append{$strip};
                last;
            };
            /counter/ && do {
                $self->{default}{$strip} += $append{$strip};
                last;
            };
            /list/ && do {
                throw_usage("Option '$strip' in append_defaults() must be scalar or array reference")
                    if ref($append{$strip}) && ref($append{$strip}) ne 'ARRAY';
                $append{$strip} = ref($append{$strip}) eq 'ARRAY'
                    ? clone( $append{$strip} )
                    : [ $append{$strip} ] ;
                push @{$self->{default}{$strip}}, @{$append{$strip}};
                last;
            };
            /keypair/ && do {
                throw_usage("Option '$strip' in append_defaults() must be scalar or hash reference")
                    if ref($append{$strip}) && ref($append{$strip}) ne 'HASH';
                $self->{default}{$strip} = {
                    %{$self->{default}{$strip}},
                    %{$append{$strip}},
                };
                last;
            };
        }
    }
    _recalculate_options($self);
    return $self->options;
}

#--------------------------------------------------------------------------#
# defaults()
#--------------------------------------------------------------------------#

=head2 C<defaults()>

 %defaults = $opt->defaults();

Returns a hash containing current default values.  Keys are "bareword" names
from the option specification.  (i.e.  names without any leading dashes).  
These defaults represent the baseline values that are modified by the parsed
command line options.

=cut

sub defaults {
	my ($self) = @_;
	return %{clone($self->{default})};
}


#--------------------------------------------------------------------------#
# getopt()
#--------------------------------------------------------------------------#

=head2 C<getopt()>

 %options = $opt->getopt();
 $opt = Getopt::Lucid->getopt( \@option_spec );
 $opt = Getopt::Lucid->getopt( \@option_spec, \@option_array );

Parses the command line array (@ARGV by default).  When called as an object
method, it takes no arguments and returns a hash containing the options parsed.
When called as a class function, C<getopt> takes the same arguments as C<new>,
calls C<new> to create an object before parsing the command line, and returns
the new object.

=cut

sub getopt {
	my ($self,$spec,$target) = @_;
    my $return_self;
    if ( $self eq 'Getopt::Lucid' ) {
        $return_self = 1;
        throw_usage("Getopt::Lucid->getopt() requires an option specification array reference")
            unless ref($spec) eq 'ARRAY';
        $self = new($self,$spec,$target)
    }
    my (@passthrough);
    while (@{$self->{target}}) {
        my $raw = shift @{$self->{target}};
        last if $raw =~ /^--$/;
        my ($orig, $val) = _split_equals($self, $raw);
        next if _unbundle($self, $orig, $val);
        my $neg = $orig =~ s/^$NEGATIVE(.*)$/$1/ ? 1 : 0;
        my $arg = _find_arg($self, $orig);
        if ( $arg ) {
            $neg ?
                $self->{seen}{$arg} = 0 :
                $self->{seen}{$arg}++;
            for ($self->{spec}{$arg}{type}) { 
                /switch/    ? _switch   ($self, $arg, $val, $neg) :
                /counter/   ? _counter  ($self, $arg, $val, $neg) :
                /parameter/ ? _parameter($self, $arg, $val, $neg) :
                /list/      ? _list     ($self, $arg, $val, $neg) :
                /keypair/   ? _keypair  ($self, $arg, $val, $neg) :
                              throw_usage("can't handle type '$_'");
            } 
        } else {
            throw_argv("Invalid argument: $orig")
                if $orig =~ /^-./; # invalid if looks like it could be an arg;
            push @passthrough, $orig;
        }
    }
    _check_required($self);
    _check_prereqs($self);
    _recalculate_options($self);
    @{$self->{target}} = (@passthrough, @{$self->{target}});
    return $return_self ? $self : $self->options;
}


#--------------------------------------------------------------------------#
# merge_defaults()
#--------------------------------------------------------------------------#

=head2 C<merge_defaults()>

 %options = merge_defaults( %config_hash );
 %options = merge_defaults( \%config_hash );

Takes a hash or hash reference of new default values, modifies the stored
defaults, recalculates the result of processing the command line with the
revised defaults, and returns a hash with the resulting options.  Each
key/value pair in the passed hash is added to the stored defaults, overwriting
any pre-existing value.  Keys which are not valid "barewords" derived from the
options specification will be ignored.

=cut

sub merge_defaults {
	my $self = shift;
    my %merge = 
        ref $_[0] eq 'HASH' ? %{+shift} : 
        (@_ % 2 == 0) ? @_ : 
        throw_usage("Argument to merge_defaults() must be a hash or hash reference");
    for my $name ( keys %{$self->{spec}} ) {
        my $strip = $self->{strip}{$name};
        next unless exists $merge{$strip};
        for ( $self->{spec}{$name}{type} ) {
            /switch|counter|parameter/ && do { 
                $self->{default}{$strip} = $merge{$strip};
                last;
            };
            /list/ && do {
                throw_usage("Option '$strip' in merge_defaults() must be scalar or array reference")
                    if ref($merge{$strip}) && ref($merge{$strip}) ne 'ARRAY';
                $merge{$strip} = ref($merge{$strip}) eq 'ARRAY'
                    ? clone( $merge{$strip} )
                    : [ $merge{$strip} ] ;
                $self->{default}{$strip} = $merge{$strip};
                last;
            };
            /keypair/ && do {
                throw_usage("Option '$strip' in merge_defaults() must be scalar or hash reference")
                    if ref($merge{$strip}) && ref($merge{$strip}) ne 'HASH';
                $self->{default}{$strip} = clone($merge{$strip});
                last;
            };
        }
    }
    _recalculate_options($self);
    return $self->options;
}

#--------------------------------------------------------------------------#
# names()
#--------------------------------------------------------------------------#

=head2 C<names()>

 @names = $opt->names();

Returns the list of "bareword" names corresponding to the names in the options
specification.  Each name represents a key in the hash of options provided by
C<options>.

=cut

sub names {
	my ($self) = @_;
	return values %{$self->{strip}};
}


#--------------------------------------------------------------------------#
# options()
#--------------------------------------------------------------------------#

=head2 C<options()>

 %options = $opt->options();

Returns a deep copy of the options hash.  Before C<getopt> is called, its 
behavior is undefined.  After C<getopt> is called, this will return the
result of modifying the defaults with the results of command line processing.

=cut

sub options {
	my ($self) = @_;
    return %{clone($self->{options})};	
}

#--------------------------------------------------------------------------#
# replace_defaults()
#--------------------------------------------------------------------------#

=head2 C<replace_defaults()>

 %options = replace_defaults( %config_hash );
 %options = replace_defaults( \%config_hash );

Takes a hash or hash reference of new default values, replaces the stored
defaults, recalculates the result of processing the command line with the
revised defaults, and returns a hash with the resulting options.  Each
key/value pair in the passed hash replaces existing defaults, including those
given in the option specifications.  Keys which are not valid "barewords"
derived from the options specification will be ignored.

=cut

sub replace_defaults {
	my $self = shift;
    my %replace = 
        ref $_[0] eq 'HASH' ? %{+shift} : 
        (@_ % 2 == 0) ? @_ : 
        throw_usage("Argument to replace_defaults() must be a hash or hash reference");
    for my $name ( keys %{$self->{spec}} ) {
        my $strip = $self->{strip}{$name};
        for ( $self->{spec}{$name}{type} ) {
            /switch|counter/ && do { 
                $self->{default}{$strip} = $replace{$strip} || 0;
                last;
            };
            /parameter/ && do { 
                $self->{default}{$strip} = $replace{$strip} || "";
                last;
            };
            /list/ && do {
                throw_usage("Option '$strip' in replace_defaults() must be scalar or array reference")
                    if ref($replace{$strip}) && ref($replace{$strip}) ne 'ARRAY';
                if ( exists $replace{$strip} ) {
                    $replace{$strip} = ref($replace{$strip}) eq 'ARRAY' ? 
                                       $replace{$strip} : [ $replace{$strip} ];
                } else {
                    $replace{$strip} = [];
                }
                $self->{default}{$strip} = clone($replace{$strip});
                last;
            };
            /keypair/ && do {
                throw_usage("Option '$strip' in replace_defaults() must be scalar or hash reference")
                    if ref($replace{$strip}) && ref($replace{$strip}) ne 'HASH';
                $replace{$strip} = {} unless exists $replace{$strip};
                $self->{default}{$strip} = clone($replace{$strip});
                last;
            };
        }
    }
    _recalculate_options($self);
    return $self->options;
}

#--------------------------------------------------------------------------#
# reset_defaults()
#--------------------------------------------------------------------------#

=head2 C<reset_defaults()>

 %options = reset_defaults();

Resets the stored defaults to the original values from the options
specification, recalculates the result of processing the command line with the
restored defaults, and returns a hash with the resulting options.  This
undoes the effect of a C<merge_defaults> or C<add_defaults> call.

=cut

sub reset_defaults {
	my ($self) = @_;
    _set_defaults($self);	
    _recalculate_options($self);
    return $self->options;
}

#--------------------------------------------------------------------------#
# _check_prereqs()
#--------------------------------------------------------------------------#

sub _check_prereqs {
	my ($self) = @_;
	for my $key ( keys %{$self->{seen}} ) {
        next unless $self->{seen}{$key};
        next unless exists $self->{spec}{$key}{needs};
        for (@{$self->{spec}{$key}{needs}}) {
            throw_argv("Option '$self->{spec}{$key}{canon}' ".
                       "requires option '$self->{spec}{$_}{canon}'")
                unless $self->{seen}{$_};
        }
    }
}

#--------------------------------------------------------------------------#
# _check_required()
#--------------------------------------------------------------------------#

sub _check_required {
	my ($self) = @_;
    for ( keys %{$self->{spec}} ) {
        throw_argv("Required option '$self->{spec}{$_}{canon}' not found")
            if ( $self->{spec}{$_}{required} && ! $self->{seen}{$_} ); 
    }
}

#--------------------------------------------------------------------------#
# _counter()
#--------------------------------------------------------------------------#

sub _counter {
	my ($self, $arg, $val, $neg) = @_;
    throw_argv("Counter option can't take a value: $self->{spec}{$arg}{canon}=$val")
        if defined $val;
    push @{$self->{parsed}}, [ $arg, 1, $neg ];
}

#--------------------------------------------------------------------------#
# _find_arg()
#--------------------------------------------------------------------------#

sub _find_arg {
	my ($self, $arg) = @_;

    $arg =~ s/^-*// unless $STRICT;
    return $self->{alias_hr}{$arg} if exists $self->{alias_hr}{$arg}; 

    for ( keys %{$self->{alias_nocase}} ) {
        return $self->{alias_nocase}{$_} if $arg =~ /$_/i;
    }

    return undef;
}

#--------------------------------------------------------------------------#
# _keypair()
#--------------------------------------------------------------------------#

sub _keypair {
	my ($self, $arg, $val, $neg) = @_;
    my ($key, $data);
    if ($neg) {
        $key = $val;
    }
    else {
        my $value = defined $val ? $val : shift @{$self->{target}};
        throw_argv("Badly formed keypair for '$self->{spec}{$arg}{canon}'")
            unless $value =~ /[^=]+=.+/;
        ($key, $data) = ( $value =~ /^([^=]*)=(.*)$/ ) ;
        throw_argv("Invalid keypair '$self->{spec}{$arg}{canon}': $key => $data")
            unless _validate_value($self, { $key => $data }, 
                               $self->{spec}{$arg}{valid});    
    }
    push @{$self->{parsed}}, [ $arg, [ $key, $data ], $neg ];
}

#--------------------------------------------------------------------------#
# _list()
#--------------------------------------------------------------------------#

sub _list {
	my ($self, $arg, $val, $neg) = @_;
    my $value;
    if ($neg) {
        $value = $val;
    }
    else {
        $value = defined $val ? $val : shift @{$self->{target}};
        $value =~ s/^$NEGATIVE(.*)$/$1/ if ! defined $val;
        throw_argv("Ambiguous value for $self->{spec}{$arg}{canon} could be option: $value")
            if ! defined $val and _find_arg($self, $value);
        throw_argv("Invalid list option $self->{spec}{$arg}{canon} = $value")
            unless _validate_value($self, $value, $self->{spec}{$arg}{valid});    
    }
    push @{$self->{parsed}}, [ $arg, $value, $neg ];
}

#--------------------------------------------------------------------------#
# _parameter()
#--------------------------------------------------------------------------#

sub _parameter {
	my ($self, $arg, $val, $neg) = @_;
    my $value;
    if ($neg) {
        throw_argv("Negated parameter option can't take a value: $self->{spec}{$arg}{canon}=$val")
            if defined $val;
    }
    else {
        $value = defined $val ? $val : shift @{$self->{target}};
        $value =~ s/^$NEGATIVE(.*)$/$1/ if ! defined $val;
        throw_argv("Parameter can't be repeated: $self->{spec}{$arg}{canon}=$value")
            if $self->{seen}{$arg} > 1;
        throw_argv("Ambiguous value for $self->{spec}{$arg}{canon} could be option: $value")
            if ! defined $val and _find_arg($self, $value);
        throw_argv("Invalid parameter $self->{spec}{$arg}{canon} = $value")
            unless _validate_value($self, $value, $self->{spec}{$arg}{valid});    
    }
    push @{$self->{parsed}}, [ $arg, $value, $neg ];
}

#--------------------------------------------------------------------------#
# _parse_spec()
#--------------------------------------------------------------------------#

sub _parse_spec {
	my ($self,$spec) = @_;
    for my $opt ( @$spec ) {
        my $name = $opt->{name};
        my @names = split( /\|/, $name );
        $opt->{canon} = $names[0];
        _validate_spec($self,\@names,$opt);
        @names = map { s/^-*//; $_ } @names unless $STRICT;
        for (@names) {
            $self->{alias_hr}{$_} = $names[0];
            $self->{alias_nocase}{$_} = $names[0]  if $opt->{nocase};
        }
        $self->{spec}{$names[0]} = $opt;
        ($self->{strip}{$names[0]} = $names[0]) =~ s/^-+//;
    }
    _validate_prereqs($self);
}

#--------------------------------------------------------------------------#
# _recalculate_options()
#--------------------------------------------------------------------------#

sub _recalculate_options {
	my ($self) = @_;
    my %result;
    for ( keys %{$self->{default}} ) {
        my $x = $self->{default}{$_};
        $result{$_} = ref($x) eq 'ARRAY' ? [ @$x ] :
                      ref($x) eq 'HASH'  ? { %$x } : $x;
    }
    for my $opt ( @{$self->{parsed}} ) {
        my ($name, $value, $neg) = @$opt;
        for ($self->{spec}{$name}{type}) {
            my $strip = $self->{strip}{$name};
            /switch/    && do { 
                $result{$strip} = $neg ? 0 : $value; 
                last; 
            };
            /counter/   && do { 
                $result{$strip} = $neg ? 0 : $result{$strip} + $value; 
                last; 
            };
            /parameter/ && do { 
                $result{$strip} = $neg ? "" : $value; 
                last; 
            };
            /list/      && do { 
                if ($neg) {  
                    $result{$strip} = $value ? 
                        [ grep { $_ ne $value } @{$result{$strip}} ] :
                        []; 
                }
                else { push @{$result{$strip}}, $value }
                last; 
            };
            /keypair/   && do { 
                if ($neg) { 
                    if ($value->[0]) { delete $result{$strip}{$value->[0]} }
                    else { $result{$strip} = {} } 
                }
                else { $result{$strip}{$value->[0]} = $value->[1]}; 
                last; 
            };
        }
    }
    return $self->{options} = \%result;
}

#--------------------------------------------------------------------------#
# _regex_or_code
#--------------------------------------------------------------------------#

sub _regex_or_code {
    my ($value,$valid) = @_;
    return 1 unless defined $valid;
	if ( ref($valid) eq 'CODE' ) {
        local *_ = \$value;
        return $valid->($value);
    } else {
        return $value =~ /^$valid$/;
    }
}

#--------------------------------------------------------------------------#
# _set_defaults()
#--------------------------------------------------------------------------#

sub _set_defaults {
	my ($self) = @_;
    my %default;
    for ( keys %{$self->{spec}} ) {
        my $spec = $self->{spec}{$_};
        my $d = exists ($spec->{default}) ? $spec->{default} : undef;
        my $type = $self->{spec}{$_}{type};
        my $strip = $self->{strip}{$_};
        throw_spec("Default for list '$spec->{canon}' must be array reference")
            if ( $type eq "list" && defined $d && ref($d) ne "ARRAY" ); 
        throw_spec("Default for keypair '$spec->{canon}' must be hash reference")
            if ( $type eq "keypair" && defined $d && ref($d) ne "HASH" ); 
        $default{$strip} = do {
            local $_ = $type;
            /switch/    ?   (defined $d ? $d: 0)   :
            /counter/   ?   (defined $d ? $d: 0)   :
            /parameter/ ?   (defined $d ? $d: "")  : 
            /list/      ?   (defined $d ? clone($d): [])  :
            /keypair/   ?   (defined $d ? clone($d): {})  : 
                            undef;
        };
        throw_spec("Default '$spec->{canon}' = '$default{$strip}' fails to validate")
            unless _validate_value($self, $default{$strip}, $spec->{valid});
    }
    $self->{default} = \%default;
}

#--------------------------------------------------------------------------#
# _split_equals()
#--------------------------------------------------------------------------#

sub _split_equals {
	my ($self,$raw) = @_;
    my ($arg,$val);
    if ( $raw =~ /^($NEGATIVE?$VALID_NAME|$SHORT_BUNDLE)=(.*)/ ) {
        $arg = $1;
        $val = $2;
    } else {
        $arg = $raw;
    }
	return ($arg, $val);
}

#--------------------------------------------------------------------------#
# _switch()
#--------------------------------------------------------------------------#

sub _switch {
	my ($self, $arg, $val, $neg) = @_;
    throw_argv("Switch can't take a value: $self->{spec}{$arg}{canon}=$val")
        if defined $val;
    if (! $neg ) {
        throw_argv("Switch used twice: $self->{spec}{$arg}{canon}")
            if $self->{seen}{$arg} > 1;
    }
    push @{$self->{parsed}}, [ $arg, 1, $neg ];
}

#--------------------------------------------------------------------------#
# _unbundle()
#--------------------------------------------------------------------------#

sub _unbundle {
	my ($self,$arg, $val) = @_;
    if ( $arg =~ /^$SHORT_BUNDLE$/ ) { 
        my @flags = split(//,substr($arg,1));
        unshift @{$self->{target}}, ("-" . pop(@flags) . "=" . $val) 
            if defined $val; 
        for ( reverse @flags ) {
            unshift @{$self->{target}}, "-$_";
        }
        return 1;
    }
    return 0;
}

#--------------------------------------------------------------------------#
# _validate_prereqs()
#--------------------------------------------------------------------------#

sub _validate_prereqs {
    my ($self) = @_;
	for my $key ( keys %{$self->{spec}} ) {
        next unless exists $self->{spec}{$key}{needs};
        my $needs = $self->{spec}{$key}{needs};
        my @prereq = ref($needs) eq 'ARRAY' ? @$needs : ( $needs );
        for (@prereq) {
            throw_spec("Prerequisite '$_' for '$self->{spec}{$key}{canon}' is not recognized")
                unless _find_arg($self,$_);
            $_ = _find_arg($self,$_);
        }
        $self->{spec}{$key}{needs} = \@prereq;
    }   
}


#--------------------------------------------------------------------------#
# _validate_spec()
#--------------------------------------------------------------------------#

sub _validate_spec {
    my ($self,$names,$details) = @_;
    for my $name ( @$names ) {
        my $alt_name = $name;
        $alt_name =~ s/^-*// unless $STRICT;
        throw_spec(
            "'$name' is not a valid option name/alias" 
        ) unless $name =~ /^$VALID_NAME$/;
        throw_spec(
            "'$name' is not unique"
        ) if exists $self->{alias_hr}{$alt_name};
        my $strip;
        ($strip = $name) =~ s/^-+//;
        throw_spec(
            "'$strip' conflicts with other options"
        ) if grep { $strip eq $_ } values %{$self->{strip}};
    }
    for my $key ( keys %$details ) {
        throw_spec(
            "'$key' is not a valid option specification key"
        ) unless grep { $key eq $_ } @valid_keys;
    }
    my $type = $details->{type};
    throw_spec(
        "'$type' is not a valid option type"
    ) unless grep { $type eq $_ } @valid_types;
}

#--------------------------------------------------------------------------#
# _validate_value()
#--------------------------------------------------------------------------#

sub _validate_value {
	my ($self, $value, $valid) = @_;
    return 1 unless defined $valid;
    if ( ref($value) eq 'HASH' ) {
        my $valid_key = $valid->[0];
        my $valid_val = $valid->[1];
        while (my ($k,$v) = each %$value) {
            _regex_or_code($k, $valid_key) or return 0;
            _regex_or_code($v, $valid_val) or return 0;
        }
        return 1;
    } elsif ( ref($value) eq 'ARRAY' ) {
        for (@$value) {
            _regex_or_code($_, $valid) or return 0;
        }
        return 1;
    } else {
        return _regex_or_code($value, $valid);
    }
}

#--------------------------------------------------------------------------#
# AUTOLOAD()
#--------------------------------------------------------------------------#

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    my $name = $AUTOLOAD;
    $name =~ s/.*:://;   # strip fully-qualified portion
    return if $name eq "DESTROY";
    my ($action, $opt) = $name =~ /^(get|set)_(.+)/ ;
    if ($action) {
        throw_usage("Can't $action unknown option '$opt'")
            unless grep { $opt eq $_} values %{$self->{strip}};
        if ($action eq "set") {
            $self->{options}{$opt} = 
                ref($self->{options}{$opt}) eq 'ARRAY' ? [@_] :
                ref($self->{options}{$opt}) eq 'HASH'  ? {@_} : shift;

        }
        my $ans = $self->{options}{$opt};
        return ref($ans) eq 'ARRAY' ? @$ans :
               ref($ans) eq 'HASH'  ? %$ans : $ans;
    }
    my $super = "SUPER::$name";
    $self->$super(@_);
}

1; #this line is important and will help the module return a true value
__END__

=head1 SEE ALSO

=over

=item *

L<Getopt::Long>

=item * 

L<Config::Simple>

=back

=head1 INSTALLATION

The following commands will build, test, and install this module:

 perl Build.PL
 perl Build
 perl Build test
 perl Build install

=head1 BUGS

Please report bugs using the CPAN Request Tracker at 
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Getopt-Lucid

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

=cut
