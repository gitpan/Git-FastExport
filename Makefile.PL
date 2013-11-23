
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A module to parse the output of git-fast-export",
  "AUTHOR" => "Philippe Bruhat (BooK) <book\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Cwd" => 0,
    "File::Find" => 0,
    "File::Path" => 0,
    "File::Spec" => 0,
    "File::Temp" => 0,
    "Test::Git" => 0,
    "Test::More" => "0.88",
    "Test::Script" => "1.05"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Git-FastExport",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Git::FastExport",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Git::Repository" => 0,
    "List::Util" => 0,
    "Scalar::Util" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.101",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



