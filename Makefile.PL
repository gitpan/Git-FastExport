
# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v5.016.
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A module to parse the output of git-fast-export",
  "AUTHOR" => "Philippe Bruhat (BooK) <book\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Git-FastExport",
  "EXE_FILES" => [
    "script/git-stitch-repo"
  ],
  "LICENSE" => "perl",
  "NAME" => "Git::FastExport",
  "PREREQ_PM" => {
    "Carp" => 0,
    "File::Basename" => 0,
    "File::Spec::Functions" => 0,
    "Getopt::Long" => 0,
    "Git::Repository" => 0,
    "List::Util" => 0,
    "Pod::Usage" => 0,
    "Scalar::Util" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Cwd" => 0,
    "File::Path" => 0,
    "File::Spec" => 0,
    "File::Temp" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::Git" => 0,
    "Test::More" => "0.88",
    "Test::Script" => "1.05"
  },
  "VERSION" => "0.105",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "Cwd" => 0,
  "File::Basename" => 0,
  "File::Path" => 0,
  "File::Spec" => 0,
  "File::Spec::Functions" => 0,
  "File::Temp" => 0,
  "Getopt::Long" => 0,
  "Git::Repository" => 0,
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "List::Util" => 0,
  "Pod::Usage" => 0,
  "Scalar::Util" => 0,
  "Test::Git" => 0,
  "Test::More" => "0.88",
  "Test::Script" => "1.05",
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



