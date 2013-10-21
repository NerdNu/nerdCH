#TODO: Blacklisting (inc pots)
# _parseiargs()
#	Parse the arguments to /i and /give.
#	If successful, return an array(@itemid, @metadata, @quantity), all entries numeric.
#	Otherwise, return null.

proc(_parseiargs, @input, 
	@m = reg_match('^([^ :]+)(:[0-9]+)?( [0-9]+)?$', @input)
	if (array_index_exists(@m,0)) {
		# CH docs tell lies. @itemid can be a string, e.g. '35:15' for 'blackwool'.
		@itemid = data_values(@m[1])
		@metadata = 0
		@quantity = if(pmode() == 'CREATIVE', 1, max_stack_size(@itemid))

		# Validate item ID.
		if (is_null(@itemid)) {
			msg(color(RED).'Unknown item: '.@m[1])
			return (null)
		} else {
			if (is_integer(@itemid)) {
				if (! is_null(@m[2])) {
					@metadata = integer(substr(@m[2], 1))
				}
			} else {
				# @input was e.g. 'blackwool' ==> @itemid is '35:15'
				@parts = split(':', @itemid)
				@itemid = @parts[0]
				@metadata = @parts[1]
			}

			# Quantity.
			if (! is_null(@m[3])) {
				@quantity = min(512, integer(substr(@m[3], 1)))
			}
			return (array(@itemid, @metadata, @quantity))
		}
	} else {
		return (null)
	}
)
