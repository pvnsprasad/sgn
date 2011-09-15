use strict;
use warnings;
use Test::More tests => 7;

use lib 't/lib';
use SGN::Test::Data qw/ create_test /;
use Catalyst::Test 'SGN';
use Digest::SHA1 qw/sha1_hex/;
use Data::Dumper;

use_ok 'SGN::Controller::Bulk';
use aliased 'SGN::Test::WWW::Mechanize' => 'Mech';

my $mech = Mech->new;

my $poly_cvterm     = create_test('Cv::Cvterm',        { name => 'polypeptide' });
my $poly_feature    = create_test('Sequence::Feature', { type => $poly_cvterm  });

$mech->with_test_level( local => sub {

    # TODO: these tests depend on live data.
    my $ids =<<IDS;
SGN-E398616
SGN-E540202
SGN-E541638
C06HBa0222J18.1
C06HBa0229B01.1
AP009263
AP009262
SGN-E200027
SGN-E201684
SGN-E587346
SGN-E443637
SGN-E403108
IDS

    $mech->get_ok('/bulk/feature');
    $mech->submit_form_ok({
        form_name => "bulk_feature",
        fields    => {
            ids => $ids,
        },
    }, "submit bulk_feature form");
    $mech->content_like(qr/Download as/);

    my $sha1  = sha1_hex($ids);
    my @links = $mech->find_all_links( url_regex => qr{/bulk/feature/download/$sha1\.fasta} );

    cmp_ok(@links, '==', 1, "found one FASTA download link for $sha1.fasta");

    @links =  grep { $_ =~ qr{$sha1} } $mech->find_all_links(url_regex => qr{/bulk/feature/download/.*\.fasta} );

    cmp_ok(@links, '==', 0, "found no other download links") or diag("Unexpected download links" . Dumper [ map {$_->url} @links ]);

    #diag $mech->content;
});

$mech->with_test_level( local => sub {
    # attempt to post an empty list
    $mech->post('/bulk/feature/submit/', { ids => "" }  );
    is($mech->status,400);
});

done_testing();
