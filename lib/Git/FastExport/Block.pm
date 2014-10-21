package Git::FastExport::Block;
{
  $Git::FastExport::Block::VERSION = '0.101';
}

use strict;
use warnings;

my $LF = "\012";

my %fields = (
    commit     => [qw( mark author committer data from merge files )],
    tag        => [qw( from tagger data )],
    reset      => [qw( from )],
    blob       => [qw( mark data )],
    checkpoint => [],
    progress   => [],
    feature    => [],
    option     => [],
);

'progress 1 objects';

sub as_string {
    my ($self) = @_;
    my $string = $self->{header} . $LF;

    for my $key ( @{ $fields{ $self->{type} } } ) {
        next if !exists $self->{$key};
        if ( $key eq 'data' ) {
            $string
                .= 'data ' . length( $self->{data} ) . $LF . $self->{data};
        }
        else {
            $string .= "$_$LF" for @{ $self->{$key} };
        }
    }
    return $string .= $self->{footer} || '';
}



=pod

=head1 NAME

Git::FastExport::Block - A block in a fast-export stream

=head1 VERSION

version 0.101

=head1 SYNOPSIS

This package is used internally by L<Git::FastExport>.

=head1 DESCRIPTION

L<Git::FastExport::Block> represents blocks from a B<git fast-export>
stream.

Internally, it is a simple hash with keys pointing either to a string
or a reference to an array of strings, which makes it very
easing to edit (when obtained via L<Git::FastExport> C<next_block()>
method) or create blocks in a B<git fast-export> stream.

The following two keys are pointing to strings:

=over 4

=item *

header

first line of the block

=item *

data

content of the block data section

=back

All the other keys are pointing to references to arrays of strings
(each string representing a line in the B<fast-export> stream:

=over 4

=item *

mark

=item *

author

=item *

commiter

=item *

from

=item *

merge

=item *

files

=item *

tagger

=back

Of course, which keys are present depend on the type of the block,
which is conveniently stored in the C<type> key.

All other keys are ignored.

=head1 METHODS

A L<Git::FastExport::Block> structure is meant to be used as a hash,
and is not protected by an accessor/mutator interface.
Or a constructor.

However, the module provides a method for outputing blocks:

=over 4

=item as_string()

Return the block as a string suitable for B<git fast-import>.

=back

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Git-FastExport or by email to
bug-git-fastexport@rt.cpan.org.

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Philippe Bruhat (BooK) <book@cpan.org>

=head1 ACKNOWLEDGEMENTS

The original version of this module was created as part of my work
for BOOKING.COM, which authorized its publication/distribution
under the same terms as Perl itself.

=head1 COPYRIGHT

Copyright 2008-2013 Philippe Bruhat (BooK), All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


__END__

# ABSTRACT: A block in a fast-export stream

