package SGN::Test::Data;

use strict;
use warnings;
use Bio::Chado::Schema::Sequence::Feature;
use SGN::Context;
use base 'Exporter';
use Test::More;

our $schema;

BEGIN {
    my $db_profile = 'sgn_test';
    eval {
        $schema = SGN::Context->new->dbic_schema('Bio::Chado::Schema', $db_profile)
    };
    if ($@) {
        plan skip_all => "Could not create a db connection. Do  you have the $db_profile db profile?";
    }
}

our $num_features = 0;
our $num_cvterms = 0;
our $num_dbxrefs = 0;
our $num_dbs = 0;
our $num_cvs = 0;
our $num_organisms = 0;
our $test_data = [];
our @EXPORT_OK = qw/ create_test /;

sub create_test {
    my ($pkg, $values) = @_;
    die "Must provide package name to create test object" unless $pkg;
    my $pkg_subs = {
        'Cv::Cv'               => sub { _create_test_cv($values) },
        'Cv::Cvterm'           => sub { _create_test_cvterm($values) },
        'General::Db'          => sub { _create_test_db($values) },
        'General::Dbxref'      => sub { _create_test_dbxref($values) },
        'Sequence::Feature'    => sub { _create_test_feature($values) },
        'Organism::Organism'   => sub { _create_test_organism($values) },
        'Sequence::Featureloc' => sub { _create_test_featureloc($values) },

    };
    die "$pkg creation not supported yet, sorry" unless exists $pkg_subs->{$pkg};
    return $pkg_subs->{$pkg}->($values);
}

sub _create_test_db {
    my ($values) = @_;
    my $db = $schema->resultset('General::Db')
           ->create( { name => $values->{name} || "db_$num_dbs-$$" } );
    push @$test_data, $db;
    $num_dbs++;
    return $db;
}

sub _create_test_dbxref {
    my ($values) = @_;
    $values->{db} ||= _create_test_db();

    my $dbxref = $schema->resultset('General::Dbxref')
           ->create(
            {
                db_id     => $values->{db}->db_id,
                accession => $values->{accession} || "dbxref_$num_dbxrefs-$$",
            });
    push @$test_data, $dbxref;
    $num_dbxrefs++;
    return $dbxref;
}

sub _create_test_cv {
    my ($values) = @_;
    unless ($values->{name}) {
        $values->{name} = "cv_$num_cvs-$$";
    }
    my $cv = $schema->resultset('Cv::Cv')
           ->create( { name => $values->{name} } );

    push @$test_data, $cv;
    $num_cvs++;
    return $cv;
}

sub _create_test_cvterm {
    my ($values) = @_;
    unless ($values->{name}) {
        $values->{name} = "cvterm_$num_cvterms-$$";
    }
    $values->{dbxref} ||= _create_test_dbxref();
    $values->{cv}     ||= _create_test_cv();
    my $cvterm = $schema->resultset('Cv::Cvterm')
           ->create(
            {
                name   => $values->{name},
                dbxref => $values->{dbxref},
                cv_id  => $values->{cv}->cv_id,
            });
    push @$test_data, $cvterm;
    $num_cvterms++;
    return $cvterm;
}

sub _create_test_organism {
    my ($values) = @_;
    unless ($values->{genus}) {
        $values->{genus} = "organism_$num_organisms-$$";
    }
    unless ($values->{species}) {
        $values->{species} = $values->{genus} . ' fooii';
    }
    my $organism = $schema->resultset('Organism::Organism')
                          ->create( $values );
    push @$test_data, $organism;
    $num_organisms++;
    return $organism;

}

sub _create_test_feature {
    my ($values) = @_;

    # provide some defaults for things we don't care about
    $values->{residues} = 'ATCG' unless $values->{residues};
    $values->{seqlen} = length($values->{residues}) unless $values->{seqlen};
    unless ($values->{name}) {
        $values->{name} = "feature_$num_features-$$";
        $num_features++;
    }
    unless ($values->{uniquename}) {
        $values->{uniquename} = "unique_feature_$num_features-$$";
        $num_features++;
    }

    $values->{organism} ||= _create_test_organism();
    $values->{type}     ||= _create_test_cvterm();

    my $feature = $schema->resultset('Sequence::Feature')
           ->create({
                residues    => $values->{residues},
                seqlen      => $values->{seqlen},
                name        => $values->{name},
                uniquename  => $values->{uniquename},
                type_id     => $values->{type}->cvterm_id,
                organism_id => $values->{organism}->organism_id,
           });
    push @$test_data, $feature;
    return $feature;
}

sub _create_test_featureloc {
    my ($values) = @_;

    $values->{feature}    ||= _create_test_feature();
    $values->{srcfeature} ||= _create_test_feature();
    # the following values need to be consistent with the default
    # residue, which is 4 bases long
    $values->{fmin} ||= 1;
    $values->{fmax} ||= 3;

    my $featureloc = $schema->resultset('Sequence::Featureloc')
        ->create({
            feature_id    => $values->{feature}->feature_id,
            srcfeature_id => $values->{srcfeature}->feature_id,
            fmin          => $values->{fmin},
            fmax          => $values->{fmax},
        });
}

sub END {
    diag("deleting " . scalar(@$test_data) . " test data objects") if @$test_data;
    # delete objects in the reverse order we created them
    # TODO: catch signals?
    map {
        diag("deleting $_") if $ENV{DEBUG};
        my $deleted = $_->delete;
    } reverse @$test_data;
}

1;
