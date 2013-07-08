proc(_start_alerts,
	@seconds = get_value('server.alerts.seconds')
	if (is_null(@seconds)) {
		@seconds = 200
		store_value('server.alerts.seconds', @seconds)
	}

	@task = set_interval(@seconds * 1000, closure(
		@alerts = get_value('server.alerts.messages')
		if (is_null(@alerts) || array_size(@alerts) == 0) {
			# No messages to broadcast.
			die()
		}
		@index = get_value('server.alerts.index')
		if (is_null(@index)) {
			@index = 0
		}
		@index = mod(@index, array_size(@alerts))
		broadcast(color(LIGHT_PURPLE).'[Server] '.@alerts[@index])
		store_value('server.alerts.index', @index + 1)
	))

	console('Starting alerts with task ID '.@task)
	store_value('server.alerts.task', @task)
)

