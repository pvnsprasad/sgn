use CGI ();
use URI::Escape;
my $q  = CGI->new;
my $id = uri_escape( $q->param('id') || $q->param('name') );
print $q->redirect( "/biosource/sample/$id/details", 301 );
