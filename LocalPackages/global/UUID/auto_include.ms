
/**
 * Retrieves the player's uuid from the database, or null if no player is known with that username
 */
proc(_get_puuid, @playerName){
	if (ponline(@playerName)) {
		@pinfo = pinfo(@playerName);
		return replace(@pinfo[20], '-', '');
	}

	@playerName = to_lower(strip_colors(@playerName));
	if (@playerName == '~console') {
		return @playerName
	}

	@res = query('uuid', 'SELECT uuid FROM user WHERE last_username=? LIMIT 1', @playerName);
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['uuid']);
	}
}

/**
 * Gets the last known username from the database, or null, if no player is known with that uuid
 */
proc(_get_username_from_uuid, @uuid){
	msg(@uuid);
	@res = query('uuid', 'SELECT last_username FROM user WHERE uuid=?', @uuid);
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['last_username']);
	}
}

/**
 * Gets the last known display name from the database, or null, if no player is known with that uuid
 */
proc(_get_display_name_from_uuid, @uuid){
	@res = query('uuid', 'SELECT last_display_name FROM user WHERE uuid=?', @uuid);
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['last_display_name']);
	}
}

/**
 * Player login event to display bulletins from subscribed channels.
 */
bind(player_login, null, null, @event,
	x_new_thread('uuid_player_join', closure(){
		// Sleep, so they are fully joined before we get their id.
		sleep(1);
		@pinfo = pinfo()
		@uuid = replace(@pinfo[20], '-', '');
		@username = to_lower(strip_colors(@pinfo[0]));
		@displayName = @pinfo[4];
		@res = query('uuid', 'REPLACE INTO `user` (`uuid`, `last_username`, `last_display_name`) VALUES(?, ?, ?)', @uuid, @username, @displayName);
	});
)
