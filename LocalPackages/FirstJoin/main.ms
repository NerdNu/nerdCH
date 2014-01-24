
bind(player_join, null, null, @event,
	if(@event['first_login']){
		@file = import('shared.firstjoin.book')
		if(@file == null){
			console(color(RED).'No first join book text set. Please add export(\'shared.firstjoin.book\', read(\'file.txt\') to main.ms for the server.')
		}
		@inv = array(array(type: 387))
		set_pinv(@inv)
		set_itemmeta(0, array(
			title: 'The Rules',
			author: 'nerd.nu',
			pages: split('>>>>>>>>>>>>>>>>>>>', colorize(@file))
		))
	}
)
