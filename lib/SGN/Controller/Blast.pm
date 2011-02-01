package SGN::Controller::Blast;

=head1 NAME

SGN::Controller::Blast - Catalyst controller for pages dealing with features

=cut

use Moose;
use namespace::autoclean;

use HTML::FormFu;
use URI::FromHash 'uri';
use YAML::Any;
use 5.010;

BEGIN { extends 'Catalyst::Controller' }
with 'Catalyst::Component::ApplicationAttribute';

sub view :Path('/blast/') Args(0) {
    my ( $self, $c, @args ) = @_;
    $c->stash->{template} = "/blast/index.mas";
}

__PACKAGE__->meta->make_immutable;
