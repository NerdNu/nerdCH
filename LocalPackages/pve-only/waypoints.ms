bind(player_death, null, null, @e,
	try(
		tmsg(@e[player], color(GOLD). 'Do ' . color(YELLOW) . '/wp death' . color(GOLD) . ' for your most recent death coordinates.');
		@uuid = puuid(player(), true);
		@waypoints = get_value('waypoints', @uuid);
		if(@waypoints == null) {
			@waypoints = array();
		}
		array_set(@waypoints, 'death', array('loc': @e[location], 'mode': private));
		store_value('waypoints', @uuid, @waypoints);
	, @ex,
		console('Error adding death waypoint: ' . @ex);
	);
);
