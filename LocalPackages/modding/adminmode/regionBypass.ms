

bind('player_join', null, null, @event) {
	@player = @event['player'];
	if(array_contains(pgroup(@player), 'super')) {
		@counter = array(0);
		set_interval(1000, closure() {
			@counter[0]++;
			if(@counter[0] > 15) {
				clear_task();
			}
			if(ponline(@player)) {
				clear_task();
				if(!get_value('adminmode.'.puuid(@player, true).'.sticky')) {
					run('/rg bypass');
					if(array_contains(pgroup(@player), 'superduper')) {
						run('/luckperms user '.player().' parent remove superduper');
					}
				}
			}
		});
	}
}