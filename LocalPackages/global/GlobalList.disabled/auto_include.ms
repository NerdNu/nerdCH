
proc(_generate_list, 
	@all = array()
	@players = all_players()
	if(array_size(@players) == 0){
		return(color(RED).'No players online :(')
	}
	array_sort(@players)
	foreach(@players, @p,
		if (is_null(get_value('list.hide.'.@p))) {
			@group = pgroup(@p)
			@group = if(array_index_exists(@group, 0), @group[0], 'default')
			if(!array_index_exists(@all, @group)){
				@all[@group] = array()
			}
			array_push(@all[@group], @p)
		}
	)
	@output = ''
	foreach(array('default', 'headadmins', 'techadmins', 'cadmins', 'sadmins', 'padmins', 'moderators', 'modmode'), @key,
		if(array_index_exists(@all, @key)){
			@coloredArray = array()
			@count = 0
			foreach(@all[@key], @p,
				(@count++)
				array_push(@coloredArray, if(@count % 2 == 0, color(GRAY), color(WHITE)) . @p)
			)
			@output .= color(GOLD) . @key . ': ' . array_implode(@coloredArray, ' ') . '\n'
		}
	)
	@output .= color(GRAY) . 'Total: ' . color(WHITE) . array_size(@players) . ' players'
	return(@output)
)
/*
proc(_cooldown, @id, @time){
  @t = get_value('cooldowns.'.@id)
 
  if(@t == null){
    store_value('cooldowns.'.@id, time())
    return(true)
  } else {
    if((time() - @t) / 1000 <= @time){
      die('You must wait at least '.@time.' seconds between command runs')
    } else {
      store_value('cooldowns.'.@id, time())
    }
  }
}
*/
proc(_cooldown, @t, @len){
#  @t = get_value('cooldowns.'.@id)

#  console('@t = "' . @t . '"')
#  console('@len = "' . @len . '"')

  if(@t == null || @t == ''){
#    store_value('cooldowns.'.@id, time())
    return(true)
  } else {
#    console((time() - @t) / 1000)
    if((time() - @t) / 1000 <= @len){
      die(color(RED) . 'You must wait at least '.@len.' seconds between command runs')
    } else {
      return(true)
 #     store_value('cooldowns.'.@id, time())
    }
  }
}

