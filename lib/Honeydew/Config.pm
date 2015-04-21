package Honeydew::Config;

# ABSTRACT: A config singleton for Honeydew
use strict;
use warnings;
use Moo;
with 'MooX::Singleton';

=for markdown [![Build Status](https://travis-ci.org/honeydew-sc/Honeydew-Config.svg?branch=master)](https://travis-ci.org/honeydew-sc/Honeydew-Config)

=head1 SYNOPSIS

In config.ini:

    [passwords]
    a=b
    c=d

In App.pm:

    use Honeydew::Config;

    my $config = Honeydew::Config->instance( file => 'config.ini' );
    print $config->{passwords}->{a}; # 'b'

=head1 DESCRIPTION

A simple config singleton - it will read in a configuration file as
described by L</file>. There's also the option to use config/feature
flags & toggles, if your app needs them.

Note that only groups are stored at the top level, and the default
group is C<"">, an empty string.

=cut

=attr file

Defaults to C</opt/honeydew/honeydew.ini>, but you can point this
module to any C<ini> file by using this attribute during start
up. Since this is a singleton, we strongly discourage you from
changing it after construction.

=cut

has 'file' => (
    is => 'ro',
    required => 1,
    default => '/opt/honeydew/honeydew.ini'
);

has 'channel' => (
    is => 'rw',
    lazy => 1,
    default => ''
);

sub BUILD {
    my $self = shift;

    open (my $fh, '<', $self->file) or die 'There\'s no config file at \'' . $self->file . '\'. Put one there, or tell me where to find it!';
    my (@file) = <$fh>;
    close ($fh);

    my $group = "";
    foreach (@file) {
        chomp;
        # Figure out what group we're in and hold on to it until it's overwritten
        ($group) = ($_ =~ /\[(.*)\]/) if $_ =~ /^\[/;
        next() if $_ =~ /^\s*#/ or $_ !~ /=/;

        my ($name, $value) = split(/\s*=\s*/, $_);
        $self->{$group}->{$name} = $value;
    }
}

=method is_tester

One header is treated specially:

    [flags]
    feature=flags
    can=go,here

If you'd like to put your config flags in a section with the header
C<flags>, you can use this function to test whether a user qualifies
to use the feature described by the flag. With the above setup, the
following would work:

    $config->is_tester('feature', 'flags'); # true
    $config->is_tester('can', 'go'); # true
    $config->is_tester('can', 'here'); # true

    $config->is_tester('feature', 'normal-user'); # false

=cut

sub is_tester {
    my ($self, $flag, $user) = @_;
    $user ||= 'nobody';

    return 1 if $self->{flags}->{$flag} eq 'all';
    my @beta_users = split(/\s*,\s*/, $self->{flags}->{$flag});

    return grep { $_ eq $user } @beta_users;
}

=method redis_addr

A convenience method that concatenates the C<redis_server> and
C<redis_port> in the C<redis> group.

=cut

sub redis_addr {
    my ($self) = @_;
    my ($server, $port) = ($self->{redis}->{redis_server}, $self->{redis}->{redis_port});

    return "$server:$port";
}

1;
