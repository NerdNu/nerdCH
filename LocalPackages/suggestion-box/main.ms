bind('player_join', null, null, @event) {
        if(has_permission(@event['player'], 'nerdch.level.admin')) {
                @suggestions = get_value('suggestionbox.suggestions');
                if(length(@suggestions) > 0) {
                        set_timeout(15000, closure() {
                                tmsg(@event['player'], color('dark_green').'There are player suggestions! Check them with /suggestion-box-list');
                        });
                }
        }
	@hash = md5(player().get_value('suggestionbox.salt'));
	if(has_value('suggestionbox.replies.'.@hash)) {
		msg(color('RED')."You have recieved a reply to your feedback. Note that this is the only time you can see this, it will automatically delete after display.");
		foreach(@reply in get_value('suggestionbox.replies.'.@hash)) {
			msg(@reply);
		}
		msg(color('RED').'-----------------------------');
		clear_value('suggestionbox.replies.'.@hash);
	} 
}
