include(reflect_pull('dir').'/pets.ms')
include(reflect_pull('dir').'/villagers.ms')

# Support for some basic functional programming.

# _map_associative(@input, @f1)
#
# Call a function of single argument on each of the elements of the input 
# associative array.  Return an array of results with the same keys as the 
# input array.
#
# If you pass a normal, non-associative array as input, this function will
# return an associative array with numeric keys (which doesn't work well
# with array_implode()). Use array_normalize() to flatten it in that case,
# or just use _map() instead.
#
# Example:
#	@lowers = array(1:, one, 2: two, 3: three)
#	@uppers = _map(@lowers, closure(@s, to_upper(@s)))

proc _map_associative(@input, @f1) {
	@output = array(@input)
	foreach (array_keys(@input), @key,
		array_set(@output, @key, execute(@input[@key], @f1))
	)
	return (@output)
}


# _map(@input, @f1)
#
# Call the single argument function f1 on each element of the input array
# and return an ordinary array of all of the results.
#
# Example:
#	@intCoords = _map(ploc[0..2], closure(@value, floor(@value)))

proc _map(@input, @f1) {
	@output = array()
	foreach (@input, @value,
		console(@value)
		@f1Value = execute(@value, @f1)
		array_push(@output, @f1Value)
	)
	return (@output)
}

proc _placeTabcomplete() {
	@places= get_value('placedb');
	@worlds = array('Overworld', 'Nether', 'End', 'Mapworld');
	@placeCompletion = array();
	foreach(@world in @worlds) {
		if(array_index_exists(@places, @world)) {
			foreach(@category: @list in @places[@world]) {
				foreach(@key: @item in @list) {
					@placeCompletion[] = @key;
				}
			}
		}
	}
	return(get_tabcomplete_prototype(
		@placeCompletion,
		@worlds
	));
}

proc _addPlaceTabcomplete() {
	@setCompletion = array('Other');
	@places = get_value('placedb');
	@worlds = array('Overworld', 'Nether', 'End', 'Mapworld');
	foreach(@world in @worlds) {
		if(array_index_exists(@places, @world)) {
			foreach(@category: @list in @places[@world]) {
				@setCompletion[] = @category;
			}
		}
	}
	return(get_tabcomplete_prototype(
		'None',
		array_unique(@setCompletion)
	));
}

proc _delPlaceTabcomplete() {
	@setCompletion = array('Other');
	@places = get_value('placedb');
	@worlds = array('Overworld', 'Nether', 'End', 'Mapworld');
	@placeCompletion = array();
	foreach(@world in @worlds) {
	        if(array_index_exists(@places, @world)) {
	                foreach(@category: @list in @places[@world]) {
				@setCompletion[] = @category;
	                        foreach(@key: @item in @list) {
	                                @placeCompletion[] = @key;
	                        }
	                }
	        }
	}
	return(get_tabcomplete_prototype(
		@worlds,
		@setCompletion,
		@placeCompletion
	));
}

/**
 * Get the list of WPs for a player. Note that no filtering is done on this list, it always
 * provides the list for the requested player.
 */
proc _listwpNames(@player) {
	@uuid = puuid(@player, true)
	@waypoints = get_value('waypoints', @uuid)
	
	if(@waypoints == null || length(@waypoints) == 0) {
	    return(array());
	}
	
	return(array_keys(@waypoints));	
}

proc _listwpsTabcomplete() {
	return(get_tabcomplete_prototype(
		all_players()
	));
}

proc _wpTabcomplete() {
	return(get_tabcomplete_prototype(
		closure(@alias, @sender, @args) { return(array_merge(_listwpNames(@sender), all_players())); },
		closure(@alias, @sender, @args) { 
			return(_listwpNames(@args[0])); 
		}
	));	
}
