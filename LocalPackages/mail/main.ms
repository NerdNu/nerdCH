bind(player_join, null, null, @event,
    set_timeout(1000, closure(
        assign(@mail, _player_mail(@event[player]))
        
        if(is_null(@mail) || length(@mail) == 0,
            die()
        , # else
            tmsg(@event[player], concat(color(green), 'You have mail! Type `/mail inbox` to see'))
        )
    ))
)