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

    describe 'flags header' => sub {
        it 'should know normal users are not testers' => sub {
            ok( ! $config->is_tester( 'beta-feature', 'normal-user' ) );
        };

        it 'should allow beta users to be testers' => sub {
            ok( $config->is_tester( 'beta-feature', 'beta-user') );
        };
    };


};

runtests;
