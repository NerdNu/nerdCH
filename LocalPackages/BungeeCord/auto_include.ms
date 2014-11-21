proc(_writeUTF, @ba, @str,
	@len = length(@str)
	if (@len > 200) {
		die('String too long')
	}
	ba_put_byte(@ba, 0)
	ba_put_byte(@ba, @len)
	ba_put_bytes(@ba, string_get_bytes(@str, 'ascii'))
)

proc(_changeserver, @player, @server,
	@ba = byte_array()
	_writeUTF(@ba, 'Connect')
	_writeUTF(@ba, @server)

	@servers = array('creative', 'pve', 'survival', 'lobby')
	if (array_contains(@servers, to_lower(@server)) && to_lower(@server) != import('sharedata.source'), 
		unbind('bc-'.@player)
		bind(player_quit, array(priority: normal, id: 'bc-'.@player), array(player: @player), @event, @server,
			modify_event('message', color(yellow). @event['player'] . ' has switched to ' . @server)
			unbind()
		)
	)
	send_plugin_message(@player, 'BungeeCord', @ba)
)

proc(_sendPluginMessage, @player, @channel, @messages,
	if (@player != '~console') {
		@ba = byte_array()
		foreach (@messages, @message,
			_writeUTF(@ba, @message)
		)
		send_plugin_message(@player, @channel, @ba)
	}
)
