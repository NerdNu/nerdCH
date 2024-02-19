
Callable @fixSpectator = iclosure(@player) {
	if(!array_contains(pgroup(@player), 'super') && import('sharedata.source') != 'creative') {
		if(pworld(@player) != 'mapworld' && pmode(@player) != 'SURVIVAL') {
			set_timeout(50, closure() {
				if(phas_flight(@player)) {
					set_pflying(@player, false);
					set_pflight(@player, false);
				}
				set_peffect(@player, 'SLOW_FALLING', 10000, 45);
				set_pmode(@player, 'SURVIVAL');
			});
		}
	} else {
		if(pmode(@player) == 'SPECTATOR')  {
			@ploc = ploc(@player);
			set_timeout(200, closure() {
				set_pflight(@player, true);
				set_pflying(@player, true);
				set_ploc(@player, @ploc);
			});
		}
	}
};

bind('player_join', null, null, @event, @fixSpectator) {
	@fixSpectator(player());
}

bind('world_changed', null, null, @event, @fixSpectator) {
	@fixSpectator(player());
}