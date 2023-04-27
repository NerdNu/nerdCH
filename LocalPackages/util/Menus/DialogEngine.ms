
/**
 * A dialog tree is a data structure which maps dialog to actions, including further
 * dialog. Depending on the answers that the player gives, the tree is iterated to the
 * dialog's conclusion.
 * The most basic tree is simply an associative array of strings. Each key is the character
 * dialog, and each value is the response when it's selected. Note that using this method
 * means that the dialog will be in associative array order, which is not necessarily
 * definition order.
 * 
 array(
	 "How's the weather?": "Great!",
	 "What are you doing?": "Oh, the usual.",
	 "Good day to you!": "Good day to you too!"
 )

 * Many conversations are more complex however, and each question/response pair may require
 * different actions, including generating dynamic questions/answers based on runtime values.
 * In the most flexible case, the value in the array may itself be an associative array, with
 * various keys.
 array(
	 array(
		 greeting: closure(@player) {
			 return "Hello.";
		 }
		 question: closure(@player) {
			 return "A dynamic question.";
		 },
		 response: closure(@player) {
			 return "A dynamic response.";
		 },
		 visible: closure(@player) {
			 return true; // If false, the question won't show up.
		 },
		 onclick: closure(@player) {
			 // Runs if this answer is selected
		 },
		 item: 'REDSTONE_BLOCK'
	 )
 )
 * The three keys are question, response, and visible. Question and response are mandatory, visible is
 * optional, and defaults to true, and greeting is optional, and defaults to null.
 * If visible is a closure which returns false, (or is set to false) the question will
 * not be shown to the user. Both greeting, question, and response may be a closure that returns a value, or may be
 * the value directly. The value may be a string, in which case it works the same as the "flat" array,
 * or, in the case of response, it may be an array, which follows the same format as the top level structure,
 * and if is selected by the player, is then fed recursively back into the function. If the response is an
 * array, then the greeting field is recommended, and works like the string "response", whereas the response
 * is the recursive conversation tree. If response is a string, then it is not necessary to provide a greeting,
 * as the response is played, and then the conversation is ended.
 * There is also the optional onclick value, which is run if the user selects this dialog option. This is run
 * in addition to the next level dialog tree (if provided). The item key is the item used in the inventory menu,
 * by default, redstone block.
 * @character is the name of the character being shown, and @player is the player running the command (if
 * not provided, player() is assumed). @greeting is the initial greeting when the function is initially run.
 */
proc _showDialogTree(string @character, string @greeting, array @tree, string @player = null) {
	@player = @player ||| player();
	// First, rewrite @tree if it's a flat object
	@resultTree = array();
	foreach(@key: @value in @tree) {
		if(@key instanceof string) {
			@resultTree[] = array(
				question: @key,
				response: @value,
				greeting: null,
				visible: true,
				onclick: null,
				item: 'REDSTONE_BLOCK',
			)
		} else if(@value instanceof array) {
			@question = associative_array();
			if(!array_index_exists(@value, 'question') || !array_index_exists(@value, 'response')) {
				throw(IllegalArgumentException, 'Missing question or response from dialog tree.');
			}
			@question['question'] = if(@value['question'] instanceof Callable, @value['question'](@player), @value['question']);
			@question['response'] = @value['response'];
			@question['visible'] = if(array_index_exists(@value, 'visible'), @value['visible'], true);
			if(@question['visible'] instanceof Callable) {
				@question['visible'] = @question['visible'](@player);
			}
			@question['onclick'] = if(array_index_exists(@value, 'onclick'), @value['onclick'], null);
			@question['item'] = if(array_index_exists(@value, 'item'), @value['item'], 'REDSTONE_BLOCK');
			@question['greeting'] = if(array_index_exists(@value, 'greeting'), @value['greeting'], null);
			@resultTree[] = @question;
		}
	}

	array @items = array();
	
	foreach(@question in @resultTree) {
		@items[] = array(
			name: if(@question['item'] instanceof Callable, @question['item'](@player), @question['item']),
			meta: array(
				display: @question['question']
			),
			onclick: closure() {
				if(@question['onclick'] instanceof Callable) {
					@question['onclick'](@player);
				}
				auto @response = if(@question['response'] instanceof Callable, @question['response'](@player), @question['response']);
				if(@response instanceof array) {
					if(!array_index_exists(@question, 'greeting')) {
						console('Invalid array: '.array_keys(@question));
					}
					string @newGreeting = if(@question['greeting'] instanceof Callable, @question['greeting'](@player), @question['greeting']);
					_showDialogTree(@character, @newGreeting, @response, @player);
				} else {
					tmsg(@player, _storyChat(@character, @response));
				}
			}
		);
	}

	if(@greeting) {
		tmsg(@player, _storyChat(@character, @greeting));
	}
	if(length(@tree) == 0) {
		return;
	}
	set_timeout(1000 + (length(@greeting) * 15), closure() {
		_showMenu(length(@items), @character, @items);
	});
}