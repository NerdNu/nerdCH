
if(import('global-list')) {

_bind_shared_value(closure(@data,
	if(is_array(@data) && array_index_exists(@data, 'filter')){
		if(@data['filter'] == 'dolist'){
			_store_shared_value(array(
				filter: 'displaylist',
				data: array(
					list: _generate_list(),
					source: import('sharedata.source'),
					player: @data['data']['player']
				)
			))
		}
		if(@data['filter'] == 'displaylist'){
			@player = @data['data']['player']
			if(@player == '~console'){
				console(color(GREEN).'On '.@data['data']['source'])
				console(@data['data']['list'])
			} else if(ponline(@player)){
				tmsg(@player, color(GREEN).'On '.@data['data']['source'])
				tmsg(@player, @data['data']['list'])
			}
		}
	}
))

}
