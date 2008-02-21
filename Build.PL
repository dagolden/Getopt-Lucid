use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name     => 'Getopt::Lucid',
    dist_author => 'David A Golden <dagolden@cpan.org>', 
    create_makefile_pl => "traditional",
    create_readme => 1,
    license         => 'perl',
    requires => {
        'perl' => 5.006,
        'Carp' => 0,
        'Exception::Class' => 1.2,
        'Exporter' => 0,
        'Getopt::Lucid::Exception' => 0.16,
        'Storable' => 2.18, # 2.15 in perl 5.008008; 
    },
    build_requires => {
        'Data::Dumper' => 0,
        'Exception::Class::TryCatch' => 1.10,
        'Test::More' => 0.62, # 0.47 in perl 5.006002; 0.62 in perl 5.008008; 0.74 is new
    },
)->create_build_script;
