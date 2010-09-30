use strict;
use warnings;
use Test::More;
use Test::MockObject;

use lib 't/lib';
BEGIN { $ENV{SGN_SKIP_CGI} = 1 }
use SGN::Test 'ctx_request';
use SGN::Test::WWW::Mechanize;

BEGIN { use_ok 'SGN::View::Email::ErrorEmail' }

my $mech = SGN::Test::WWW::Mechanize->new;
$mech->with_test_level( process => sub {

    my ($res, $c) = ctx_request('/');
    $c->stash->{email_errors} = [ 'Fake test error!' ];
    my $body = $c->view('Email::ErrorEmail')->_email_body( $c );

    like( $body, qr/object skipped/, 'email body looks right' );
    like( $body, qr/=== Request ===/, 'email body looks right' );

});

done_testing();
