package SGN::Controller::Biosource::API::Sample;
use Moose;
BEGIN { extends 'Catalyst::Controller::DBIC::API::REST' }

__PACKAGE__->config(
    action => { setup => { PathPart => 'sample', Chained => '/biosource/api/api_base' } },
    class            => 'Biosource::BsSample',
    use_json_boolean => 1,
  );



