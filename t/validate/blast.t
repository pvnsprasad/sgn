=head1 NAME

t/integration/blast.t - validation tests /blast/

=head1 DESCRIPTION

Tests for blast.

=head1 AUTHORS

Jonathan "Duke" Leto

=cut

use Modern::Perl;
use lib 't/lib';
use Test::More;
use SGN::Test::WWW::Mechanize;

use SGN::Test qw/validate_urls/;

my $base_url = $ENV{SGN_TEST_SERVER};
my $url      = "/blast/";

my $mech = SGN::Test::WWW::Mechanize->new;

validate_urls({
    'blast index' => $url,
});

done_testing;
