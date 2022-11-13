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
