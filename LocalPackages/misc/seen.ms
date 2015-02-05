bind(player_join, null, null, @event,
	assign(@playerName, strip_colors(player()))
	assign(@lowerName, to_lower(@playerName))
	@ip = pinfo(@playerName, 3)
	@uuid = _get_puuid(@playerName)
	store_value('lastseen.' . @uuid, time())
	store_value('correctPlayerName.' . @lowerName, @playerName)
	store_value('lastip.' . @uuid, @ip)
)
