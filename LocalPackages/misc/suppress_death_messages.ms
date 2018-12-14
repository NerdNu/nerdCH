
bind(player_death, null, null, @e,
	if(get_value('supress_death_messages')){
		console('Death message suppressed: ' . @e['death_message'])
		modify_event('death_message', null)
	}
)
