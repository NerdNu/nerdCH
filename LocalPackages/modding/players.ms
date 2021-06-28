# Functions used in the implementation of players.msa.

# _get_tp_index(@target, @step)
#	Return the stored player index of the next player to teleport to, for the caller.
#	Each calling player keeps his own separate stored index.
#	*	If @target is a 1-based integer index into the players array, then it is 
#		converted to a 0-based index and returned.
#	*	If @target matches (inexactly) a player name, return his 0-based index.
#	*	Otherwise, use the previously used index incremented by @step (+1 or -1).

proc _get_tp_index(@target, @step) {
	if (is_numeric(@target)) {
		return (integer(@target) - 1)
	} else if (@target != '') {
		try (
			return (array_index(all_players(), player(@target)))
		)
	}

	@index = import('tpnext.'.player())
	if (is_null(@index)) {
		@index = -1
	}
	return (@index + @step)
}


# _tp_index(@index, @players)
#	Teleport to @players[@index], with message and @index checking. Store updated index.

proc _tp_index(@index, @players) {
	# Wrap around @index to a valid value in either direction.
	@count = array_size(@players)
	@index = mod(@count + @index, @count)
	export('tpnext.'.player(), @index)

	# Teleport.
	@player = @players[@index]
	if (has_permission(@player, 'nerdch.level.restricted')) {
		msg(color(GOLD).'Skipping '.@player.' ('.(@index+1).' of '.@count.'): ModMode or Admin.')
	} else {
		@loc = ploc(@player)
		@niceLoc = array(integer(@loc[0]), integer(@loc[1]), integer(@loc[2]), @loc[3])
		msg(color(GOLD).'Teleporting you to '.@player.' ('.(@index+1).' of '.@count.') at '.@niceLoc.'.')
		set_ploc(@loc)
	}
}

