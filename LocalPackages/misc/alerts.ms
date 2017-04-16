# _get_alerts()
#	Return a non-null array of strings containing the alert messages.

proc(_get_alerts,
        @alerts = get_value('server.alerts.messages');
        return (if (is_null(@alerts), array(), @alerts));
)

# _broadcast_alert()
#	Broadcast alerts to all players unless they opt-out
proc(_broadcast_alert, @msg,
	foreach (@player in all_players()) {
		@uuid = replace(puuid(@player), '-', '');
		@opt_out = get_value('server.alerts.optout.' . @uuid);
		if (is_null(@opt_out)) {
			tmsg(@player, @msg);
		}
	}
)


# _start_alerts()
#	Start the timer callback that broadcasts alerts.

proc(_start_alerts,
	@seconds = get_value('server.alerts.seconds');
	if (is_null(@seconds)) {
		@seconds = 200;
		store_value('server.alerts.seconds', @seconds);
	}

	@task = set_interval(@seconds * 1000, closure(
		@alerts = _get_alerts();
		if (array_size(@alerts) == 0) {
			# No messages to broadcast.
			die();
		}
		@index = get_value('server.alerts.index');
		if (is_null(@index)) {
			@index = 0;
		}
		@index = mod(@index, array_size(@alerts));
		if (is_array(@alerts[@index])) {
			@a = @alerts[@index];
			_broadcast_alert(color(@a[color]).'[Server] '.@a[msg]);
		} else {
			_broadcast_alert(color(LIGHT_PURPLE).'[Server] '.@alerts[@index]);
		}
		store_value('server.alerts.index', @index + 1);
	))

	console('Starting alerts with task ID '.@task);
	store_value('server.alerts.task', @task);
)

