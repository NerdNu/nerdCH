proc _suggestionBoxAbuserTabcomplete() {
        return(get_tabcomplete_prototype(
                array('add', 'remove'),
                'None'
        ));
}

proc _suggestionBoxRemoveTabcomplete() {
	return(get_tabcomplete_prototype(
		closure(){ return(array_keys(get_value('suggestionbox.suggestions'))); },
		'None'
	));
}

proc _suggestionBoxReplyTabcomplete() {
	return(get_tabcomplete_prototype(
		closure() { return(array_keys(get_value('suggestionbox.suggestions'))); }
	));
}
