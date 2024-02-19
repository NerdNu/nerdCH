bind('player_interact', null, array(itemname: 'SADDLE', button: 'right'), @event) {
	if(_3d_distance(pcursor(), ploc()) > 5) {
		return();
	}
	@allowed = array('AXOLOTL', 'CAT', 'CHICKEN', 'COD', 'COW', 'FOX', 'GOAT', 'LLAMA', 'MUSHROOM_COW', 'OCELOT', 'PANDA', 'POLAR_BEAR', 'RABBIT', 'SALMON',
		'SHEEP', 'SQUID', 'TROPICAL_FISH', 'TURTLE', 'WOLF');
	if(array_contains(pgroup(), 'super')) {
		@allowed[] = 'PLAYER';
		@allowed[] = 'BEE';
	}
	@entities = entities_in_radius(pcursor(), 2, @allowed);
	if(length(@entities) > 0) {
		@entity = array_rand(@entities, 1, false)[0];
		@type = entity_type(@entity);
		if(!array_contains(@allowed, @type)) {
			return();
		}
		if(@entity == puuid()) {
			return;
		}
		if(is_entity_living(@entity)) {
			set_entity_rider(@entity, puuid());
		}
	}
}