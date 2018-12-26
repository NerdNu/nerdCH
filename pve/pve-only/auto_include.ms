include('pets.ms')


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

proc(_map_associative, @input, @f1,
	@output = array(@input)
	foreach (array_keys(@input), @key,
		array_set(@output, @key, execute(@input[@key], @f1))
	)
	return (@output)
)


# _map(@input, @f1)
#
# Call the single argument function f1 on each element of the input array
# and return an ordinary array of all of the results.
#
# Example:
#	@intCoords = _map(ploc[0..2], closure(@value, floor(@value)))

proc(_map, @input, @f1,
	@output = array()
	foreach (@input, @value,
		console(@value)
		@f1Value = execute(@value, @f1)
		array_push(@output, @f1Value)
	)
	return (@output)
)
