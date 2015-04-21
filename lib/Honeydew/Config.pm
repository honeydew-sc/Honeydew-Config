package Honeydew::Config;

# ABSTRACT: A config singleton for Honeydew
use strict;
use warnings;
use Moo;
with 'MooX::Singleton';

=for markdown [![Build Status](https://travis-ci.org/honeydew-sc/Honeydew-Config.svg?branch=master)](https://travis-ci.org/honeydew-sc/Honeydew-Config)

=head1 SYNOPSIS

=head1 DESCRIPTION

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

    my $group;
    foreach (@file) {
        chomp;
        ($group) = ($_ =~ /\[(.*)\]/) if $_ =~ /^\[/;
        next() if $_ =~ /^\s*#/ or $_ !~ /=/;

        my ($name, $value) = split(/\s*=\s*/, $_);
        $self->{$group}->{$name} = $value;
        $self->{$name} = $value;
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

1;
