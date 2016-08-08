#
# Ermagerd individual players' chat or just everyone!
#

@ermagerd_players = associative_array()
export('ermagerd_players', @ermagerd_players)

#Ermagerd !
bind(player_chat, null, null, @event,
	@ermagerd_players = import('ermagerd_players')
	if(!(   array_index_exists(@ermagerd_players, to_lower(player()))
             || array_index_exists(@ermagerd_players, '*')
            )) {
		die();
	}

	@string = @event['message'];

	# ERMAGERD #
	# Begin the transformations
	@string = reg_replace('(?i)oo?r?', 'er', @string);
	@string = reg_replace('a', 'er', @string);
	@string = reg_replace('([^a-zA-Z])*?ermg([^a-zA-Z])', '$1ermagerd$2', @string);
	@string = reg_replace('([^a-zA-Z])*?my', '$1ma', @string);
	@string = reg_replace('[\\.,;]', '', @string); #Pfft, who needs punctuation
	
	modify_event('message', @string);
)

