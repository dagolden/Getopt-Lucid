use 5.006;
use strict;
use lib 'inc';
eval "require Pod::WikiDoc";
my $class = $@ ? "Module::Build" : "Module::Build::WikiDoc";
eval "require $class";
$class->new( 
    module_name         => 'Getopt::Lucid',
    dist_author         => 'David A. Golden <dagolden@cpan.org>',
    license             => 'apache',
    create_readme       => 1,
    create_makefile_pl  => 'traditional',
    requires => {
        'perl' => 5.006,
        'Carp' => 0,
        'Exception::Class' => 1.23,
        'Exporter' => 0,
        'Storable' => 2.16, # 2.15 in perl 5.008008; 
    },
    build_requires => {
        'Data::Dumper' => 0,
        'Exception::Class::TryCatch' => 1.10,
        'Test::More' => 0.62, # 0.47 in perl 5.006002; 0.62 in perl 5.008008; 
    },
    meta_merge            => { 
        no_index => { 
            directory => [ qw{
                examples
                inc
            }],
        },
        resources => {
            repository => 'http://github.com/dagolden/getopt-lucid/'
        },
    },
)->create_build_script;

