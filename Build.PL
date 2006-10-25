use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Class::Tie::InsideOut',
     license => 'perl',
     requires => {
       'perl'             => '5.6.1',
       'Carp'             => 0,
       'Scalar::Util'     => 0,
     },
     recommends => {
#       'Class::Accessor'  => 0,              # for tests
       'Pod::Readme'      => 0.06,           # for building distro
       'Storable'         => 0,              # for tests, cloning interface
     },
     build_requires => {
       'Test::More'     => 0,
     },
     create_readme      => ($Module::Build::VERSION >= 0.2702),
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
     sign               => 0,
     keywords           => [
       "inside-out objects",
       "moebius objects",
       "tied hashes",
     ],
     resources          => {
       license          => 'http://dev.perl.org/licenses/',
       bugtracker       => 'http://rt.cpan.org/Public/Dist/Display.html?Name=Class-Tie-InsideOut',
     },
);

$build->create_build_script;

