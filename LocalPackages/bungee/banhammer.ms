bind('player_join', null, null, @event) {
	if(import('activate.banhammer') && @event['first_login']) {
		_sendPluginMessage(player(), 'BungeeCord', array('MCBouncer', 'ban', player(), "Compromised account"));
	}
}