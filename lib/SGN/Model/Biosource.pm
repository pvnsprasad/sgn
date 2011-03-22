package SGN::Model::Biosource;
use strict;

use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Bio::Chado::Schema',
  );

1;
