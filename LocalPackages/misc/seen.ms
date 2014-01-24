bind(player_join, null, null, @event,
	assign(@playerName, strip_colors(player()))
	assign(@lowerName, to_lower(@playerName))
	@ip = pinfo(@playerName, 3)
	store_value('lastseen.' . @lowerName, time())
	store_value('correctPlayerName.' . @lowerName, @playerName)
	store_value('lastip.' . @lowerName, @ip)
)
