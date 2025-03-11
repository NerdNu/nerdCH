proc _convertcolors(@text) {
    return(reg_replace('&([0-9a-fA-F]{1})', concat(substr(color(0),0,1), '$1'), @text))
}


# seen.msa
# Stores the player's current username and IP address (as well as time).
/*bind('player_join', null, null, @event,
	assign(@playerName, strip_colors(player()))
	assign(@lowerName, to_lower(@playerName))
	@ip = pinfo(@playerName, 3)
	@uuid = _get_puuid(@playerName)
	store_value('lastseen.' . @uuid, time())
	store_value('correctPlayerName.' . @lowerName, @playerName)
	store_value('lastip.' . @uuid, @ip)
)*/

proc _signtextTabcompletion() {
	return(get_tabcomplete_prototype(
		1..4,
		'None'
	));
}

# Checks if the block the player is looking at is a sign. CH method is_sign_at() does not include hanging signs.

boolean proc _isSign(@player) {
	array @signblocks = array('OAK_SIGN', 'OAK_HANGING_SIGN', 'OAK_WALL_HANGING_SIGN', 'SPRUCE_SIGN', 'SPRUCE_HANGING_SIGN', 'SPRUCE_WALL_HANGING_SIGN',
		'BIRCH_SIGN', 'BIRCH_HANGING_SIGN', 'BIRCH_WALL_HANGING_SIGN', 'JUNGLE_SIGN', 'JUNGLE_HANGING_SIGN', 'JUNGLE_WALL_HANGING_SIGN', 'ACACIA_SIGN',
		'ACACIA_HANGING_SIGN', 'ACACIA_WALL_HANGING_SIGN', 'DARK_OAK_SIGN', 'DARK_OAK_HANGING_SIGN', 'DARK_OAK_WALL_HANGING_SIGN', 'MANGROVE_SIGN', 'MANGROVE_HANGING_SIGN',
		'MANGROVE_WALL_HANGING_SIGN', 'CHERRY_SIGN', 'CHERRY_HANGING_SIGN', 'CHERRY_WALL_HANGING_SIGN', 'PALE_OAK_SIGN', 'PALE_OAK_HANGING_SIGN', 'PALE_OAK_WALL_HANGING_SIGN',
		'BAMBOO_SIGN', 'BAMBOO_HANGING_SIGN', 'BAMBOO_WALL_HANGING_SIGN', 'CRIMSON_SIGN', 'CRIMSON_HANGING_SIGN', 'CRIMSON_WALL_HANGING_SIGN', 'WARPED_SIGN',
		'WARPED_HANGING_SIGN', 'WARPED_WALL_HANGING_SIGN');
	return(array_contains_ic(@signblocks, get_block(pcursor(@player))));
}