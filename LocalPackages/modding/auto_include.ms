bind(player_join, null, null, @event,
    @warnings = get_value('warnings', puuid(@event['player'], true))
    if(@warnings != null) {
        msg(color(GRAY).'---------------------------------------------')
        msg(color(RED).'You been warned about something by a staff member!')
        msg(color(RED)."Type '/warnings' to view your warnings.")
        msg(color(GRAY).'---------------------------------------------')
    }
)

set_interval(30 * 1000, closure() {
    @player_warnings = get_values('warnings')
    @players = all_players()
    foreach(@key: @value in @player_warnings) {
        @player_name = _get_username_from_uuid(substr(@key, 9))
        if(array_contains_ic(@players, @player_name)) {
            @player = player(@player_name)
            tmsg(@player, color(GRAY).'---------------------------------------------')
            tmsg(@player, color(RED).'You been warned about something by a staff member!')
            tmsg(@player, color(RED)."Type '/warnings' to view your warnings.")
            tmsg(@player, color(RED)."Type '/warnings clear 1' to clear the first warning.")
            tmsg(@player, color(GRAY).'---------------------------------------------')
        }
    }
})

/**
 * Gets the last known username from the database, or null, if no player is known with that UUID.
 * Hyphens are automatically stripped from the UUID to match the database contents.
 */
proc(_get_username_from_uuid, @uuid) {
	@nameCache = import('nameCache');
	@uuid = replace(@uuid, '-', '');

	if (array_index_exists(@nameCache, @uuid)) {
		return(@nameCache[@uuid]);
	}

	@res = query('uuid', 'SELECT last_username FROM user WHERE uuid=?', @uuid);
	if (length(@res) == 0) {
		return(null);
	} else {
		@nameCache[@uuid] = @res[0]['last_username'];
		export('nameCache', @nameCache);
		return(@res[0]['last_username']);
	}
}

# _get_tp_index(@target, @step)
#	Return the stored player index of the next player to teleport to, for the caller.
#	Each calling player keeps his own separate stored index.
#	*	If @target is a 1-based integer index into the players array, then it is
#		converted to a 0-based index and returned.
#	*	If @target matches (inexactly) a player name, return his 0-based index.
#	*	Otherwise, use the previously used index incremented by @step (+1 or -1).

proc(_get_tp_index, @target, @step,
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
)


# _tp_index(@index, @players)
#	Teleport to @players[@index], with message and @index checking. Store updated index.

proc(_tp_index, @index, @players,
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
)

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

proc(
	_3d_distance, @arr1, @arr2,
	return(
		floor(
			sqrt(
				  ((@arr2[0] - @arr1[0]) ** 2)
				+ ((@arr2[1] - @arr1[1]) ** 2)
				+ ((@arr2[2] - @arr1[2]) ** 2)
			)
		)
	)
)

proc(_add_flags, @region, @timeout, @tries, @owner,
	if(@tries < 1) {
		msg(color(RED).'Default flags added unsuccessfully.')
	} else {
		if(sk_region_exists(@region)) {
			call_alias('/addflags '.@region . ' ' . @owner)
		} else {
			# WorldGuard 6 handles /region define asynchronously.
			set_timeout(@timeout, closure(){
				_add_flags(@region, @timeout, @tries - 1, @owner)
			})
		}
	}
)
