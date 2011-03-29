package SGN::Controller::Biosource::API;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

sub api_base : Chained('/') PathPart('api/v1/biosource') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->user_exists && $c->user->has_role('curator')
       or $c->throw(
           is_client_error => 1,
           http_status     => 403,
           public_message  => 'Site curator login required',
         );

}

1;
