package SGN::Controller::Blast;

=head1 NAME

SGN::Controller::Blast - Catalyst controller for pages dealing with features

=cut

use Moose;
use namespace::autoclean;
use Data::Dumper;

use HTML::FormFu;
use URI::FromHash 'uri';
use YAML::Any;
use 5.010;

BEGIN { extends 'Catalyst::Controller' }
with 'Catalyst::Component::ApplicationAttribute';

sub view :Path('/blast/') Args(0) {
    my ( $self, $c, @args ) = @_;

    my $form = $self->_build_form();
    warn Dumper [ $form ];

    $c->forward_to_mason_view(
        '/blast/index.mas',
        form => $form,
    );
}

sub _build_form {
    my ($self) = @_;

    my $form = HTML::FormFu->new(Load(<<EOY));
      method: POST
      attributes:
        name: blast_form
        id: blast_form
      elements:
          - type: Select
            name: blast_program
            label: Program

          - type: Text
          - name: expect_threshold
          - name: Expect Threshold (e-value)

          - type: Select
            name: sequence_set
            label: Sequence Set

          - type: Submit
            name: submit
EOY

    return $form;
}

__PACKAGE__->meta->make_immutable;
