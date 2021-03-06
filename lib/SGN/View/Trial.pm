package SGN::View::Trial;
use base 'Exporter';
use strict;
use warnings;

our @EXPORT_OK = qw/
    design_layout_view
    design_info_view
    trial_detail_design_view
/;
our @EXPORT = ();

sub trial_detail_design_view {
  my $design_ref = shift;
  my %design = %{$design_ref};
  my $design_result_html;

  $design_result_html .= '<table border="1">';
  $design_result_html .= qq{<tr><th>Plot Name</th><th>Accession Name</th><th>Check Name</th><th>Row number</th><th>Col number</th><th>Block Number</th><th>Block Row Number</th><th>Block Col Number</th><th>Rep Number</th></tr>};

  foreach my $key (sort { $a <=> $b} keys %design) {
    $design_result_html .= "<tr><td>".$design{$key}->{plot_name} ."</td><td>".$design{$key}->{accession_name} ."</td><td>".$design{$key}->{check_name}."</td><td>".$design{$key}->{row_number}."</td><td>".$design{$key}->{col_number}."</td><td>".$design{$key}->{block_number}."</td><td>".$design{$key}->{block_row_number}."</td><td>".$design{$key}->{block_col_number}."</td>";
    if ($design{$key}->{rep_number}) {
      $design_result_html .= "<td>".$design{$key}->{rep_number}."</td>";
    }
    $design_result_html .= "</tr>";
  }
  $design_result_html .= "</table>";
  return  "$design_result_html";

}


sub design_layout_view {
  my $design_ref = shift;
  my $design_info_ref = shift;
  my %design = %{$design_ref};
  my %design_info = %{$design_info_ref};
  my $design_result_html;

  $design_result_html .= '<table border="1">';
  $design_result_html .= qq{<tr><th>Plot Name</th><th>Accession Name</th><th>Check Name</th><th>Row number</th><th>Col number</th><th>Block Number</th><th>Block Row Number</th><th>Block Col Number</th><th>Rep Number</th></tr>};
  foreach my $key (sort { $a <=> $b} keys %design) {
    #$design_result_html .= "<tr><td>".$design{$key}->{plot_name} ."</td><td>".$design{$key}->{stock_name} ."</td><td>".$design{$key}->{check_name}."</td><td>".$design{$key}->{row_number}."</td><td>".$design{$key}->{col_number}."</td><td>".$design{$key}->{block_number}."</td><td>".$design{$key}->{block_row_number}."</td><td>".$design{$key}->{block_col_number}."</td>";
    $design_result_html .= "<tr><td>".$design{$key}->{plot_name} ."</td><td>".$design{$key}->{stock_name} ."</td><td>".$design{$key}->{check_name}."</td><td>".$design{$key}->{row_number}."</td><td>".$design{$key}->{col_number}."</td><td>".$design{$key}->{block_number}."</td><td>".$design{$key}->{block_row_number}."</td><td>".$design{$key}->{block_col_number}."</td>";
    if ($design{$key}->{rep_number}) {
      $design_result_html .= "<td>".$design{$key}->{rep_number}."</td>";
    }
    $design_result_html .= "</tr>";
  }
  $design_result_html .= "</table>";
  return  "$design_result_html";

}

sub design_info_view {
  my $design_ref = shift;
  my $design_info_ref = shift;
  my %design = %{$design_ref};
  my %design_info = %{$design_info_ref};
  my %block_hash;
  my %rep_hash;
  my $design_info_html;
  my $design_description;


  $design_info_html .= "<dl>";

  if ($design_info{'design_type'}) {
    $design_description = $design_info{'design_type'};
    if ($design_info{'design_type'} eq "CRD") {
      $design_description = "Completely Randomized Design";
    }
    if ($design_info{'design_type'} eq "RCBD") {
      $design_description = "Randomized Complete Block Design";
    }
    if ($design_info{'design_type'} eq "Alpha") {
      $design_description = "Alpha Lattice Incomplete Block Design";
    }
    if ($design_info{'design_type'} eq "Augmented") {
      $design_description = "Augmented Incomplete Block Design";
    }
    if ($design_info{'design_type'} eq "MAD") {
      $design_description = "Modified Augmented Design";
    }
#    if ($design_info{'design_type'} eq "MADII") {
#      $design_description = "Modified Augmented Design II";
#    }
#    if ($design_info{'design_type'} eq "MADIII") {
#      $design_description = "Modified Augmented Design III";
#    }
#    if ($design_info{'design_type'} eq "MADIV") {
#      $design_description = "Modified Augmented Design IV";
#    }
    $design_info_html .= "<dt>Design type</dt><dd>".$design_description."</dd>";
  }
  if ($design_info{'number_of_stocks'}) {
    $design_info_html .= "<dt>Number of accessions</dt><dd>".$design_info{'number_of_stocks'}."</dd>";
  }
  if ($design_info{'number_of_controls'}) {
    $design_info_html .= "<dt>Number of controls</dt><dd>".$design_info{'number_of_controls'}."</dd>";
  }

  foreach my $key (sort { $a <=> $b} keys %design) {
    my $current_block_number = $design{$key}->{block_number};
    my $current_rep_number;
    if ($block_hash{$current_block_number}) {
      $block_hash{$current_block_number} += 1;
    } else {
      $block_hash{$current_block_number} = 1;
    }
    if ($design{$key}->{rep_number}) {
      $current_rep_number = $design{$key}->{rep_number};
      if ($rep_hash{$current_rep_number}) {
	$rep_hash{$current_rep_number} += 1;
      } else {
	$rep_hash{$current_rep_number} = 1;
      }
    }
  }

  if (%block_hash) {
    $design_info_html .= "<dt>Number of blocks</dt><dd>".scalar(keys %block_hash)."</dd>";
    $design_info_html .= "<dt>Number of accessions per block</dt><dd>";
    foreach my $key (sort { $a <=> $b} keys %block_hash) {
      $design_info_html .= "Block ".$key.": ".$block_hash{$key}." accessions <br>";
    }
    $design_info_html .= "</dt>";
  }


  if (%rep_hash) {
    $design_info_html .= "<dt>Number of reps</dt><dd>".scalar(keys %rep_hash)."</dd>";
  }

  $design_info_html .= "</dl>";

  return $design_info_html;

}


######
1;
######
