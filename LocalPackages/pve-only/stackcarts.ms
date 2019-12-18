# Allow cart stacking in inventory
# Super glitchy... Stacks onto the player's cursor rather than in the inventory
# slot. Always leaves 1 item in the inventory slot. These glitches seem to be
# related to the client really not wanting to stack carts.

bind('inventory_click', null, null, @event,
	if(and(@event["slotitem"],@event["cursoritem"]),
		if(and(equals(@event["slotitem"]["name"],"MINECART"),equals(@event["cursoritem"]["name"],"MINECART")),
			if (@event["slotitem"]["qty"]+@event["cursoritem"]["qty"]<64) {
				@event["slotitem"]["qty"]=@event["slotitem"]["qty"]+@event["cursoritem"]["qty"]
				@event["cursoritem"]["qty"]=0
			}
		)
	)
)
