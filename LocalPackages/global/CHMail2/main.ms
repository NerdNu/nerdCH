

bind(player_join, null, null, @event){
	x_new_thread('mail_player_join', closure(){
		// Sleep, so they are fully joined before we get their id.
		sleep(1);
		@uuid = entity_uuid(pinfo(player(), 13));
		@res = query('mail', 'SELECT * FROM user WHERE uuid=? LIMIT 1', @uuid);
		if(length(@res) != 0){
			query('mail', 'UPDATE user SET last_username=?, last_display_name=? WHERE uuid=?', to_lower(player()), player(), @uuid);
		} else {
			query('mail', 'INSERT INTO user (uuid, last_username, last_display_name, email) VALUES (?, ?, ?, NULL)',
				@uuid, to_lower(player()), player());
		}
	});
}

set_interval(10000, closure(){
	x_new_thread('mail_check', closure(){
		@res = query('mail', 'SELECT * FROM message WHERE `notified`=0');
		@playersToNotify = array();
		foreach(@row in @res){
			@puuid = @row['to'];
			@pname = _mail_get_username_from_uuid(@puuid);
			if(ponline(@pname)){
				if(array_index_exists(@playersToNotify, @pname)){
					@playersToNotify[@pname] = @playersToNotify[@pname] + 1;
				} else {
					@playersToNotify[@pname] = 1;
				}
			}
		}
		foreach(@player: @count in @playersToNotify){
			@message = if(@count == 1, 'You have one unread message.', "You have @count unread messages.");
			@didNotify = x_run_on_main_thread_now(closure(){
				//Double check to ensure that the player is still online
				if(ponline(@player)){
					tmsg(@player, color(GREEN).@message
						.' Type '.color(LIGHT_PURPLE).'/mail inbox'
						.color(GREEN).' to see your messages.');
					return(true);
				}
				return(false);
			});
			if(@didNotify){
				query('mail', 'UPDATE message SET `notified`=1 WHERE `to`=?', _mail_get_puuid(@player));
			}
		}
	});
});
