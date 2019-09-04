
/**
 * This works around a minecraft bug that causes beds placed in the hell biome
 * to explode tnt like when right clicked with redstone.
 */
bind('block_place', null, array(type: 26), @e,
	# Do not allow beds to be placed in the NETHER or THE_END.

	@wenv = world_info(pworld())['environment']
	if(@wenv == 'NETHER') {
		msg(color(red).'Beds being placed in the Hell biome are blocked until\nfurther notice, sorry!')
		cancel()
	} else if (@wenv == 'THE_END') {
		msg(color(red).'Beds being placed in the End biome are blocked until\nfurther notice, sorry!')
		cancel()
	}

)

