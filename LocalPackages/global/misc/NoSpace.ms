/**
 * Prevents users with spaces in their name from logging in. Spaces
 * in names cause many issues, so our solution is to just ban
 * the users at the git-go.
 */
bind(player_login, null, null, @event){
	if(reg_count('.*[ ]+.*', @event['player'])){
		modify_event('result', 'KICK_BANNED');
		modify_event('kickmsg', 'Unfortunately, usernames with spaces in them are not allowed on our servers.');
	}
}
