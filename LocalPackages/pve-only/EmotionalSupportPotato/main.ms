set_timeout(2000, closure() {
	@emotionalSupportPotato = array(
		meta: array(
			display: 'Emotional Support Potato', 
			flags: array(),
			enchants: array(
				binding_curse: array(elevel: 1, etype: 'BINDING_CURSE')
			),
			lore: array("A regular potato which", "occasionally encourages you."),
			model: null, 
			modifiers: null, 
			repair: 1,
		), 
		name: 'POTATO', 
		qty: 1
	);
	export('lcsemotionalsupportpotato', @emotionalSupportPotato);

	@potatoQueue = 'lcs_potato_queue';
	set_interval(5000, closure() {
		if(!queue_running(@potatoQueue)) {
			foreach(@player in all_players()) {
				queue_push(closure() {
					if(ponline(@player)) {
						foreach(@slot: @item in pinv(@player)) {
							if(@item != null && array_index_exists(@item, 'meta', 'display') && array_index_exists(@item, 'meta', 'lore') 
									&& @item['meta']['display'] == 'Emotional Support Potato' && @item['meta']['lore'] != null ) {
								if(rand() > 0.95) {
									_lcsGivePlayerEncouragement(@player, @item['meta']['repair'], @slot);
									break;
								}
							}
						}
					}
				}, @potatoQueue);
			}
		}
	});
	
	bind('player_join', null, null, @event, @emotionalSupportPotato) {
		if(!get_value('firstpotatoisfree.'.puuid(@event['player'], true))) {
			set_timeout(2000, closure() {
				drop_item(@event['player'], @emotionalSupportPotato);
				store_value('firstpotatoisfree.'.puuid(@event['player'], true), true);
			});
		}
		if(import('hahahapotatorestartgottem.'.@event['player'])) {
			export('hahahapotatorestartgottem.'.@player, false);
			set_timeout(2000, closure() {
				tmsg(@event['player'], _storyChat('Emotional Support Potato', 'AHAHAHAHAHA! There was no restart, that was me, but I got you good xD'));
			});
		}
	}

	bind('player_consume', null, null, @event) {
		if(@event['item']['name'] == 'POTATO' && rand() > 0.6 && _lcsPlayerHasRottenPotato(player())) {
			export('potatosnarklastrun.'.player(), time());
			msg(_storyChat('Emotional Support Potato', 'OH MY GOD, YOU MONSTER, SPIT THAT OUT RIGHT NOW!'));
		} else if(rand() > 0.95 && _lcsPlayerHasRottenPotato(player())) {
			export('potatosnarklastrun.'.player(), time());
			msg(_storyChat('Emotional Support Potato', 'I hope that '.replace(to_lower(@event['item']['name']), '_', ' ').' was poisoned.'));
		}
	}
	bind('player_death', null, null, @event) {
		if(_lcsPlayerHasRottenPotato(player())) {
			msg(_storyChat('Emotional Support Potato', 'Hahahahahahahahahahaha! Finally!!! I\'m free of you!!!!'));
		}
	}
	bind('player_join', null, null, @event) {
		set_timeout(2000, closure() {
			if(_lcsPlayerHasRottenPotato(player())) {
				export('potatosnarklastrun.'.player(), time());
				msg(_storyChat('Emotional Support Potato',
					array_rand(array(
						'Oh god, you\'re back, I thought I had gotten rid of you.',
						'Oh, you\'re back. Everybody was talking about you while you were gone. They all hate you too.',
						'Ahhh, why\'d you have to ruin things and come back? It was so nice here without you.',
						'Oh. It\'s you again. Hi.',
					), 1, false)[0]
				));	
			}
		});
	}
	bind('player_chat', null, null, @event) {
		if(@event['message'] == 'back') {
			if(rand() > 0.9 && _lcsPlayerHasRottenPotato(player())) {
				set_timeout(2000, closure() {
					msg(_storyChat('Emotional Support Potato', 'Nobody cares.'));
				});
			}
		}
		if(@event['message'] == 'lol') {
			if(rand() > 0.9 && _lcsPlayerHasRottenPotato(player())) {
				set_timeout(2000, closure() {
					msg(_storyChat('Emotional Support Potato', 'LMAO LMFAO LOL HAHA ROFLCOPTER'));
					msg(_storyChat('Emotional Support Potato', 'This is how obnoxious you sound when you just type "lol".'));
				});
			}
		}
	}
	bind('player_quit', null, null, @event) {
		@quittingPlayer = @event['player'];
		@allPlayers = all_players();
		if(rand() > 0.9) {
			foreach(@player in array_rand(@allPlayers, max(length(@allPlayers), ceil(length(@allPlayers) / 10)), false)) {
				if(@player == @quittingPlayer) {
					continue();
				}
				if(_lcsPlayerHasRottenPotato(@player)) {
					if(time() - 10000 < import('potatosnarklastrun.'.@player)) {
						continue();
					}
					export('potatosnarklastrun.'.@player, time());
					if(rand() > 0.5) {
						set_timeout(3000, closure() {
								tmsg(@player, _storyChat('Emotional Support Potato', 'Oh good, '.@quittingPlayer.' left. I hate them almost as much as I hate you.'));
						});
					} else {
						tmsg(@player, "<Emotional Support Potato> Hey, @quittingPlayer, try hitting Alt-F4");
						set_timeout(3000, closure() {
							tmsg(@player, _storyChat('Emotional Support Potato', 'Hahahaha, they fell for it lmao what a loser'));
						});
					}
				}
			}
		}
	}
	bind('player_toggle_sneak', null, array(sneaking: true), @event) {
		if(rand() > 0.9 && _lcsPlayerHasRottenPotato(player())) {
			set_timeout(5000, closure() {
				if(psneaking(player())) {
					export('potatosnarklastrun.'.player(), time());
					msg(_storyChat('Emotional Support Potato', 'What are you doing? You know we can still see you, right? Moron.'));
				}
			});
		}
	}
	bind('world_changed', null, null, @event) {
		if(_lcsPlayerHasRottenPotato(player())) {
			@saying = 'I hope a skeleton shoots you while you\'re here.';
			if(@event['to'] == 'world_nether') {
				@saying = 'I hope you fall in lava while you\'re here.';
			} else if(@event['to'] == 'world_the_end') {
				@saying = 'I hope you fall off the edge while you\'re here.';
			} else if(@event['to'] == 'LadyCailinSecret') {
				@saying = 'This is a nice place, seems super dangerous. You should stay here for a while.';
			}
			export('potatosnarklastrun.'.player(), time());
			msg(_storyChat('Emotional Support Potato', @saying));
		}
	}
	bind('entity_damage', null, array(type: 'PLAYER'), @event) {
		if(rand() > 0.98 && _lcsPlayerHasRottenPotato(player()) && @event['cause'] != 'CUSTOM') {
			export('potatosnarklastrun.'.player(), time());
			@saying = null;
			if(@event['cause'] == 'FALL') {
				@saying = 'Have a nice trip! See you next fall! Haha, noob.';
			} else {
				@saying = array_rand(array(
					'Hahahaha, I saw that.',
					'Hahaha, noob, git gud'
				), 1, false)[0];
			}
			msg(_storyChat('Emotional Support Potato', @saying));
		}
	}
	@potatoWasPickedUp = closure(@event) {
		@item = @event['item'];
		if(array_index_exists(@item, 'meta', 'lore') && @item['meta']['lore'] != null && array_index_exists(@item, 'meta', 'display')) {
			if(@item['meta']['display'] == 'Emotional Support Potato') {
				@potatoStage = @item['meta']['repair'];
				if(@potatoStage >= 4) {
					tmsg(@event['player'], _storyChat('Emotional Support Potato', 'Bah, I thought I had gotten rid of you.'));
				} else {
					tmsg(@event['player'], _storyChat('Emotional Support Potato', 'Well hello '.@event['player'].'! It\'s nice to meet you! My name is Tate, and I\'m so excited to be here for you!'
						. ' You just let me know if you ever are feeling down!'));
				}
			}
		}
	};
	bind('item_pickup', null, array(itemname: 'POTATO'), @event, @potatoWasPickedUp) {
		@potatoWasPickedUp(@event);
	}
	bind('item_pickup', null, array(itemname: 'POISONOUS_POTATO'), @event, @potatoWasPickedUp) {
		@potatoWasPickedUp(@event);
	}

	@potatoWasShoveled = closure(@event) {
		if(rand() > 0.1 || @event['block'] == null) {
			return;
		}
		@item = @event['item'];
		if(array_index_exists(@item, 'meta', 'lore') && @item['meta']['lore'] != null && array_index_exists(@item, 'meta', 'display')) {
			if(@item['meta']['display'] == 'Emotional Support Potato') {
				console(@event);
				@lines = array(
					'Hey! What are you doing!? I\'m not a shovel!',
					'Put me down! This is uncalled for!',
					'Arghhh, are you blind, I\'m a potato not a pickaxe!',
					"Wrong hotbar item!",
				);
				tmsg(@event['player'], _storyChat("Emotional Support Potato", array_get_rand(@lines)));
			}
		}
	};
	bind('player_interact', null, array(button: 'left', itemname: 'POISONOUS_POTATO'), @event, @potatoWasShoveled) {
		@potatoWasShoveled(@event);
	}
});
