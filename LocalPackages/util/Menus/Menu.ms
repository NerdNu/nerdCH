/**
 * Creates a UI menu containing various options. @typeOrSize is the input to
 * create_virtual_inventory, @title is the title of the menu, and @items is the item
 * list. In addition to the normal item array attributes, these items may also contain
 * a 'onclick' attribute, which should contain a closure<void>(). This closure will be
 * called if the user selects that option. closeonclick defaults to true, but if false,
 * the menu remains open if an item is interacted with.
 */
proc _showMenu(auto @typeOrSize, string @title, array @items) {
	@id = player().@title;
	try {
		create_virtual_inventory(@id, @typeOrSize, @title, @items);
	} catch(IllegalArgumentException @ex) {
		return;
	}
	bind('inventory_click', array(id: @id.'-click'), array(player: player()), @event, @items, @id) {
		cancel();
		if(array_index_exists(@items, @event['slot']) && array_index_exists(@items[@event['slot']], 'onclick')) {
			@closeOnClick = true;
			if(array_index_exists(@items[@event['slot']], 'closeonclick')) {
				@closeOnClick = @items[@event['slot']]['closeonclick'];
			}
			if(@closeOnClick) {
				unbind();
				unbind(@id.'-click');
				delete_virtual_inventory(@id);
			}
			@items[@event['slot']]['onclick']();
		}
	}

	bind('inventory_close', null, array(virtual: true), @event, @id) {
		if(@event['holder'] == @id) {
			unbind();
			unbind(@id.'-click');
			delete_virtual_inventory(@id);
		}
	}

	popen_inventory(@id);
}
