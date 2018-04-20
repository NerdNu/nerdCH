# Prototype dragon fight changes

bind(player_interact_entity, null, null, @event,
	if(@event['clicked'] == "ITEM_FRAME"){
		@item=pinv(@event['player'],pheld_slot(@event['player']))
		if(@item != null){
			if(@item['type'] == 395){
				if(is_numeric(@item['meta']['display'])){
					@newitem = associative_array()
					@newitem[pheld_slot(@event['player'])] = array(type: 358, data: integer(@item['meta']['display']), qty: @item['qty'])
					set_pinv(@event['player'],@newitem)
				}
			}
		}
	}
)
