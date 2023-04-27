
export('uuidCache', array());
export('nameCache', array())

/**
 * Player login event to log the uuid and latest name. Retries 5 times, sleeping for
 * 3 seconds between each attempt, if they haven't fully joined yet.
 */
bind('player_login', null, null, @event,
	x_new_thread('uuid_player_join', closure(){
		foreach(@i in 0..5) {
			if(!ponline(@event['player'])) {
				# Sleep, so they are fully joined before we get their id.
				sleep(3);
				continue;
			}
			@pinfo = pinfo(@event['player']);
			@uuid = replace(@event['uuid'], '-', '');
			@username = to_lower(strip_colors(@pinfo[0]));
			@displayName = @pinfo[4];
			@res = query('uuid', 'REPLACE INTO `user` (`uuid`, `last_username`, `last_display_name`) VALUES(?, ?, ?)', @uuid, @username, @displayName);
			break;
		}
	});
)

