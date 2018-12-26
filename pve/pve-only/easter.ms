# Prototype dragon fight changes

bind(player_interact_entity, null, null, @event,
	if(equals(get_mob_name(@event['id']),"Easter Bunny"),
		@dropegg = closure(){
			if(has_metadata(@event['id'],easter)){
				#do nothing
			} else {
				set_metadata(@event['id'],easter,1)
				drop_item(entity_loc(@event['id']),array(type: 344, data: 0, meta: array(display: "Easter Egg", lore: "Happy Easter!")))
			}
        	}
	
		try{
			if(
				equals(pinv(@event['player'],pheld_slot(@event['player']))['name'],"CARROT_ITEM"),
				execute(@dropegg),
				try{
					if(equals(pinv(@event['player'],-106)['name'],"CARROT_ITEM"), execute(@dropegg))
				} catch(Exception @e) {
					#do nothing
				}
			)
		} catch(Exception @e) {
			try{
				if(equals(pinv(@event['player'],-106)['name'],"CARROT_ITEM"), execute(@dropegg))
			} catch(Exception @e) {
				#do nothing
			}
		}
	)
#	msg(get_metadata(@event['id']))
)
