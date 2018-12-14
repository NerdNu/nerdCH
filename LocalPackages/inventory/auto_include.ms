# _parseiargs()
#	Parse the arguments to /i and /give.
#	If successful, return an array(@itemid, @metadata, @quantity).
#	Otherwise, return null.

proc(_parseiargs, @input,

    # regex pattern: (* denotes nullable)
    # m(0) = whole match
    # *m(1) = minecraft:
    # m(2) = (item_name) OR (item name)
    # *m(3) = space + number(s)
    #
	@m = reg_match('^(minecraft:)?([a-zA-Z_ ]+)( [0-9]+)?$', @input)
	if (array_index_exists(@m,0)) {
	    if (is_null(@m[3])) {
	        @qty = integer(1)
	    } else {
	        @qty = integer(@m[3])
	    }
        return array(@m[2], @qty)
	} else {
		return (null)
	}
)
