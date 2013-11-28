bind(player_join, null, null, @event,
	set_timeout(1000, closure(
		@motd = get_value('motd')
		if (! is_null(@motd) && length(@motd) != 0) {
			tmsg(@event[player], @motd)
		}
	))
)
