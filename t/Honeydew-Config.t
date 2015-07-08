#! /usr/bin/perl

use strict;
use warnings;
use Test::Spec;
use Test::Fatal;
use Cwd qw/abs_path/;
use File::Basename qw/dirname/;
use File::Spec;

BEGIN: {
    unless (use_ok('Honeydew::Config')) {
        BAIL_OUT("Couldn't load Honeydew::Config");
        exit;
    }
}

describe 'Honeydew config' => sub {
    my ($config, $fixture_config_file);

    my $this_dir = dirname(abs_path( __FILE__ ));
    $fixture_config_file = File::Spec->catfile($this_dir, 'fixture-config.ini');

    before each => sub {
        $config = Honeydew::Config->new(
            file => $fixture_config_file
        );
    };

    it 'should die with an invalid config file ' => sub {
        ok( exception { my $bad_conf = Honeydew::Config->new(
            file => '/tmp/non-existent/'
        )} );
    };

    it 'should have a default file' => sub {
        my $default = '/opt/honeydew/honeydew.ini';
        `touch $default`;
        if (-e $default) {
            my $default_config = Honeydew::Config->new;
            is( $default_config->file, '/opt/honeydew/honeydew.ini' );
        }
    };

    it 'should group the configs by headers' => sub {
        ok( exists $config->{header} );
        ok( exists $config->{header2} );
    };

    it 'should put the configs under their proper header' => sub {
        is( $config->{header}->{key}, 'value' );
    };

    it 'should handle duplicate key names under different headers' => sub {
        is( $config->{header2}->{key}, 'value3' );
    };

    it 'should handle multiple keys under one header' => sub {
        is( $config->{header2}->{key}, 'value3' );
        is( $config->{header2}->{key3}, 'value4' );
    };

    describe 'directories' => sub {
        my @dirs = qw/sets features phrases/;

        foreach my $dir (@dirs) {
            it 'should figure out the ' . $dir . ' directory' => sub {
                my $method = $dir . '_dir';
                my $found_dir = $config->$method;
                is( $found_dir, File::Spec->catfile('/tmp/', $dir) );
            };
        }
    };

    describe 'flags header' => sub {
        it 'should know normal users are not testers' => sub {
            ok( ! $config->is_tester( 'beta-feature', 'normal-user' ) );
        };

        it 'should allow beta users to be testers' => sub {
            ok( $config->is_tester( 'beta-feature', 'beta-user') );
        };
    };

    describe 'redis server' => sub {
        my ($redis_cfg);
        before each => sub {
            $redis_cfg = Honeydew::Config->new(
                file => $fixture_config_file
            );
        };

        it 'should get a redis config string out for us' => sub {
            is( $redis_cfg->redis_addr, 'server:port' );
        };

    };

    describe 'mysql dsn' => sub {
        my ($cfg);
        before each => sub {
            $cfg = Honeydew::Config->new(
                file => $fixture_config_file
            );
        };

        it 'should construct a proper DSN for us' => sub {
            my @expected_dsn = (
                'DBI:mysql:database=database;host=host',
                'username',
                'password',
                { RaiseError => 1 }
            );

            is_deeply( [ $cfg->mysql_dsn ], \@expected_dsn );
        };

        # comment this out so it doesn't impact prereqs.
        # xit 'should create a valid dsn for DBI to use' => sub {
        #     require DBI;
        #     my $exception = exception { my $dbh = DBI->connect( $cfg->mysql_dsn ) };
        #     like( $exception, qr/Unknown MySQL server host 'host'/ );
        # };
    };

};

runtests;
