
use Modern::Perl;

package SGN::Model::Wiki;

use base 'DBIx::Class::Core';


__PACKAGE__->table("wiki");


__PACKAGE__->add_columns( 
    "wiki_id",
    { 
	data_type         => "integer",
	is_auto_increment => 1,
	is_nullable       => 0,
	sequence          => "wiki_wiki_id_seq",
    },

    "page",
    {
	data_type         => "text",
	is_nullable       => 0,
    },
    
    "contents",
    { 
	data_type         => "text",
    },

    "version",
    {
	data_type         => "integer",
    },
    );

__PACKAGE__->set_primary_key("wiki_id");

