bind(player_teleport, null, null, @event) {
    console("Tried to remove the event place and marker.")
    if(has_value('event.endtime')) {
        if(get_value('event.endtime') < time()) {
            runas("~console", "/bmarker delete world weeklyevent eventmarker");
            call_alias("/delplace Overworld other Event");
            clear_value('event.endtime')
            console("Succeeded at removing the event place and marker.")
        }
    }
}