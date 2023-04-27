
/**
 * Returns an array of points moving from the start location, forward, the given distance, in the given number of steps,
 * in the given world.
 */
proc _movieTweenForward(@start, @steps, @distance) {
	array @array = array();
	@world = @start['world'];
	@vector = get_vector(array(yaw: @start['yaw'], pitch: @start['pitch'], world: @world), @distance / @steps);
	// msg(@vector);
	for(int @i = 0, @i < @steps, @i++) {
		@array[] = array(
			x: @start['x'] + (@vector['x'] * @i),
			y: @start['y'] + (@vector['y'] * @i),
			z: @start['z'] + (@vector['z'] * @i),
			yaw: @start['yaw'],
			pitch: @start['pitch'],
			world: @world
		);
	}
	return(@array);
}

/**
 * Tweens between two points in a linear fashion. x, y, z, yaw, and pitch are all considered as part of the algorithm.
 */
proc _movieTweenBetween(array @start, array @finish, int @steps) {
	@xInc = (@finish['x'] - @start['x']) / @steps;
	@yInc = (@finish['y'] - @start['y']) / @steps;
	@zInc = (@finish['z'] - @start['z']) / @steps;
	// Special logic here, since yaw specifically wraps around.
	// We want to go the shorter distance, if start > 180 and end is < 180, which actually counts up.
	if(@start['yaw'] > 180 && @finish['yaw'] < 180) {
		@yawInc = (360 - @start['yaw'] + @finish['yaw']) / @steps;
	} else {
		@yawInc = (@finish['yaw'] - @start['yaw']) / @steps;
	}
	@pitchInc = (@finish['pitch'] - @start['pitch']) / @steps;
	array @array = array(array(skippable: false, complex: @start));
	@skippable = false;
	for(int @i = 1, @i < @steps - 1, @i++) {
		@array[] = array(
			skippable: @skippable,
			complex: array(
				x: @array[@i - 1]['complex']['x'] + @xInc,
				y: @array[@i - 1]['complex']['y'] + @yInc,
				z: @array[@i - 1]['complex']['z'] + @zInc,
				yaw: @array[@i - 1]['complex']['yaw'] + @yawInc,
				pitch: @array[@i - 1]['complex']['pitch'] + @pitchInc
			)
		);
		@skippable = !@skippable;
	}
	@array[] = array(skippable: false, complex: @finish);
	return @array;
}

proc _movieReset(string @player) {
	@movieId = get_value('movie.playerinmovie.'.@player)
	if(@movieId) {
		clear_task(import('moviefor.'.@player));
		set_timeout(50, closure() {
			try(unbind(get_value('movie.playerinmovie.'.@player.'.movebind')));
			try(set_pflying(@player, false));
			set_pflight(@player, false);
			// console('setting player loc '.import('movie.restartlocation')(@movieId, @player));
			set_ploc(@player, import('movie.restartlocation')(@movieId, @player));
			@mode = if(import('movie.restartMode') instanceof Callable, import('movie.restartMode')(@movieId, @player), 'SURVIVAL');
			console("Setting mode @mode");
			set_pmode(@player, @mode);
			clear_value('movie.playerinmovie.'.@player);
			clear_value('movie.playerinmovie.'.@player.'.movebind');
			_stopMusic(@player);
		});
	} else {
		die('Republic credits? Republic credits are no good out here.');
	}
}

/**
 * Called automatically, ensures various safeguards are set up.
 */
proc _movieInit() {
	if(import('movie.init')) {
		return();
	}

	bind('player_join', null, null, @event) {
		if(get_value('movie.playerinmovie.'.player())) {
			// Oops, they logged out during the credits, they will be restarted elsewhere.
			return();
		}

		if(!array_contains(pgroup(), 'super')) {
			if(pworld() != 'mapworld' && pmode() != 'SURVIVAL') {
				@player = player();
				set_timeout(50, closure() {
					if(phas_flight(@player)) {
						set_pflying(@player, false);
						set_pflight(@player, false);
					}
					set_peffect(player(), 'SLOW_FALLING', 10000, 45);
					set_pmode('SURVIVAL');
				});
			}
		} else {
			if(pmode() == 'SPECTATOR')  {
				@ploc = ploc();
				set_timeout(200, closure() {
					set_pflight(true);
					set_pflying(true);
					set_ploc(@ploc);
				});
			}
		}
	}
	export('movie.init', true);
}

/**
 * Given an array of actions, and a single action, injects the action into the array
 * at the given percentage. For instance, if the actions array has 10 events, and @at
 * is 0.5, the given action will be injected into the fifth spot (other events will
 * be pushed right). The action is added in place, and a reference to the array is
 * returned.
 */
proc _movieInjectEvent(array @actions, auto @action, double @at) {
	int @id = min(floor(length(@actions) * @at), length(@actions) + 1);
	array_insert(@actions, @action, @id);
	return @actions;
}

/**
 * Injects multiple, individual events at the given locations. @actions is the action
 * array, and @events is an array of length 2 arrays, first the action, then the location
 * to inject, as if it were the @at event. Each one is injected from right to left, to
 * ensure they fit in the expected locations. @actions is returned.
 */
proc _movieInjectEvents(array @actions, array @events) {
	@events = @events[];
	array_reverse(@events);
	foreach(@event in @events) {
		_movieInjectEvent(@actions, @event[0], @event[1]);
	}
	return @actions;
}

/**
 * Given an array of actions, executes these as a movie. A movie is a sequence where the player
 * is put into specator mode, moved to the resetLocation, runs the actions, then moved back
 * to the reset location, and put back into survival mode, with additional precautions to ensure
 * they do not remain in spectator.
 * The movieId is an internal identifier for the given movie. If a player logs out in the middle
 * of the movie, then upon login, the movie will restart with the given movie, by calling
 * a closure that should be exported to "movie.restart", and accept a string, then properly
 * retrigger the specified movie. It's important to also set a "movie.restartlocation" handler
 * as well, which provides the reset location for when the user runs /leave-movie. The endMode
 * is the mode they get put in when the movie is over, by default SURVIVAL.
 *
 * For each action, it may be one of the following types:
 * array: Assumed to be a location array, which the player is moved to.
 * integer: A delay in the queue
 * string: If it starts with @, a large title, otherwise a subtitle
 * closure: The closure will be executed
 *
 * Note that the "framerate" is pegged to 20 FPS, but by default, all frames are marked as unskippable,
 * meaning that in practice, unless otherwise configured, the framerate will be slower. However, for
 * skippable frames, if the system detects that it's behind, it will skip as many skippable frames as necessary
 * to recover to the original framerate. In order to configure a frame as skippable, send an action such as this:
 * array(skippable: true, complex: @originalAction), where @originalAction is the action that would have been
 * provided before.
 *
 * @resetLocation can be an associative array with two keys, 'start' and 'end'.
 */
proc _movieStart(array @actions, string @player, array @resetLocation, string @movieId, string @endMode = 'SURVIVAL') {
	_movieInit();
	if(!ponline(@player)) {
		return;
	}
	// @queue = 'moviefor'.@player;
	@startLoc = @resetLocation;
	@endLoc = @resetLocation;
	if(is_associative(@resetLocation) && array_index_exists(@resetLocation, 'start') && array_index_exists(@resetLocation, 'end')) {
		@startLoc = @resetLocation['start'];
		@endLoc = @resetLocation['end'];
	}

	@move = bind('player_move', null, array(player: @player), @event) {
		cancel();
	}
	store_value('movie.playerinmovie.'.@player.'.movebind', @move);
	store_value('movie.playerinmovie.'.@player, @movieId);
	set_ploc(@player, @startLoc);
	// runas(@player, '/hud off');

	set_pmode(@player, 'SPECTATOR');
	set_timeout(200, closure() {
		set_pflight(@player, true);
		set_pflying(@player, true);
		set_ploc(@player, @startLoc);
	});

	@parsedActions = array();
	foreach(@action in @actions) {
		@skippable = false;
		if(is_array(@action) && array_index_exists(@action, 'complex')) {
			// Complex action
			@skippable = array_get(@action, 'skippable', false);
			@action = @action['complex'];
		}
		@parsedActions[] = array(
			skippable: @skippable,
			action: @action,
		);
	}

	@parsedActions[] = array(
		skippable: false,
		action: closure() {
			unbind(@move);
			set_pmode(@player, 'SURVIVAL');
			set_ploc(@player, @endLoc);
		}
	);

	@intervalId = array();

	@quit = bind('player_quit', null, array(player: @player), @event, @player, @move, @intervalId) {
		console('Clearing queue for ' . @player);
		if(length(@intervalId) > 0) {
			clear_task(@intervalId[0]);
		}
		unbind(@move);
		unbind();
	}

	@parsedActions[] = array(
		skippable: false,
		action: closure() {
			unbind(@quit);
			clear_value('movie.playerinmovie.'.@player);
		}
	)

	@startTime = time();
	@actionIndex = array(0);
	@delayUntil = array(0);
	@fps = 20;

	console('starting interval, length: ' . length(@parsedActions));
	// The interval runs at twice the framerate so we don't have sampling issues,
	// but it means we also have to provide a "not before" mechanism to keep the
	// correct framerate.
	@intervalId[] = set_interval(1000 / @fps / 2, closure() {
		if(time() < @delayUntil[0]) {
			return;
		}
		// Pump action
		@index = @actionIndex[0];
		@notBefore = @startTime + (1000 / @fps * (@index - 1));
		if(time() < @notBefore) {
			return;
		}
		if(@index >= length(@parsedActions)) {
			clear_task();
			return;
		}
		@action = @parsedActions[@index];
		@run = true;
		if(@action['skippable']) {
			// Skippable action. Are we behind? If so, skip.
			@expectedTime = @startTime + (1000 / @fps * @index);
			
			@time = time();
			if(@time > @expectedTime) {
				// Yes, skip.
				// console('Running behind, movie frame skip.');
				@run = false;
			} else if(@time < @notBefore) {
				// 
			}
		}

		if(@run) {
			@action = @action['action'];
			if(!ponline(@player)) {
				console('Clearing queue for ' . @player);
				clear_task();
				return;
			}

			if(is_array(@action)) {
				// Location
				set_ploc(@player, @action);
			} else if(is_integer(@action)) {
				// delay
				@delayUntil[0] = time() + @action;
			} else if(is_string(@action)) {
				// title
				if(@action[0] == '@') {
					title(@player, @action[1..], '', 20, 100, 10);
				} else {
					title(@player, '', @action, 20, 100, 10);
				}
			} else if(is_closure(@action)) {
				execute(@action);
			}
		}
		@actionIndex[0]++;
	});

	export('moviefor.'.@player, @intervalId[0]);

	// queue_delay(2000, @queue);
	// foreach(@action in @actions) {
	// 	queue_push(closure(){
	// 		if(!ponline(@player)) {
	// 			// Something happened, and the queue didn't clear, so just clear it now.
	// 			console('Clearing queue for ' . @player);
	// 			queue_clear(@queue);
	// 			return();
	// 		}
	// 		// stop_sound(@player, 'MUSIC_GAME', 'MUSIC');
	// 	}, @queue);
		// if(is_array(@action)) {
		// 	// Location
		// 	queue_push(closure() {
		// 		set_ploc(@player, @action);
		// 	}, @queue);
		// 	queue_delay(50, @queue);
		// } else if(is_integer(@action)) {
		// 	// delay
		// 	queue_delay(@action, @queue);
		// } else if(is_string(@action)) {
		// 	// title
		// 	queue_push(closure() {
		// 		if(@action[0] == '@') {
		// 			title(@player, @action[1..], '', 20, 100, 10);
		// 		} else {
		// 			title(@player, '', @action, 20, 100, 10);
		// 		}
		// 	}, @queue);
		// } else if(is_closure(@action)) {
		// 	queue_push(@action, @queue);
		// }
	// }
	// queue_push(closure() {
		// unbind(@move);
		// set_pmode(@player, 'SURVIVAL');
		// set_ploc(@player, @endLoc);
	// }, @queue);

	// queue_push(closure() {
		// unbind(@quit);
		// clear_value('movie.playerinmovie.'.@player);
	// }, @queue);

}