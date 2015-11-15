
/**
 * Retrieves the player's uuid from the database, or null if no player is known with that username
 */
proc(_get_puuid, @playerName) {
	@playerName = to_lower(strip_colors(@playerName));

	if (ponline(@playerName)) {
		@pinfo = pinfo(@playerName);
		return(replace(@pinfo[20], '-', ''));
	}

	if (@playerName == '~console') {
		return(@playerName);
	}

	@uuidCache = import('uuidCache');

	if (array_index_exists(@uuidCache, @playerName)) {
		return(@uuidCache[@playerName]);
	}

	@res = query('uuid', 'SELECT uuid FROM user WHERE last_username=? LIMIT 1', @playerName);
	if (length(@res) == 0) {
		return(null);
	} else {
		@uuidCache[@playerName] = @res[0]['uuid'];
		export('uuidCache', @uuidCache);
		return(@res[0]['uuid']);
	}
}

/**
 * Gets the last known username from the database, or null, if no player is known with that uuid
 */
proc(_get_username_from_uuid, @uuid) {
	@nameCache = import('nameCache');

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
