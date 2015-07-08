package Honeydew::Config;
$Honeydew::Config::VERSION = '0.05';
# ABSTRACT: A config singleton for Honeydew
use strict;
use warnings;
use Moo;
use File::Spec;

with 'MooX::Singleton';



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


sub phrases_dir {
    my ($self) = @_;

    return $self->honeydew_dir( 'phrases' );
}

sub features_dir {
    my ($self) = @_;

    return $self->honeydew_dir( 'features' );
}

sub sets_dir {
    my ($self) = @_;

    return $self->honeydew_dir( 'sets' );
}

sub honeydew_dir {
    my ($self, $dir) = @_;

    my $basedir = $self->{honeydew}->{basedir};

    return File::Spec->catfile( $basedir, $dir );
}


sub is_tester {
    my ($self, $flag, $user) = @_;
    $user ||= 'nobody';

    return 1 if $self->{flags}->{$flag} eq 'all';
    my @beta_users = split(/\s*,\s*/, $self->{flags}->{$flag});

    return grep { $_ eq $user } @beta_users;
}


sub redis_addr {
    my ($self) = @_;
    my ($server, $port) = ($self->{redis}->{redis_server}, $self->{redis}->{redis_port});

    return "$server:$port";
}


sub mysql_dsn {
    my ($self) = @_;

    my ($db_settings) = $self->{mysql};

    my @dsn = (
        "DBI:mysql:database=" . $db_settings->{database} . ";host=" . $db_settings->{host},
        $db_settings->{username},
        $db_settings->{password},
        { RaiseError => 1 }
    );

    return @dsn;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Honeydew::Config - A config singleton for Honeydew

=for markdown [![Build Status](https://travis-ci.org/honeydew-sc/Honeydew-Config.svg?branch=master)](https://travis-ci.org/honeydew-sc/Honeydew-Config)

=head1 VERSION

version 0.05

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

=head1 ATTRIBUTES

=head2 file

Defaults to C</opt/honeydew/honeydew.ini>, but you can point this
module to any C<ini> file by using this attribute during start
up. Since this is a singleton, we strongly discourage you from
changing it after construction.

=head1 METHODS

=head2 features_dir

=head2 sets_dir

=head2 phrases_dir

Specify where the Honeydew features/sets/phrases are located. This
uses C<$config->{honeydew}->{basedir}> and appends the appropriate
directory name to it. In your inifile, you might do

    [honeydew]
    basedir=/opt/honeydew

And that would result in a C<sets_dir> of C</opt/honeydew/sets>, and
analogous directories for features and phrases.

=head2 is_tester

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

=head2 redis_addr

A convenience method that concatenates the C<redis_server> and
C<redis_port> in the C<redis> group.

=head2 mysql_dsn

A convenience method for constructing the dsn for a MySQL database
connection. It uses the following values from the C<[mysql]> section
of the config file to construct the dsn.

    [mysql]
    host=host_address
    database=database
    username=username
    password=password

would create a dsn like

    (
        'DBI:mysql:database=database;host=host',
        'username',
        'password',
        { RaiseError => 1 }
    )

Usage looks like:

    my $config = Honeydew::Config->instance;
    my $dbh = DBI->connect( $config->dsn );

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/honeydew-sc/Honeydew-Config/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Daniel Gempesaw.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
