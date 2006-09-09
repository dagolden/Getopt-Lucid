use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name     => 'Getopt::Lucid',
    dist_author => 'David A Golden <dagolden@cpan.org>', 
    create_makefile_pl => "traditional",
    create_readme => 1,
    license         => 'perl',
    requires => {
        perl => 5.006,
        Clone::Any => 1.01,
        Exception::Class => 1.20,
    },
    build_requires => {
        Exception::Class::TryCatch => 1.05,
        Test::Exception => 0.20,
        Test::More => 0.47, 
    },
    recommends => {},
    conflicts => {},
)->create_build_script;
