@forbiddenRegions = associative_array(
	// Return true if the player has access, false otherwise
	// regionName: closure(@player) {
	// 	return true;
	// },
);

proc _checkForbiddenRegions(@player, @forbiddenRegions) {
	if(!ponline(@player)) {
		return();
	}

	// TODO: Keep all non-whitelisted players out of the minigamelobby world for now, but remove this once it's open
	// @whitelisted = array('iceberg76', 'Haiku', 'admanta', 'LadyCailin');
	@whitelisted = get_value('minigames.whitelist')
	if((pworld(@player) == 'minigamelobby' || pworld(@player) == 'world_mod') && !has_permission(@player, 'nerdch.level.mod') && !array_contains(@whitelisted, @player)) {
		console("minigames: @player is in a location they shouldn't be!");
		runas(@player, '/spawn');
		return;
	}

	if(import("minigames.forbiddenoverride.@player")) {
		// Admin, they're allowed.
		return();
	}

	foreach(@regionName: @logic in @forbiddenRegions) {
		@regionBounds = _getMinigameLocation(@regionName);
		if(@regionBounds notinstanceof array) {
			// Not defined yet
			continue;
		}
		@ploc = _normalizeLocation(ploc(@player));
		@ploc['y']++;
		if(_pointInRegion(@ploc, @regionBounds[0], @regionBounds[1])) {
			// They are in the region, are they supposed to be?
			if(!(@logic(@player))) {
				// They aren't, tp them out
				set_ploc(@player, _getMinigameLocation(@regionName . 'warp'));
				console("minigames: @player is in a location they shouldn't be!");
				return();
			}
		}
	}
}

set_interval(1000, closure() {
	if(queue_running('forbiddenRegionsCheck')) {
		return();
	}
	foreach(@player in all_players()) {
		queue_push(closure() {
			_checkForbiddenRegions(@player, @forbiddenRegions);
		}, 'forbiddenRegionsCheck');
		queue_delay(50, 'forbiddenRegionsCheck');
	}
})
