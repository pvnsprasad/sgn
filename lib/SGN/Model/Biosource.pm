package SGN::Model::Biosource;
use Moose;

extends 'Catalyst::Model::DBIC::Schema';


__PACKAGE__->config(
    schema_class => 'CXGN::Biosource::Schema',
  );

1;
