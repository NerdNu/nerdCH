
# Lol, I love one liners
bind(player_interact_entity, null, null, @event,
	if(@event['clicked'] == 'ITEM_FRAME' 
		&& pinv(player(), null) != null 
		&& (pinv(player(), null)['type'] == 395
		|| pinv(player(), null)['type'] == 358)){
			 cancel()
	}
)
