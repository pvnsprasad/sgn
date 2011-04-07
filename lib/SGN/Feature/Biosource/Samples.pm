package SGN::Feature::Biosource::Samples;
use Moose;
use namespace::autoclean;

extends 'SGN::Feature';


has '+description' => (
    default => 'Samples and datasets',
    );

sub xrefs {
    my ( $self, $query ) = @_;

    return if ref $query;

    return ( $self->_name_xrefs( $query ) );
}


sub _name_xrefs {
    my ( $self, $query ) = @_;

    my $c = $self->context;
    my $schema = $c->dbic_schema('CXGN::Biosource::Schema','sgn_chado')
        or return;

    my $samples = $schema->resultset('BsSample')
                         ->search({
                             -or => [ { sample_name => $query },
                                      { alternative_name => $query },
                                    ],
                            });
    return map {
        my $sample = $_;
        SGN::SiteFeatures::CrossReference->new({
            feature => $self,
            text    => $sample->sample_name.( $sample->alternative_name ? ' ('.$sample->alternative_name.')' : '' ),
            url     => URI->new( '/biosource/sample/'.$sample->sample_id.'/details' ),
        });
    } $samples->all;

}


1;
