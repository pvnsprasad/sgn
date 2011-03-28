package SGN::Controller::Biosource;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use CXGN::GEM::Target;

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash(
        schema => $c->dbic_schema('CXGN::Biosource::Schema','sgn_chado'),
      );
}

sub get_sample : Chained('/') PathPart('biosource/sample') CaptureArgs(1) {
    my ( $self, $c, $sample_id ) = @_;

    my $new_method = $sample_id =~ /\D/ ? 'new_by_name' : 'new';
    $c->stash->{sample} = CXGN::Biosource::Sample->$new_method( $c->stash->{schema}, $sample_id )
        or $c->throw_404('sample not found');
}

sub sample_detail : Chained('get_sample') PathPart('details') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('get_expression_targets_for_sample');

    $c->stash(
        sample_relations_href => { $c->stash->{sample}->get_relationship     },
        pub_list              => [ $c->stash->{sample}->get_publication_list ],

        template              => '/biosource/sample_detail.mas',
        );
}

sub get_expression_targets_for_sample : Private {
    my ( $self, $c ) = @_;

    my $sample = $c->stash->{sample}
        or return;

    my $gem_schema = $c->dbic_schema('CXGN::GEM::Schema', 'sgn_chado' );
    $c->stash(
        target_list => [
            map { CXGN::GEM::Target->new( $gem_schema, $_ ) }
            $gem_schema->resultset('GeTargetElement')
                       ->search({ sample_id => $sample->get_sample_id })
                       ->get_column('target_id')
                       ->all
        ],
      );

}

1;
