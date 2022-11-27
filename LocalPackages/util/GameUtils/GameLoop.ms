

/**
 * The game loop affects players in the game managed world. Any activities that
 * spill out into other worlds cannot be managed via the game loop, since this is
 * an expensive activity. True is returned if the game loop is actually started successfully,
 * all other values should be considered false.
 */
proc _startGameLoop() {
	if(!import('gameloopconfigured')) {

		export('game.loop.count', 0);
		Callable @loopHandler = iclosure(@loopName) {
			@loops = import(@loopName, array());
			foreach(@handler in @loops) {
				try {
					@handler();
				} catch(Exception @ex) {
					console(@ex);
				}
			}
		}
		set_interval(1000, closure() {
			int @loopCount = import('game.loop.count');
			if(@loopCount > 10000) {
				@loopCount = 0;
			}

			// Fast loop
			@loopHandler('game.loop.fast');

			if(@loopCount % 5 == 0) {
				@loopHandler('game.loop.normal');
			}

			if(@loopCount % 10 == 0) {
				@loopHandler('game.loop.slow');
			}

			export('game.loop.count', ++@loopCount);
		});

		_startMusicEngine();

		export('gameloopconfigured', true);
	}
	return true;
}

proc _registerFastGameLoop(Callable @callable) {
	array @loop = import('game.loop.fast', array());
	@loop[] = @callable;
	export('game.loop.fast', @loop);
}

proc _registerGameLoop(Callable @callable) {
	array @loop = import('game.loop.normal', array());
	@loop[] = @callable;
	export('game.loop.normal', @loop);
}

proc _registerSlowGameLoop(Callable @callable) {
	array @loop = import('game.loop.slow', array());
	@loop[] = @callable;
	export('game.loop.slow', @loop);
}