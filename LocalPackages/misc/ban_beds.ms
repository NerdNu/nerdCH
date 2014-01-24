
/**
 * This works around a minecraft bug that causes beds placed in the hell biome
 * to explode tnt like when right clicked with redstone.
 */
bind(block_place, null, array(type: 26), @e,
	# Look in a circle around the location, and if any of the blocks
	# are hell biome, cancel it
	@up = @e['location'][]
	@down = @e['location'][]
	@left = @e['location'][]
	@right = @e['location'][]
	@up['x'] = @up['x'] + 1
	@down['x'] = @down['x'] - 1
	@left['z'] = @left['z'] + 1
	@right['z'] = @right['z'] - 1
	@array = array(@e['location'], @up, @down, @left, @right)
	foreach(@array, @loc,
		if(get_biome(@loc) == 'HELL'){
			msg(color(red).'Beds being placed in the Hell biome are blocked until\nfurther notice, sorry!')
			cancel()
			break()
		}
	)
)
