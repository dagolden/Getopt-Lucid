use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name     => 'Getopt::Lucid',
    dist_author => 'David A Golden <dagolden@cpan.org>', 
    create_makefile_pl => "traditional",
    create_readme => 0,
    license         => 'perl',
    requires => {
        perl => 5.005,
        Exception::Class => 1.20,
        Storable => 2,
        # build requires:
        Data::Dumper => 0,
        Exception::Class::TryCatch => 1.10, 
        Test::More => 0.45, 
    },
)->create_build_script;
