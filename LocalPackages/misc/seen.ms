bind(player_join, null, null, @event,
	assign(@playerName, strip_colors(player()))
	assign(@lowerName, to_lower(@playerName))
	store_value('lastseen.' . @lowerName, time())
	store_value('correctPlayerName.' . @lowerName, @playerName)
)
