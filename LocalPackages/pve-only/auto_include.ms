try(include(reflect_pull('dir').'/pets.ms'))
try(include(reflect_pull('dir').'/villagers.ms'))

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

# Return the name of the specified world in the place database.
# That name is also the friendly name presented in chat.

proc _placeDBWorldName(@world) {
	switch (@world) {
		case 'world':         return ('Overworld');
		case 'world_nether':  return ('Nether');
		case 'world_the_end': return ('End');
		case 'mapworld':      return ('Mapworld');
		default:              return (@world);
	}
}

# Return the place database.

proc _getPlaceDB() {
	return (get_value('placedb') ||| array());
}

# Return the place with the specified world, set and name, or null
# if not found. The returned place is a location array.

proc _getPlace(@placedb, @world, @set, @name) {
	# Avoid IndexOverflowException.
	if (!array_index_exists(@placedb, @world)       ||
		!array_index_exists(@placedb[@world], @set) ||
		!array_index_exists(@placedb[@world][@set], @name)) {
		return (null);
	}
	return @placedb[@world][@set][@name];
}

# Remove and return the place specified by @name from the specified set
# and world, or return null if no matching place was found.
# Also, clean up any resulting empty arrays in the place database and 
# message the command sender accordingly.
# If @chatty is true, send messages about changes to the database.

proc _removePlace(@placedb, @world, @set, @name, @chatty) {
	if (_getPlace(@placedb, @world, @set, @name) == null) {
		return (null);
	}

	@place = array_remove(@placedb[@world][@set], @name)
	if (@place != null) {
		if (@chatty) {
			msg(color('LIGHT_PURPLE').'Removed '.@name.' in '.@set.' in '.@world.'.');
		}
		if (array_size(@placedb[@world][@set]) == 0) {
			array_remove(@placedb[@world], @set);
			if (@chatty) {
				msg(color('LIGHT_PURPLE').'Removed '.@set.' in '.@world.'.');
			}
			if (array_size(@placedb[@world]) == 0) {
				array_remove(@placedb, @world);
				if (@chatty) {
					msg(color('LIGHT_PURPLE').'Removed '.@world.'.');
				}
			}
		}
		store_value('placedb', @placedb);
	}
	return (@place);
}

proc _placeTabcomplete() {
	@places = _getPlaceDB();
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
	@places = _getPlaceDB();
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
	@places = _getPlaceDB();
	@worlds = array('Overworld', 'Nether', 'End', 'Mapworld');
	@placeCompletion = array();
	foreach (@world in @worlds) {
		if (array_index_exists(@places, @world)) {
			foreach (@category: @list in @places[@world]) {
				@setCompletion[] = @category;
				foreach (@key: @item in @list) {
					@placeCompletion[] = @key;
				}
			}
		}
	}
	return (get_tabcomplete_prototype(
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

