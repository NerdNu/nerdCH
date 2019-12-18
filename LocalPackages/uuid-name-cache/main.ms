
export('uuidCache', array());
export('nameCache', array())

/**
 * Player login event to log the uuid and latest name
 */
bind('player_login', null, null, @event,
	x_new_thread('uuid_player_join', closure(){
		# Sleep, so they are fully joined before we get their id.
		sleep(0.5);
		@pinfo = pinfo(@event['player']);
		@uuid = replace(@event['uuid'], '-', '');
		@username = to_lower(strip_colors(@pinfo[0]));
		@displayName = @pinfo[4];
		@res = query('uuid', 'REPLACE INTO `user` (`uuid`, `last_username`, `last_display_name`) VALUES(?, ?, ?)', @uuid, @username, @displayName);
	});
)

