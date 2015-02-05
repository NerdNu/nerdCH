bind(player_join, null, null, @event,
    @warnings = get_value('warnings', _get_puuid(@event['player']))
    if(@warnings != null) {
        msg(color(GRAY).'---------------------------------------------')
        msg(color(RED).'You been warned about something by a staff member!')
        msg(color(RED)."Type '/warnings' to view your warnings.")
        msg(color(GRAY).'---------------------------------------------')
    }
)

set_interval(30 * 1000, closure() {
    @player_warnings = get_values('warnings')
    @players = all_players()
    foreach(@key: @value in @player_warnings) {
        @player_name = _get_username_from_uuid(substr(@key, 9))
        if(array_contains_ic(@players, @player_name)) {
            @player = player(@player_name)
            tmsg(@player, color(GRAY).'---------------------------------------------')
            tmsg(@player, color(RED).'You been warned about something by a staff member!')
            tmsg(@player, color(RED)."Type '/warnings' to view your warnings.")
            tmsg(@player, color(GRAY).'---------------------------------------------')
        }
    }
})
