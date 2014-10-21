use strict;
use warnings;
use File::Path;
use File::Spec;
use Cwd;
use Git;
use Error qw( :try );

# some data for the file content
my @data = <DATA>;
my $idx  = 0;

# Git.pm options for silencing git
my $gitopts = { STDERR => '' };

1;

sub description_of {

    # interpolate with comma's in this scope
    local $" = ', ';

    # silence screaming about undefined values
    no warnings 'uninitialized';

    my @desc;
    for my $v (@_) {
        push @desc,
            !defined $v ? '<undef>'
            : $v     eq ''      ? "''"
            : ref $v eq 'ARRAY' ? "[ @$v ]"
            : ref $v eq 'HASH'  ? "{ @{[map{qq'$_ => $v->{$_}'}sort keys%$v]} }"
            : $v;
    }

    return "@desc";
}

# create a new, empty repository
sub new_repo {
    my ( $dir, $name ) = @_;
    my $cwd = getcwd;

    # alas, this can't be done with Git.pm
    my $wc = File::Spec->rel2abs( File::Spec->catfile( $dir, $name ) );
    mkpath $wc;
    chdir $wc;
    `git init`;
    chdir $cwd;
    my $repo = Git->repository( Directory => $wc );
    $repo->command( [qw( config user.email test@example.com )], $gitopts );
    $repo->command( [qw( config user.name  Test )],             $gitopts );
    return $repo;
}

# produce a text description of a given repository
sub repo_description {
    my ($repo) = @_;
    my %log;    # map sha1 to log message
    my @commits;

    # process the whole tree
    my ( $fh, $c )
        = $repo->command_output_pipe( 'log', '--pretty=format:%H-%P-%s',
        '--date-order', '--all' );
    while (<$fh>) {
        chomp;
        my ( $h, $p, $log ) = split /-/, $_, 3;
        $log{$h} = $log;
        $p =~ y/ //d;
        push @commits, $p ? "$log-$p" : $log;
    }
    $repo->command_close_pipe( $fh, $c );

    # replace SHA-1 by log name
    my $desc = join ' ', reverse @commits;
    $desc =~ s/(\w{40})/$log{$1}/g;

    return $desc;
}

# split a description into descriptions of independent repositories
sub split_description {
    my ($desc) = @_;
    my %desc;

    for my $node ( split / /, $desc ) {
        my ($repo) = $node =~ /^([A-Z]+)/;
        push @{ $desc{$repo} }, $node;
    }
    return map { join ' ', @$_ } values %desc;
}

# create a set of repositories from a given description
sub create_repos {
    my ( $dir, $desc, $refs ) = @_;
    my $info = { dir => $dir, repo => {}, sha1 => {} };

    for my $commit ( split / /, $desc ) {
        my ( $child, $parent ) = split /-/, $commit;
        my @child = $child =~ /([A-Z]+\d+)/g;
        my @parent = $parent =~ /([A-Z]+\d+)/g if $parent;

        die "bad node description" if @child > 1 && @parent > 1;

        if ( @child > 1 ) {    # branch point
            create_linear_commit( $info, $_, $parent[0] ) for @child;
        }
        elsif ( @parent > 1 ) {    # merge point
            create_merge_commit( $info, $child[0], @parent );
        }
        else {                     # simple, linear commit
            create_linear_commit( $info, $child[0], $parent[0] );
        }
        sleep 1;
    }

    # checkout a new dummy branch in each repo
    for my $repo ( values %{ $info->{repo} } ) {
        $repo->command( [ 'checkout', '-b', 'dummy' ], $gitopts );
    }

    # setup the refs (branches & tags)
    for my $ref ( split / /, $refs ) {
        my ( $name, $type, $commit ) = split /([>=])/, $ref;
        my ($repo_name) = $commit =~ /^([A-Z]+)/;
        my $repo = $info->{repo}{$repo_name};
        if ( $type eq '=' ) {    # branch
            $repo->command( [ branch => '-D', $name ], $gitopts )
                if grep {/^..$name$/} $repo->command('branch');
            $repo->command( [ branch => $name, $info->{sha1}{$commit} ],
                $gitopts );
        }
        else {                   # tag
            $repo->command( [ tag => $name, $info->{sha1}{$commit} ],
                $gitopts );
        }
    }

    # delete the dummy branch and checkout master in each repo
    for my $repo ( values %{ $info->{repo} } ) {
        $repo->command( [ 'checkout', 'master' ], $gitopts );
        $repo->command( [ branch => '-D', 'dummy' ], $gitopts );
    }

    # return the repository objects
    return map { $info->{repo}{$_} } sort keys %{ $info->{repo} };
}

sub create_linear_commit {
    my ( $info, $child, $parent ) = @_;
    my ($name) = $child =~ /^([A-Z]+)/g;

    # create the repo if needed
    my $repo = $info->{repo}{$name};
    if ( !$repo ) {
        $repo = $info->{repo}{$name} = new_repo( $info->{dir} => $name );
    }

    # checkout the parent commit
    $repo->command( 'checkout', '-q', $info->{sha1}{$parent} ) if $parent;
    my $base = File::Spec->catfile( $info->{dir}, $name );
    update_file( $base, $name );
    $repo->command( 'add', $name );
    $repo->command( 'commit', '-m', $child );
    $info->{sha1}{$child}
        = $repo->command_oneline(qw( log -n 1 --pretty=format:%H HEAD ));
}

sub create_merge_commit {
    my ( $info, $child, @parents ) = @_;
    my ($name) = $child =~ /^([A-Z]+)/g;
    my $repo = $info->{repo}{$name};

    # checkout the first parent
    my $parent = shift @parents;
    $repo->command( 'checkout', '-q', $info->{sha1}{$parent} );

    # merge the other parents
    $repo->command_noisy( 'merge', '-n', '-s', 'ours', '-m', $child,
        map { $info->{sha1}{$_} } @parents,
    );

    $info->{sha1}{$child}
        = $repo->command_oneline(qw( log -n 1 --pretty=format:%H HEAD ));
}

sub update_file {
    my ($file) = File::Spec->catfile(@_);
    open my $fh, '>', $file or die "Can't open $file: $!";
    print $fh $data[ $idx++ % @data ];
    close $fh;
}

__DATA__
aieee
aiieee
awk
awkkkkkk
bam
bang
bang_eth
bap
biff
bloop
blurp
boff
bonk
clange
clank
clank_est
clash
clunk
clunk_eth
crash
crr_aaack
crraack
cr_r_a_a_ck
crunch
crunch_eth
eee_yow
flrbbbbb
glipp
glurpp
kapow
kayo
ker_plop
ker_sploosh
klonk
krunch
ooooff
ouch
ouch_eth
owww
pam
plop
pow
powie
qunckkk
rakkk
rip
slosh
sock
spla_a_t
splatt
sploosh
swa_a_p
swish
swoosh
thunk
thwack
thwacke
thwape
thwapp
touche
uggh
urkk
urkkk
vronk
whack
whack_eth
wham_eth
whamm
whap
zam
zamm
zap
zapeth
zgruppp
zlonk
zlopp
zlott
zok
zowie
zwapp
z_zwap
zzzzzwap
