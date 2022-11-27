/**
 * Triggers an AOE marker at the given target, for the given time period in ms, and when finished,
 * runs the given closure. A list of players in the AOE circle will be sent to the closure.
 */
proc _fightUtilsAOE(@target, @radius, @totalTime, @closure) {
	_fightUtilsAOECore(@target, @radius, @totalTime, @closure, closure(@point) {
		spawn_particle(@point, array(particle: 'FIREWORKS_SPARK'));
	});
}

proc _fightUtilsAOEPoison(@target, @radius, @totalTime, @closure) {
	_fightUtilsAOECore(@target, @radius, @totalTime, @closure, closure(@point) {
		spawn_particle(@point, array(particle: 'WARPED_SPORE'));
	});
}

proc _fightUtilsAOEHunger(@target, @radius, @totalTime, @closure) {
	_fightUtilsAOECore(@target, @radius, @totalTime, @closure, closure(@point) {
		spawn_particle(@point, array(particle: 'DRIPPING_HONEY'));
	});
}

proc _fightUtilsAOEZombie(@target, @radius, @totalTime, @closure) {
	_fightUtilsAOECore(@target, @radius, @totalTime, @closure, closure(@point) {
		spawn_particle(@point, array(particle: 'SPELL_WITCH'));
	});
}

proc _fightUtilsAOEHearts(@target, @radius, @totalTime, @closure) {
	_fightUtilsAOECore(@target, @radius, @totalTime, @closure, closure(@point) {
		spawn_particle(@point, array(particle: 'HEART'));
	});
}

proc _fightUtilsAOEEntity(@target, @radius, @totalTime, @closure) {
	_fightUtilsAOECore(@target, @radius, @totalTime, @closure, closure(@point) {
		spawn_particle(@point, array(particle: 'FLAME'));
	}, false);
}

proc _fightUtilsAOECore(@target, @radius, @totalTime, @closure, @particleClosure, @players = true) {
	@target = @target[];
	@target[2] = @target['y'] = (@target['y'] + 3);
	@queue = 'thread'.rand();
	for(@i = 0, @i < ceil(@totalTime / 200), @i++) {
		queue_push(closure() {
			foreach(@point in _get_circle_points(@target, @radius, 0.25)) {
				execute(@point, @particleClosure);
			}
		}, @queue);
		queue_delay(200, @queue);
	}
	queue_push(closure() {
		if(@players) {
			execute(players_in_radius(@target, @radius - 0.5), @closure);
		} else {
			execute(entities_in_radius(@target, @radius), @closure);
		}
	}, @queue);
}

proc _get_circle_points(@target, @radius, @particleDistance) {
    @circle = array();
    for(@angle = 0, @angle < 6.282, @angle += @particleDistance) {
        @circle[] = array(
            x: @radius * cos(@angle) + @target['x'],
            y: @target['y'],
            z: @radius * sin(@angle) + @target['z'],
            world: @target['world'],
        );
    }
    return(@circle);
}