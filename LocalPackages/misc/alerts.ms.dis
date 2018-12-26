# _get_alerts()
#	Return a non-null array of strings containing the alert messages.

proc(_get_alerts,
        @alerts = get_value('server.alerts.messages');
        return (if (is_null(@alerts), array(), @alerts));
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
			broadcast(color(@a[color]).'[Server] '.@a[msg]);
		} else {
			broadcast(color(LIGHT_PURPLE).'[Server] '.@alerts[@index]);
		}
		store_value('server.alerts.index', @index + 1);
	))

	console('Starting alerts with task ID '.@task);
	store_value('server.alerts.task', @task);
)

