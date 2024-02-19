proc _locationConfiguration() {
	// For now, hardcoded, eventually make this configurable in game.
	if(!import('minigames.locations')) {
		@locations = associative_array();
		foreach(@value in array(
			// Lobby
			'minigameentrance'
		)) {
			@locations[@value] = get_value('minigames.locations.'.@value);
		}
		export('minigames.locations', @locations);
	}

	if(!import('minigames.regions')) {
		@regions = associative_array();
		foreach(@region in array(
			
		)) {
			@regions[@region] = get_value('minigames.regions.'.@region);
		}
		export('minigames.regions', @regions);
	}
}

proc _validateMinigameLocation(string @name) {
	_locationConfiguration();
	if(!array_index_exists(import('minigames.locations'), @name)) {
		die(color('RED').'Location name does not exist.');
	}
}

proc _validateMinigameRegion(string @name) {
	_locationConfiguration();
	if(!array_index_exists(import('minigames.regions'), @name)) {
		die(color('RED').'Region name does not exist.');
	}
}

proc _getMinigameLocation(string @name) {
	_locationConfiguration();
	return _normalizeLocation(import('minigames.locations')[@name]);
}

proc _getMinigameRegion(string @name) {
	_locationConfiguration();
	return import('minigames.regions')[@name][];
}

proc _getMinigameAssignLocationTabcompleter() {
	_locationConfiguration();
	return get_tabcomplete_prototype(array_keys(import('minigames.locations')));
}

proc _getMinigameAssignRegionTabcompleter() {
	_locationConfiguration();
	return get_tabcomplete_prototype(array_keys(import('minigames.regions')));
}

proc _getMinigameWhitelistTabCompleter() {
	return get_tabcomplete_prototype(get_value('minigames.whitelist') ||| array());
}