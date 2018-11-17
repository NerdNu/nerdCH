# _koth_king()
#
# Return the team ID (0 - 15) of the current King of the Hill - the team who has
# placed their block in the scoring location. Return -1 if nobody holds that block.

proc(_koth_king,
	@location = get_value('koth.location')
	if (!is_null(@location)) {
		@block = get_block_at(@location)
		@fields = split(':', @block)
		@id = @fields[0]
		@data = @fields[1]
		if (@id == 35) {
			return (@data)
		}
	}
	return (-1)
)


# _koth_score_get()
#
# Get the array of scores, which are the number of seconds that each team (0 - 15)
# has held the scoring block.

proc(_koth_score_get,
	@times = get_value('koth.times')
	if (is_null(@times)) {
		@times = array()
		array_resize(@times, 16, 0)
	}
	return (@times)
)


# _koth_score_clear()
#
# Reset the accumulated time (score) for all teams to 0.
# Return the initialised times array.

proc(_koth_score_clear,
	@times = array()
	array_resize(@times, 16, 0)
	store_value('koth.times', @times)
	return (@times)
)


# _koth_score_show()
#
# Show the current score.

proc(_koth_score_show,
	# The chat color corresponding to a particular team ID (wool data value) from 0 - 15.
	@COLOR = array(
		color(WHITE), color(GOLD), color(LIGHT_PURPLE), color(BLUE), 
		color(YELLOW), color(GREEN), color(LIGHT_PURPLE), color(DARK_GRAY), 
		color(GRAY), color(DARK_AQUA), color(DARK_PURPLE), color(DARK_BLUE),
		color(BROWN), color(DARK_GREEN), color(DARK_RED), color(BLACK)
	)
	@NAME = array(
		'White', 'Orange', 'Magenta', 'Light Blue', 'Yellow', 'Lime', 'Pink', 'Dark Gray',
		'Light Gray', 'Dark Cyan', 'Purple', 'Blue', 'Brown', 'Green', 'Red', 'Black'
	)
	@times = _koth_score_get()
	@message = color(GOLD).'Time held (seconds): '
	@teams = get_value('koth.teams')
	if (is_null(@teams)) {
		@teams = array(11, 14)
		store_value('koth.teams', @teams)
	}
	for (@i = 0, @i < 16, inc(@i),
		if (array_contains(@teams, @i)) {
			@message = @message.@COLOR[@i].@NAME[@i].color(WHITE).': '.color(GRAY).@times[@i].'  '
		}
	)
	msg(@message)
)


# _koth_reset()
#
# Clear the accumulated scores.
# If a team block (wool) is at the scoring location, set that block to air.

proc(_koth_reset,
	_koth_score_clear()
	@team = _koth_king()
	if (@team >= 0) {
		# If there is a King, the location is valid.
		@location = get_value('koth.location')
		set_block_at(@location, 0)
	}
)


# _koth_stop()
#
# Stop the scorekeeping task.

proc(_koth_stop,
	@task = get_value('koth.task')
	if (! is_null(@task)) {
		clear_task(@task)
	}
)	


# _koth_start()
#
# Start a task to periodically check for the presence of a wool block at 
# the 'koth.block' location.  Add to the score of whichever team has their 
# wool colour there.

proc(_koth_start,
	# Period between checks in seconds.
	@CHECK_PERIOD = 1

	_koth_stop()
	@task = set_interval(@CHECK_PERIOD * 1000, 0, closure(
		@team = _koth_king()
		if (@team >= 0) {
			@times = _koth_score_get()
			inc(@times[@team], @CHECK_PERIOD)
			store_value('koth.times', @times)
		}
	))
	store_value('koth.task', @task)
)
