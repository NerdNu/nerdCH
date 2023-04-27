

bind('player_join', null, null, @event) {
	@player = @event['player'];
	if(array_contains(pgroup(@player), 'super') && import('sharedata.source') == 'pve') {
		@counter = array(0);
		set_interval(1000, closure() {
			@counter[0]++;
			if(@counter[0] > 15) {
				clear_task();
			}
			if(ponline(@player)) {
				clear_task();
				runas(@player, '/rg bypass');
			}
		});
	}
}