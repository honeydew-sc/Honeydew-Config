use strict;
use warnings;
use Test::More;

BEGIN: {
unless (use_ok('Honeydew-Config')) {
BAIL_OUT("Couldn't load Honeydew-Config");
exit;
}
}



done_testing;
