# Return true if the player has the specified potion effect, identified by numeric type ID.

proc(_has_peffect, @player, @potionID,
	foreach (get_peffect(@player), @effect,
		if (@effect[id] == @potionID) {
			return (true)
		}
	)
	return (false)
)
