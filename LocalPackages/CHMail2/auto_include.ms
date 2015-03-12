
/**
 * Retrieves the player's uuid from the mail database, or null if no player is known with that username
 */
proc(_mail_get_puuid, @playerName){
	@res = query('mail', 'SELECT uuid FROM user WHERE last_username=? LIMIT 1', to_lower(@playerName));
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['uuid']);
	}
}

/**
 * Gets the last known username from the mail database, or null, if no player is known with that uuid
 */
proc(_mail_get_username_from_uuid, @uuid){
	@res = query('mail', 'SELECT last_username FROM user WHERE uuid=?', @uuid);
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['last_username']);
	}
}

/**
 * Gets the last known display name from the mail database, or null, if no player is known with that uuid
 */
proc(_mail_get_display_name_from_uuid, @uuid){
	@res = query('mail', 'SELECT last_display_name FROM user WHERE uuid=?', @uuid);
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['last_display_name']);
	}
}
