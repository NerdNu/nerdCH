/*
if(array_contains(dm_all_markersets(), 'Portals')){
	dm_delete_markerset('Portals')
}

if(array_contains(dm_all_markersets(), 'places')){
	dm_delete_markerset('places')
}

dm_create_markerset('places', array(persistent: true, label: 'Places'))
dm_set_markerset_hide_by_default('places', true)
dm_set_markerset_show_labels('places', true)


foreach(get_value('places'), @place){
	@hasPlace = false
	foreach(dm_all_markers('places'), @dmPlaceId){
		@dmPlaceName = dm_marker_label('places', @dmPlaceId)
		if(@dmPlaceName == @place['name']){
			@hasPlace = true
			break()
		}
	}
	if(!@hasPlace){
		dm_create_marker('places', array(
			id: @place['name'],
			label: @place['name'],
			persistent: true,
			location: @place['coord']
		))
	}
}

*/
