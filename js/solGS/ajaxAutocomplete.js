

/**

autocomplete related js logic for solgs

Isaak Y Tecle 
iyt2@cornell.edu
*/


//trait search autocomplete
jQuery(document).ready( function() {
        jQuery("#trait_search_entry").autocomplete({
                source: "/solgs/ajax/trait/search",
                minLength: 3,
       });
    });
    

