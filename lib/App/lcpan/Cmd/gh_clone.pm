package App::lcpan::Cmd::gh_clone;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::Any::IfLOG '$log';

require App::lcpan;
require App::lcpan::Cmd::dist_meta;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => 'Clone github repo of a dist',
    args => {
        %App::lcpan::common_args,
        %App::lcpan::dist_args,
        as => {
            schema => 'dirname*',
        },
    },
};
sub handle_cmd {
    my %args = @_;
    my $dist = $args{dist};

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my $res = App::lcpan::Cmd::dist_meta::handle_cmd(%args);
    return [412, $res->[1]] unless $res->[0] == 200;
    my $meta = $res->[2];

    unless ($meta->{resources} && $meta->{resources}{repository} && $meta->{resources}{repository}{type} eq 'git') {
        return [412, "No git repository specified in the distmeta's resources"];
    }
    my $url = $meta->{resources}{repository}{url};
    unless ($url =~ m!^https?://github\.com!i) {
        return [412, "Git repository is not on github ($url)"];
    }

    require IPC::System::Options;
    IPC::System::Options::system({log=>1, die=>1}, "git", "clone", $url,
                                 ( defined $args{as} ? ($args{as}) : ()));
    [200];
}

1;
# ABSTRACT:
