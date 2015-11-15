include('alerts.ms')

proc(_convertcolors, @text,
    return(reg_replace('&([0-9a-fA-F]{1})', concat(substr(color(0),0,1), '$1'), @text))
)



/*proc('_hologram', @loc, @lines) {
        if(!has_bind('hologram')) {
                bind('entity_damage', array('id': 'hologram'), array('type': 'HORSE'), @event) {
                        if(get_mob_age(@event['id']) < 100) {
                                cancel()
                        }
                }
        }
       
        @loc['y'] += 55
       
        foreach(@line in @lines) {
                @skull = spawn_entity('WITHER_SKULL', 1, @loc)[0]
                @horse = spawn_mob('HORSE', 1, @loc)[0]
                set_entity_rider(@skull, @horse)
                set_entity_spec(@skull, array('direction': array(0, 0, 0)))
                set_mob_age(@horse, -1700000, true)
                set_name_visible(@horse, true)
                set_mob_name(@horse, @line)
                @loc['y'] += 0.3
        }
}*/



