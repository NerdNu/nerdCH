#TODO: Blacklisting (inc pots)
# _parseiargs()
#	Parse the arguments to /i and /give.
#	If successful, return an array(@itemid, @metadata, @quantity), all entries numeric.
#	Otherwise, return null.

proc(_parseiargs, @input,

    # regex pattern: (* denotes nullable)
    # *m(0) = minecraft:
    # m(1) = (item_name) OR (item name)
    # m(2) = space + number(s)
    #
	@m = reg_match('^(minecraft:)?([a-zA-Z_ ]+)( [0-9]+)?$', @input)
	if (array_index_exists(@m,0)) {
	    if (is_null(@m[2])) {
	        @qty = integer(1)
	    } else {
	        @qty = integer(@m[2])
	    }
        return array(@m[1], @qty)
	} else {
		return (null)
	}
)
