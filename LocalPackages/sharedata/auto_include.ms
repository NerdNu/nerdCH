
/**
 * Stores a global shared value among the servers.
 */
proc(_store_shared_value, @value,
	@source = import('sharedata.source')
	@data = get_value('sharedata.data')
	if(!is_array(@data)){
		@data = array()
	}
	@piece = array(timestamp: time(), source: @source, data: @value)
	array_push(@data, @piece)
	store_value('sharedata.data', @data)
)

proc(_bind_shared_value, @closure,
	@binds = import('sharedata.binds')
	if(!is_array(@binds)){
		@binds = array()
	}
	array_push(@binds, @closure)
	export('sharedata.binds', @binds)
)
