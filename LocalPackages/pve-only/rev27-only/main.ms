bind('player_interact', null, null, @event) {
	include('../../utility/playersInCuboid.ms');
	if(!array_index_exists(@event, 'location')) {
		return();
	}
	@loc = @event['location'];
	if(@loc['world'] != 'world') {
		return();
	}
	if(@loc['y'] != 92) {
		return();
	}
	if(@loc['x'] < -28 || @loc['x'] > -13) {
		return();
	}
	if(@loc['z'] < -28 || @loc['z'] > -13) {
		return();
	}

	@buttonX = floor(@event['location']['x']);
	@buttonZ = floor(@event['location']['z']);
	@signX = 0;
	@signZ = 0;
	@buttonXtoSignY = array(
		-28: 92, -27: 91, -26: 90, -25: 89,
		-24: 92, -23: 91, -22: 90, -21: 89,
		-20: 92, -19: 91, -18: 90, -17: 89,
		-16: 92, -15: 91, -14: 90, -13: 89,
	)
	@offset = (28 + @buttonZ);
	if(@buttonX >= -28 && @buttonX <= -21) {
		// concrete
		@signX = -13;
		if(@buttonX < -24) {
			@signZ = -5;
		} else {
			@signZ = -3;
		}
		@signX -= @offset;
	} else if(@buttonX > -21 && @buttonX <= -13) {
		// terracotta
		@signZ = -13;
		if(@buttonX >= -20 && @buttonX <= -17) {
			@signX = -5;
		} else {
			@signX = -3;
		}
		@signZ -= @offset;
	}
	@signY = @buttonXtoSignY[@buttonX];
	@signLoc = array(@signX, @signY, @signZ, 'world');
	if(is_sign_at(@signLoc)) {
		@destination = strip_colors(get_sign_text(@signLoc)[1]);
		@broadcast = _playersInCuboid(
			array(-29, 87, -29, 'world'),
			array(-12, 93, -12, 'world')
		)
		foreach(@player in @broadcast) {
			play_note(@player, 'CHIME', array(octave: 2, tone: "F#"));
		}
		set_timeout(750, closure() {
			foreach(@player in @broadcast) {
				play_note(@player, 'CHIME', array(octave: 1, tone: 'D'));
			}
		});
		@sign1 = array(-20, 89, -18, 'world');
		@sign2 = array(-21, 89, -18, 'world');
		if(is_sign_at(@sign1) && is_sign_at(@sign2)) {
			if(length(@destination) == 2) {
				set_sign_text(@sign1, '', color('DARK_RED').'DANGER, RAIL OUT!');
			} else {
				set_sign_text(@sign1, '', 'Now boarding for');
			}
			set_sign_text(@sign2, '', color('DARK_BLUE').@destination);
		}
		if(length(@destination) == 2) {
			broadcast(color('LIGHT_PURPLE').'All aboard! The train to nowhere is now boarding! (' . @destination . ')', @broadcast);
		} else {
			broadcast(color('LIGHT_PURPLE').'All aboard! The train bound for ' . color('RED') . @destination . color('LIGHT_PURPLE') . ' is now boarding!', @broadcast);
		}
	}
}

set_interval(2000, closure() {
	@sign1 = array(-20, 89, -18, 'world');
	if(is_sign_at(@sign1)) {
		@text = strip_colors(get_sign_text(@sign1)[1]);
		if(@text == 'DANGER, RAIL OUT!' || @text == '') {
			set_timeout(1500, closure() {
				@text = strip_colors(get_sign_text(@sign1)[1]);
				if(@text == 'DANGER, RAIL OUT!') {
					set_sign_text(@sign1, '', '');
				}
			});
			if(@text == 'DANGER, RAIL OUT!') {
				set_sign_text(@sign1, '', '');
			} else {
				set_sign_text(@sign1, '', color('DARK_RED').'DANGER, RAIL OUT!');
			}
		}
	}
});
