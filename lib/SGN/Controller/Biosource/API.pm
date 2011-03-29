package SGN::Controller::Biosource::API;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

sub api_base : Chained('/') PathPart('api/v1/biosource') CaptureArgs(0) {

}

1;
