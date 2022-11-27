/**
 * Formats a message using the "story" format of messages. The @from is who the message appears to be from, and the @message is the
 * message itself.
 */
proc _storyChat(@from, @message) {
	return(color('AQUA').color('ITALIC').@from.color('RESET').': '.color('GRAY').@message);
}

/**
 * Formats a message using the "story" format of messages, and also sends it to the specified player(s). @players may
 * be a single player, or an array of players.
 */
proc _storyChatPlayers(@from, @message, @players) {
	@players = if(@players instanceof string, array(@players), @players);
	foreach(@player in @players) {
		if(ponline(@player)) {
			tmsg(@player, _storyChat(@from, @message));
		}
	}
}

/**
 * Given a set of lines, and an array of (or single) player name(s), sends each line one after
 * the next, with an automatic amount of time between the lines to ensure they can be read. Uses
 * _scriptLine under the hood, which in turn uses _storyChat.
 */
proc _scriptLines(@toPlayers, @from, @lines, @callback) {
	if(@toPlayers instanceof string) {
		@toPlayers = array(@toPlayers);
	}
	@queue = 'scriptlines'.rand();
	foreach(@line in @lines) {
		queue_push(closure() {
			_scriptLine(@toPlayers, @from, @line);
		}, @queue);
		queue_delay(2000 + (length(@line) * 50), @queue);
	}
	if(@callback instanceof closure, queue_push(@callback, @queue));
}

/**
 * Given a line, sends it to all the specified players using _storyChat. Additionally,
 * if the message is short enough, it will also be sent as a title.
 */
proc _scriptLine(@toPlayers, @from, @line) {
	if(@toPlayers instanceof string) {
		@toPlayers = array(@toPlayers);
	}
	foreach(@player in @toPlayers) {
		if(length(@line) < 10) {
			title(@player, @line, '');
		} else if(length(@line) < 50) {
			title(@player, '', @line);
		}
		if(ponline(@player)) {
			tmsg(@player, _storyChat(@from, @line));
		}
	}
}