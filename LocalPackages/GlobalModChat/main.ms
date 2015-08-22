
_bind_shared_value(closure(@data,
	if(is_array(@data) && array_index_exists(@data, 'filter')){
		if(@data['filter'] == 'globalmodchat'){
			_global_do_modchat(@data['data']['source'], @data['data']['player'], @data['data']['message'])
		}
		if(@data['filter'] == 'globalbroadcast'){
			_global_do_broadcast(@data['data']['message'])
		}
		if(@data['filter'] == 'globaladminchat'){
			_global_do_adminchat(@data['data']['source'], @data['data']['player'], @data['data']['message'])
		}
	}
))
