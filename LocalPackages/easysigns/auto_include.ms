
# _parse_location(@args)
#
# Parse command line arguments @args with the format [<world>] <x> <y> <z>
# and return the corresponding CH location array, or an error message string
# if the arguments could not be parsed.
# @args can be an array slice created with @args[cslice(first, last)].

proc(_parse_location, @args,
	if (array_size(@args) != 3 && array_size(@args) != 4) {
		return ('The location must be of the form [<world>] <x> <y> <z>.')	
	}

	if (array_size(@args) == 4) {
		try(
			@world = @args[0]
			world_info(@world)
		,
			return ('Invalid world specified: '.@world)
		)
		@start = 1
	} else {
		@world = pworld()
		@start = 0
	}

	if (! is_numeric(@args[@start]) || ! is_numeric(@args[@start+1]) || ! is_numeric(@args[@start+2])) {
		return ('All coordinates must be numbers.')
	}
	
	return (array(@args[@start], @args[@start+1], @args[@start+2], @world))
)

/**
 * Changes the location array's new format into the old, expected format.
 */
proc(_easy_sign_loc_conv, @location,
	@array = array()
	@array[] = integer(@location['x'])
	@array[] = integer(@location['y'])
	@array[] = integer(@location['z'])
	@array[] = @location['world']
	return(@array)
)
