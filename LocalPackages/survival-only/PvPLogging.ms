bind(player_quit, null, null, @event,
	@loc = ploc(); // @event['location'];
	console(@event['player'] . ' logged out at ([' . @loc['world'] . '] ' . @loc['x'] . ', ' . @loc['y'] . ', ' . @loc['z'] . ')');
);

