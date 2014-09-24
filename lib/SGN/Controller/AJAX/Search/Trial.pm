
package SGN::Controller::AJAX::Search::Trial;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );

sub search :Path('/ajax/search/trials') Args(0) { 
    my $self = shift;
    my $c = shift;

    my $params = $c->req->params();

    $params->{page_size} = 20 if (! $params->{page_size});
    $params->{page} = 1 if (! $params->{page});
    
    my $trial_name_condition;
    
    my @conditions;
    my @bind_values;

    if ($params->{trial_name} && ($params->{trial_name} ne "all")) { 
	push @conditions, "project.name ilike ?";
	push @bind_values, "%".$params->{trial_name}."%";
    }
    if ($params->{location} && ($params->{location} ne "all")) { 
	push @conditions, "nd_geolocation.description ilike ?";
	push @bind_values, '%'.$params->{location}.'%';
    }
    if ($params->{year} && ($params->{year} ne "all")) { 
	push @conditions, "projectprop.value ilike ?";
	push @bind_values, '%'.$params->{year}.'%';
    }
    if ($params->{breeding_program} && ($params->{breeding_program} ne "all")) { 
	push @conditions, "program.name ilike ?";
	push @bind_values, $params->{breeding_program};
    }

    my $select_clause = "SELECT distinct(project.project_id), project.name, project.description, program.name, projectprop.value ";

    my $count_clause = "SELECT count(distinct(project.project_id)) ";

    my $from_clause = " FROM project JOIN nd_experiment_project USING(project_id) JOIN nd_experiment USING (nd_experiment_id) JOIN nd_geolocation using(nd_geolocation_id) JOIN projectprop ON (project.project_id = projectprop.project_id) JOIN project_relationship ON (project.project_id = project_relationship.subject_project_id) JOIN project as program ON (project_relationship.object_project_id=program.project_id) join cvterm on(projectprop.type_id = cvterm.cvterm_id) WHERE cvterm.name ilike '%year%'  ";

    my $where_clause = " AND ". join (" AND ", @conditions) if (@conditions);

    my $order_clause = " ORDER BY projectprop.value desc, program.name, project.name ";

    my $q .= $count_clause . $from_clause . $where_clause;

    my $offset = " LIMIT ".$params->{page_size}. " OFFSET ".(($params->{page}-1) * $params->{page_size}) ;

    print STDERR "QUERY: $q\n";
    
    my $h = $c->dbc->dbh->prepare($q);
    $h->execute(@bind_values);

    my ($total) = $h->fetchrow_array();

    print STDERR "Total matches: $total\n";

    $q = $select_clause . $from_clause . $where_clause . $order_clause . $offset;

    print STDERR "QUERY: $q\n";

    $h = $c->dbc->dbh->prepare($q);

    $h->execute(@bind_values);

    my @result;
    while (my ($project_id, $project_name, $project_description, $program, $year) = $h->fetchrow_array()) { 
	push @result, [ "<a href=\"/breeders_toolbox/trial/$project_id\">$project_name</a>", $project_description, $program, $year ];
    }

    $c->stash->{rest} =  { 
	trials => \@result,
	total_count => $total,
    };
}