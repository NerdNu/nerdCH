# When right clicking on an item fram with a blank map that has a name which can be converted to an integer, convert the map into a completed map with an ID matching the name converted to an integer.


bind(player_interact_entity, null, null, @event,
  # return right away if event is not a player clicking an item frame
  if(@event['clicked'] == "ITEM_FRAME") {
    @item=pinv(@event['player'],pheld_slot(@event['player']))
    # Make sure the player is holding something
    if(@item != null) {
      # And the thing they're holding is an empty map
      if(@item['type'] == 395){
        # with a name that can be converted to an integer
        if(is_numeric(@item['meta']['display'])){
          @blacklist=array(1837)
          if(!array_contains(@blacklist,integer(@item['meta']['display']))) {
            # Make a new item stack with a completed map. Set the correct map ID and quantity based on the blank map stack.
            @newitem = associative_array()
            @newitem[pheld_slot(@event['player'])] = array(type: 358, data: integer(@item['meta']['display']), qty: @item['qty'])
            # Replace the blank maps with the competed maps.
            set_pinv(@event['player'],@newitem)
          } else {
            msg(concat(color(red), 'That map ID is currently blacklisted.'))
          }
        }
      }
    }
  }
)
