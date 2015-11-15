
if(import('sharedata.source') == null){
	console(color(RED).'Could not set up sharedata, please add'
		.' export(\'sharedata.source\', \'<server name>\')'
		.' to the server\'s main.ms.')
} else {
	console('ShareData: Setting server source to '.import('sharedata.source'))
}

# Poll loop for reading data
@lastRead = array(0)

set_interval(100, closure(
	@data = get_value('sharedata.data')
	@changes = false
	if(!is_array(@data)){
		@data = array()
	}
	@oldData = array()
	foreach(@data, @key, @piece,
		@timestamp = @piece['timestamp']
		if(@timestamp + 5000 < time()){
			# This data is old, so delete it after this round
			array_push(@oldData, @key)
		}
		if(@timestamp > @lastRead[0]){
			# This value hasn't been read. Update lastRead, then publish this data
			@lastRead[0] = @timestamp
			@source = import('sharedata.source')
			if(@piece['source'] != @source){
				@binds = import('sharedata.binds')
				if(!is_array(@binds)){
					@binds = array()
				}
				foreach(@binds, @bind,
					execute(@piece['data'], @bind)
				)
			}
		}
	)
	for(@i = array_size(@oldData) - 1, @i >= 0, @i--,
		@index = @oldData[@i]
		array_remove(@data, @index)
		@changes = true
	)
	if(@changes){
		store_value('sharedata.data', @data)
	}
))

