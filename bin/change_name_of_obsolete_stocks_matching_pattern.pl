#!/usr/bin/env perl

=head1

change_name_of_obsolete_stocks_matching_pattern.pl

=head1 SYNOPSIS

    change_name_of_obsolete_stocks_matching_pattern.pl -H [dbhost] -D [dbname] -f "Ug" -r "UG"

=head1 COMMAND-LINE OPTIONS

 -H  host name
 -D  database name
 -f  string to find
 -r  replace string with this

=head2 DESCRIPTION


=head2 AUTHOR

Jeremy D. Edwards (jde22@cornell.edu)

April 2014

=head2 TODO

Add support for other spreadsheet formats

=cut

use strict;
use warnings;

use lib 'lib';
use Getopt::Std;
use Bio::Chado::Schema;
use CXGN::DB::InsertDBH;
use CXGN::DB::Connection;



our ($opt_H, $opt_D, $opt_f, $opt_r);
getopts('H:D:f:r:');


sub print_help {
  print STDERR "A script to rename obsolete stocks\nUsage: change_name_of_obsolete_stocks_matching_pattern.pl -D [database name] -H [database host, e.g., localhost] -f [find string] -r [replace string with this]\n";
}


if (!$opt_D || !$opt_H || !$opt_f ) {
  print_help();
  die("Exiting: options missing\n");
}

my $dbh = CXGN::DB::InsertDBH
  ->new({
	 dbname => $opt_D,
	 dbhost => $opt_H,
	 dbargs => {AutoCommit => 1,
		    RaiseError => 1},
	});

my $chado_schema = Bio::Chado::Schema->connect(  sub { $dbh->get_actual_dbh() } );

my $rs = $chado_schema->resultset('Stock::Stock')->search({'uniquename' => {like => $opt_f.'%'}});

my $count = 0;
foreach my $stock ($rs->all()) {
  print STDERR "Original name: ".$stock->uniquename()."\n";
  $count++;
}
print STDERR "\nFound $count accessions\n";

if ($opt_r) {
  foreach my $stock ($rs->all()) {
    my $stockid = $stock->stock_id();
    my $uniquename = $stock->uniquename();
    my $newname = $uniquename."obsolete";
    print STDERR "new name: $newname\n";
    if ($stock->is_obsolete()) {
      print STDERR "$stockid changing name $uniquename to $newname\n";
      $stock->uniquename($newname);
      $stock->update();
    }
  }
}
