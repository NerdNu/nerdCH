bind(player_join, null, null, @event,
	@server_name = import('sharedata.source')
#	console('MobCodes: ' . @event['player'] . '@' . @server_name)

	if (@server_name == 'creative') {
		_schematica_printer_dis(@event['player'])
	}

	if (@server_name == 'pve') {
		_schematica_printer_dis(@event['player'])
		_rei_player_radar_en(@event['player'])
		_voxelmap_cave_mapping_dis(@event['player'])
	}

	if (@server_name == 'survival') {
                _voxelmap_player_radar_dis(@event['player'])
                _voxelmap_cave_mapping_dis(@event['player'])
	}
)

