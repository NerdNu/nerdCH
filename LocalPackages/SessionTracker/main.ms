bind('player_join', null, null, @event,
	@session_number=get_value('session_number.'.player())+1
	store_value('session_number.'.player(), @session_number)
	store_value('session_start.'.player(), time())
)

bind('player_quit', null, null, @event,
	@session_number=get_value('session_number.'.player())
	@session_start=get_value('session_start.'.player())
	console('SessionTracker: '.player().','.@session_number.','.@session_start.','.(time()-@session_start))
)
