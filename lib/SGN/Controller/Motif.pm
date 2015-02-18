
package SGN::Controller::Motif;

use Moose;
use File::Basename;

BEGIN { extends 'Catalyst::Controller'; }

# this function read the database files (Bowtie2) and
# send the list of databases to the view input.mas
sub input :Path('/tools/motifs/')  :Args(0) { 
	my ($self, $c) = @_;

	# redirect to the view file input.mas
	$c->stash->{template} = '/tools/motif/motif_input.mas';
}

sub motifs_output :Path('/tools/motifs_ouput/')  :Args(0) { 
	my ($self, $c) = @_;
  
  my $params = $c->req->body_params();
  my $gene_name = $c->req->param("input_gene");
  
	# redirect to the view file input.mas
	$c->stash->{template} = '/tools/motif/motif_output.mas';
}


1;
