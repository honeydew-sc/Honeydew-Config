package Honeydew::Config;

# ABSTRACT: A config singleton for Honeydew
use strict;
use warnings;
use Moo;
with 'MooX::Singleton';

=for markdown [![Build Status](https://travis-ci.org/gempesaw/Honeydew-Config.svg?branch=master)](https://travis-ci.org/gempesaw/Honeydew-Config)

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

sub is_tester {
    my ($self, $flag, $user) = @_;
    $user ||= 'nobody';

    return 1 if $self->{$flag} eq 'all';
    my @beta_users = split(/\s*,\s*/, $self->{$flag});

    return grep { $_ eq $user } @beta_users;
}

1;
