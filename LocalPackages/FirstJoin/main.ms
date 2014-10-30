
bind(player_join, null, null, @event,
	if(@event['first_login']){
    #to add more books to firstjoin, just enter  "clear_value('cooldowns.book.'.player())" on preceding line
		run_cmd('/rulebook')
	}
)
