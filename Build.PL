use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Class::Tie::InsideOut',
     license => 'perl',
     requires => {
       'perl'             => '5.6.1',
     },
     recommends => {
       'Pod::Readme'      => 0.06,
     },
     build_requires => {
       'Test::More'     => 0,
     },
     create_readme      => ($Module::Build::VERSION >= 0.2702),
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
     sign               => 1,
);

$build->create_build_script;

