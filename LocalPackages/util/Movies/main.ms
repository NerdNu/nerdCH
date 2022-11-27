
Callable @checkPlayer = closure(@player) {
	if(pmode(@player) == 'SPECTATOR') {// && !has_permission('nerdch.level.admin')) {
		@movie = get_value('movie.playerinmovie.'.@player);
		if(@movie) {
			tmsg(@player, 'Uh oh! Something happened, your movie will be restarted now. Run /leave-movie to exit.');
			set_pmode(@player, 'SURVIVAL');
			set_peffect(@player, 'SLOW_FALLING', 10, 45);
			console(color('RED')."Player @player was affected by the recompile/restart, their movie \"@movie\" is being restarted.");
			import('movie.restart')(@movie, @player);
		}
	}
};

set_timeout(1000, closure() {
	foreach(@player in all_players()) {
		@checkPlayer(@player);	
	}
});

bind('player_join', null, null, @event, @checkPlayer) {
	set_timeout(1000, closure() {
		@checkPlayer(player());
	});
}