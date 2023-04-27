
/**
 * Called once at startup, and triggers the audio engine overrides.
 */
proc _startMusicEngine() {
	if(!import('music.engine.started')) {
		@world = _getGameWorld();
		@rand = rand();
		export('music.engine.threadid', @rand);
		x_new_thread('AudioEngine', closure() {
			int @i = 0;
			array @playersInWorld = array(all_players(@world));
			while(!x_is_interrupted()) {
				if(import('music.engine.threadid') != @rand) {
					console('Killing old audio engine thread');
					return;
				}
				@i++;
				if(@i > 10000000) {
					@i = 0;
				}
				sleep(0.25);
				if(@playersInWorld == null || @i % 10) {
					@playersInWorld = x_run_on_main_thread_now(closure() { return all_players(@world) });
				}
				x_run_on_main_thread_now(closure() {
					foreach(@player in @playersInWorld) {
						if(!ponline(@player)) {
							array_remove_values(@playersInWorld, @player);
							// Clear their music model so it doesn't get stuck on
							export('music.engine.model.'.@player, null);
							continue;
						}
						stop_sound(@player, 'MUSIC_GAME', 'MUSIC');
						stop_sound(@player, 'MUSIC_CREATIVE', 'MUSIC');
					}
				});
				foreach(@player in @playersInWorld) {
					_updatePlayerMusic(@player);
				}
			}
		});

		export('music.engine.started', true);
	}
}

proc _getMusicModel(@player) {
	@model = import('music.engine.model.'.@player) ||| array(
		currentSong: null,
		playsUntil: 0,
		stopPlayingIfNotInZone: null,
		playChance: 0,
		adhocPlaying: false,
		adhocRepeat: null,
		adhocNext: null,
	);
	export('music.engine.model.'.@player, @model);
	return @model;
}

proc _updatePlayerMusic(@player) {
	if(_isMusicMuted(@player)) {
		if(import('music.engine.debug')) {
			console('Music muted for '.@player);
		}
		// Music is muted for this player. Do nothing this round.
		return;
	}
	@data = import('music.engine.data');
	@model = _getMusicModel(@player);

	@getRegion = @data['meta']['regionLookup'];
	// First, list which zones the player is currently in, and get the highest priority one.
	@inZones = array();
	@priorityZone = null;
	@priorityZoneName = null;
	foreach(@zoneName: @zone in @data['zones']) {
		foreach(@region in @zone['regions']) {
			@bounds = x_run_on_main_thread_now(closure() { return execute(@region, @getRegion) });
			if(@bounds != null && ponline(@player) && _pointInRegion(ploc(@player), @bounds[0], @bounds[1])) {
				@inZones[@zoneName] = @zone;
				break;
			}
		}
	}

	if(@model['stopPlayingIfNotInZone'] != null) {
		if(!array_contains(array_keys(@inZones), @model['stopPlayingIfNotInZone'])) {
			x_run_on_main_thread_now(closure() { stop_named_sound(@player, @model['currentSong']); });
			@model['stopPlayingIfNotInZone'] = null;
			@model['playsUntil'] = 0;
			@model['currentSong'] = null;
			@model['playChance'] = 0;
		}
	}

	if(length(@inZones) == 1) {
		@priorityZoneName = array_keys(@inZones)[0];
		@priorityZone = @inZones[@priorityZoneName];
	} else if(length(@inZones) > 1) {
		@max = 0;
		foreach(@zoneName: @zone in @inZones) {
			@priority = array_get(@zone, 'priority', 0);
			if(@priority > @max) {
				@priorityZoneName = @zoneName;
				@priorityZone = @zone;
				@max = @priority;
			}
		}
	}

	if(@model['adhocPlaying'] && (@model['adhocRepeat'] || @model['adhocNext'])) {
		if(import('music.engine.debug')) {
			console(reflect_pull('line_num').' '.@model . ' time: ' . time());
		}
		if(time() < @model['playsUntil']) {
			// Music is still playing, nothing to do.
			return;
		}
		@adhocNext = @model['adhocNext'];
		@adhocRepeat = @model['adhocRepeat'];
		_stopMusic(@player);
		if(import('music.engine.debug')) {
			if(@adhocRepeat != null) {
				console(reflect_pull('line_num').' '.'Playing adhocRepeat song '.@adhocRepeat);
			} else {
				console(reflect_pull('line_num').' '.'Playing adhocNext song '.@adhocNext);
			}
		}
		@song = null;
		if(@adhocRepeat != null) {
			@song = @adhocRepeat;
			x_run_on_main_thread_now(closure() { play_named_sound(ploc(@player), array(sound: @adhocRepeat, channel: 'MUSIC'), @player); });
			@model['adhocRepeat'] = @song;
		} else {
			@song = @adhocNext;
			x_run_on_main_thread_now(closure() { play_named_sound(ploc(@player), array(sound: @adhocNext, channel: 'MUSIC'), @player); });
		}
		@model['playsUntil'] = time() + (@data['music'][@song]['length'] * 1000);
		@model['adhocPlaying'] = true;
		@model['currentSong'] = @song;
		return;
	}

	if(@priorityZone) {
		@eligibleMusic = if(@priorityZone['music'] instanceof string, array(@priorityZone['music']), @priorityZone['music']);
		if(array_get(@priorityZone, 'preempt', false)
				&& @model['currentSong'] != null
				&& !@model['adhocPlaying']
				&& !array_contains(@eligibleMusic, @model['currentSong'])) {
			// They have moved to a higher priority region, we need to stop this song and re-select
			if(import('music.engine.debug')) {
				console(reflect_pull('line_num').' '.@player.' '.@model);
			}
			x_run_on_main_thread_now(closure() { stop_named_sound(@player, @model['currentSong']); });
			@model['currentSong'] = null;
			@model['playsUntil'] = 0;
		}
		if(time() < @model['playsUntil']) {
			// Music is still playing, nothing to do.
			return;
		}

		@model['adhocPlaying'] = false;
		// console(@model);
		// No music is playing, do something!
		if(array_get(@priorityZone, 'repeat', false) || rand() + 0.1 < @model['playChance']) {
			// Select another song immediately
			@song = array_get_rand(@eligibleMusic);
			x_run_on_main_thread_now(closure() { play_named_sound(ploc(@player), array(sound: @song, channel: 'MUSIC'), @player); });
			@model['playChance'] = 0;
			@model['currentSong'] = @song;
			@model['playsUntil'] = time() + (@data['music'][@song]['length'] * 1000);
			if(array_get(@priorityZone, 'stopOnExit', false)) {
				@model['stopPlayingIfNotInZone'] = @priorityZoneName;
			}
		} else {
			// Add 0.01% to the playChance
			@model['stopPlayingIfNotInZone'] = null;
			@model['playsUntil'] = 0;
			@model['playChance'] += 0.001;
			@model['currentSong'] = null;
		}
		if(import('music.engine.debug')) {
			console(reflect_pull('line_num').' '.@player.' '.@model);
		}
	}
}

/**
 * This method is meant for "infinite loop" songs, which are specially created and annotated songs, which are
 * broken into 3 parts, an intro, a repeating looping middle, and an outro. The middle part is annotated with
 * precise moments when the song can be stopped and be musically coherent with the outro, which is then played
 * immediately after. With some margin of error for network latency and server load, this means that the song
 * can respond to dynamic events, making for a more immersive experience.
 */
proc _syncStopAndPlayNow(string @player, array @songData) {
	@model = _getMusicModel(@player);
	if(@model['currentSong'] == null) {
		// Nothing's playing, this is easy.
		_stopAndPlayNow(@player, @songData);
		return;
	}
	if(import('music.engine.debug')) {
		console(reflect_pull('line_num').' '."_syncStopAndPlayNow Playing @songData for @player with existing model @model");
	}
	@data = import('music.engine.data');
	@song = @model['currentSong'];
	@syncStop = @data['music'][@song]['length'];
	@songStartTime = @model['playsUntil'] - (@syncStop * 1000);
	// Default is just "the end of the song" if no syncStops were configured.
	@syncStops = array_get(@data['music'][@song], 'syncStops', array(@syncStop));
	// Find the next sync stop
	foreach(@time in @syncStops) {
		if(time() > (@time * 1000) + @songStartTime) {
			// We've already passed this one
			continue;
		} else {
			@syncStop = @time * 1000;
			break;
		}
	}

	// Found it, now configure the model to automatically repeat things for us.
	@model['playsUntil'] = @songStartTime + @syncStop;
	@model['adhocPlaying'] = true;
	if(array_get(@songData, 'repeat', false)) {
		@model['adhocRepeat'] = @songData['name'];
		@model['adhocNext'] = null;
	} else {
		@model['adhocNext'] = @songData['name'];
		@model['adhocRepeat'] = null;
	}
	if(import('music.engine.debug')) {
		console(reflect_pull('line_num').' '."_syncStopAndPlayNow ending with model:" . @model);
	}
}

/**
 * Potentially stops other music, and plays the given adhoc song immediately, for the given player. @songData
 * is an associative array with the following keys:
 * `name`: Required. The name of the song to play.
 * `preempt`: Defaults to false. If true, any other currently playing song (including previously triggered adhoc music) will be stopped.
 * `ignoreMutes`: Defaults to true. If false, will not play if the player's music is muted.
 * `repeat`: If this song should be played on repeat.
 */
proc _stopAndPlayNow(string @player, array @songData) {
	if(import('music.engine.debug')) {
		console(reflect_pull('line_num').' '.@player.' '.@songData);
	}
	if(!array_get(@songData, 'ignoreMutes', true) && _isMusicMuted(@player)) {
		return;
	}
	@data = import('music.engine.data');
	@model = _getMusicModel(@player);
	if(@model['currentSong']) {
		if(array_get(@songData, 'preempt', false)) {
			stop_named_sound(@player, @model['currentSong']);
		} else {
			// Do nothing, a higher priority song is playing, and we didn't preempt
			return;
		}
	}
	@song = @songData['name'];
	if(import('music.engine.debug')) {
		console(reflect_pull('line_num').' '."Playing @song for @player");
	}
	play_named_sound(ploc(@player), array(sound: @song, channel: 'MUSIC'), @player);
	@model['playChance'] = 0;
	@model['currentSong'] = @song;
	@model['playsUntil'] = time() + (@data['music'][@song]['length'] * 1000);
	@model['stopPlayingIfNotInZone'] = null;
	@model['adhocPlaying'] = true;
	@model['adhocRepeat'] = if(array_get(@songData, 'repeat', false), @song, null);
	if(import('music.engine.debug')) {
		console(reflect_pull('line_num').' '.@model);
	}
}

/**
 * Unconditionally stops any song currently playing for the current player. Note that this
 * will not stop a new song from playing. See _stopAndMuteMusic.
 */
proc _stopMusic(string @player) {
	@model = _getMusicModel(@player);
	if(@model['currentSong']) {
		stop_named_sound(@player, @model['currentSong']);
	}
	@model['stopPlayingIfNotInZone'] = null;
	@model['playsUntil'] = 0;
	@model['currentSong'] = null;
	@model['playChance'] = 0;
	@model['adhocPlaying'] = false;
	@model['adhocRepeat'] = null;
	@model['adhocNext'] = null;
}

/**
 * Unconditionally stops any song currently playing for the current player, and prevents new
 * music from starting, until _unmuteMusic is called for the player. Note that this mute
 * is persisted on disk.
 */
proc _stopAndMuteMusic(string @player) {
	_stopMusic(@player);
	@puuid = puuid(@player, true);
	store_value("music.engine.@puuid.muted", true);
}

/**
 * If the music had previously been muted for the given player, it is unmuted. Note that mutes
 * are persisted on disk.
 */
proc _unmuteMusic(string @player) {
	@puuid = puuid(@player, true);
	store_value("music.engine.@puuid.muted", false);
}

/**
 * Returns true if the music is muted for this player.
 */
proc _isMusicMuted(string @player) {
	@puuid = puuid(@player, true);
	return get_value("music.engine.@puuid.muted") ||| false;
}

/**
 * This function registers the data about the world and music files such that the audio engine can be automatically run.
 * This primarily consists of two types of data: information about the music tracks, and information about zones in the game world.
 * There is also a set of meta information describing how the generic structures can integrate with game specific parts.
 * Note that the game engine is capable of playing music in other circumstances, and in particular can trigger music with
 * generally the same conditions as here based on some dynamic game inputs, and this function only registers the setup
 * that is used for the automated system. Note however though, that all music that is triggered in either the automated system
 * or adhoc system must anyways be configured with the metadata for the tracks, so that these will be managed correctly otherwise.
 *
 * Each track knows two things, the name of the file to play, and the length of the track. Since the client is responsible for
 * playing music, the server does not inherently know anything about the music, and so needs additional hints to properly manage.
 * The length of the track is used to (hopefully) correctly schedule when the client is no longer playing music, and prevents clashes
 * between songs.
 *
 * Zones are a series of one or more regions that form a single, potentially non-cubic region, which allow the audio engine
 * to determine which tracks to play for a player in a given location in the game. Zones have priority as well, so a player
 * might be in multiple zones, but a smaller, inner zone, might take priority over the larger zone, allowing for flexible
 * and easy region configurations.
 * By default, the audio engine decides when to play a song, and then determines which song to play based on the player's
 * location, but each zone can be configured to immediately start playing a song upon player entry. Song repeat behavior can
 * also be configured. In Minecraft in general, music cannot be smoothly repeated, but every song must know its length, and
 * so this can be scheduled at roughly correct intervals.
 *
 * The @data object follows this schema. At the top level, there are three entries. `music`, `zones`, and `meta`.
 *
 * `meta` contains an associative array with the key `regionLookup` which should be a Callable<array, string> which accepts
 * a region name, and returns a length 2 array with the region boundary for a given location.
 *
 * `music` is an associative array of associative arrays. The key of this array is the song name, and the value is a sub array.
 *     `length` is the length of the track, in seconds.
 *     `syncStops` is an array of integers, which represent times (in seconds) in the song when the song can be stopped in a musically consistent way.
 *
 * `zones` is the most complex object. This is an associative array, where the key is the name of the zone, and each value is an associative
 * array. These contain several fields, many of which are optional.
 * `regions`: This is an array of one or more actual region names for this zone. These regions can be looked up with the `regionLookup` function. Required.
 * `music`: A string or array of strings containing the song name(s) to play in this region. Must be one of the songs listed in the `music` top
 *     level key.
 * `priority`: The priority. If a player is in multiple zones, the zone with the highest priority number wins. Defaults to 0.
 * `playOnEnter`: If true, music will be selected and played as soon as the player is detected in the region, stopping other music if necessary. Defaults to false.
 * `stopOnExit`: If true, music will stop playing when the player leaves the triggering region. Defaults to false.
 * `repeat`: If true, as soon as the music stops playing, more music is selected to be played. Normally, music is only randomly selected to be played,
 *     and silence is allowed.
 * `preempt`: If the player enters this zone, and music from a lower priority region is playing, this will stop the previous song if it otherwise would
 *     play a song now.
 */
proc _registerMusicData(array @data) {
	if(@data['meta']['regionLookup'] notinstanceof Callable) {
		throw(IllegalArgumentException, '[meta][regionLookup] must be a Callable<array, string>');
	}
	export('music.engine.data', @data[]);
	set_timeout(50, closure() {
		foreach(@player in all_players(_getGameWorld())) {
			foreach(@song: @length in @data['music']) {
				// Stop everything, so we return to a known state
				stop_named_sound(@player, @song);
			}
		}
	});
}