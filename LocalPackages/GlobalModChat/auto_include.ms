
proc(_global_do_modchat, @source, @player, @message,
	@message = '['.color(5).'MBG('.@source.')'.color(RED).' - '
		.strip_colors(@player).color(WHITE).'] '
		.color(GREEN).@message
	console(@message)
	foreach(_get_mods(), @mod,
		tmsg(@mod, @message)
	)
)

proc(_global_do_adminchat, @source, @player, @message,
	@message = '['.color(5).'ABG('.@source.')'.color(RED).' - '
		.strip_colors(@player).color(WHITE).'] '
		.color(GOLD).@message
	console(@message)
	foreach(_get_admins(), @admin,
		tmsg(@admin, @message)
	)
)

proc(_global_do_broadcast, @message,
	broadcast('['.color(5).'Global '.color(RED).'Broadcast'.color(WHITE).'] '.color(GREEN).@message)
)

proc(_global_list_players, @player, @players,
	@list = array()
	foreach(@players, @player,
		@group = @players['group']
		if(!is_array(@list[@group])){
			@list[@group] = array()
		}
		array_push(@list[@group], @player['name'])
	)
	foreach(@list, @key, @p,
		tmsg(@player, color(GOLD).@key.':'._global_join_list_names(@p))
	)
)

proc(_global_join_list_names, @list,
	@first = true
	@names = ''
	foreach(@list, @i, @name,
		@color = color(WHITE)
		if(@i % 2 == 0){
			@color = color(GRAY)
		}
		if(!@first){
			@names .= ' '
		}
		@first = false
		@names .= @color.@name
	)
	return(@names)
)
