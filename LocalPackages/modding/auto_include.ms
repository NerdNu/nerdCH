include('players.ms')

# Return true if the player has the specified potion effect, identified by numeric type ID.

proc(_has_peffect, @player, @potionID,
	foreach (get_peffect(@player), @effect,
		if (@effect[id] == @potionID) {
			return (true)
		}
	)
	return (false)
)


# _lb_retention_days()
#
# Return the duration to use for rollbacks and redos as an integer in days. 
# This value is set as 'lb.retention.days' in plugins/CommandHelper/main.ms. 
# If unspecified, it defaults to 21.

proc(_lb_retention_days,
	@days = import('lb.retention.days')
	return (if(is_null(@days), 21, @days))
)
