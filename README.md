# NAME

Honeydew::Config - A config singleton for Honeydew

[![Build Status](https://travis-ci.org/honeydew-sc/Honeydew-Config.svg?branch=master)](https://travis-ci.org/honeydew-sc/Honeydew-Config)

# VERSION

version 0.05

# SYNOPSIS

In config.ini:

    [passwords]
    a=b
    c=d

In App.pm:

    use Honeydew::Config;

    my $config = Honeydew::Config->instance( file => 'config.ini' );
    print $config->{passwords}->{a}; # 'b'

# DESCRIPTION

A simple config singleton - it will read in a configuration file as
described by ["file"](#file). There's also the option to use config/feature
flags & toggles, if your app needs them.

Note that only groups are stored at the top level, and the default
group is `""`, an empty string.

# ATTRIBUTES

## file

Defaults to `/opt/honeydew/honeydew.ini`, but you can point this
module to any `ini` file by using this attribute during start
up. Since this is a singleton, we strongly discourage you from
changing it after construction.

# METHODS

## features\_dir

## sets\_dir

## phrases\_dir

Specify where the Honeydew features/sets/phrases are located. This
uses `$config-`{honeydew}->{basedir}> and appends the appropriate
directory name to it. In your inifile, you might do

    [honeydew]
    basedir=/opt/honeydew

And that would result in a `sets_dir` of `/opt/honeydew/sets`, and
analogous directories for features and phrases.

## is\_tester

One header is treated specially:

    [flags]
    feature=flags
    can=go,here

If you'd like to put your config flags in a section with the header
`flags`, you can use this function to test whether a user qualifies
to use the feature described by the flag. With the above setup, the
following would work:

    $config->is_tester('feature', 'flags'); # true
    $config->is_tester('can', 'go'); # true
    $config->is_tester('can', 'here'); # true

    $config->is_tester('feature', 'normal-user'); # false

## redis\_addr

A convenience method that concatenates the `redis_server` and
`redis_port` in the `redis` group.

## mysql\_dsn

A convenience method for constructing the dsn for a MySQL database
connection. It uses the following values from the `[mysql]` section
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

# BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/honeydew-sc/Honeydew-Config/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Daniel Gempesaw.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
