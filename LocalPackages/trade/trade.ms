proc(_signencode, @data,
	assign(@new, '')
	for(assign(@j, 0), lt(@j, length(@data)), inc(@j),
		assign(@new, concat(@new, 
			if(equals(substr(@data, @j, add(@j,1)), ':'),
				'  ',
				color(
					integer(
						substr(@data, @j, add(@j,1))))))))
	return(@new))

proc(_signdecode, @data,
	assign(@new, '')
	for(assign(@j, 1), lt(@j, length(@data)), inc(@j, 2),
		assign(@new, concat(@new,
			if(equals(substr(@data, @j, add(@j,1)), ' '),
				':',
				substr(@data, @j, add(@j,1))))))
	return(@new))

proc(_msg2, @text,
	msg(concat(color(10), '[SIGN] ', color(15), @text)))

bind(player_interact, null, array(block: 68, button: 'right'), @event,
	assign(@text, get_sign_text(@event['location']))
	#Check if it's a trade sign...
	assign(@command, reg_match(concat(color(1),'\\[(.*)\\]'), @text[1]))
	if(array_index_exists(@command,0),
		switch(to_lower(@command[1]),
			'trade',
				#Decode the quantities
				assign(@quantities, reg_split(':', _signdecode(@text[0])))
				
				#Decode the item IDs to take/give
				assign(@takeid, _signdecode(@text[2]))
				assign(@giveid, _signdecode(@text[3]))
				
				if(equals(reg_count('\\:', @takeid), 0),
					assign(@takeid, concat(@takeid, ':0')))
				
				assign(@givename, to_lower(data_name(reg_split('\\:', @giveid)[0])))
				assign(@takename, to_lower(data_name(reg_split('\\:', @takeid)[0])))
				#Check the player is holding the item to be taken
				
				
				if(equals(pinfo(@event['player'], 6), @takeid),
					assign(@takecount, phas_item(@event['player'], @takeid))
					assign(@takecount, subtract(@takecount,mod(@takecount, @quantities[0])))
					
					#Actually do the taking
					assign(@actuallytaken, ptake_item(@event['player'], @takeid, @takecount))
					
					#How much do we give?
					assign(@givecount, divide(multiply(@actuallytaken, @quantities[1]), @quantities[0]))
					
					#Give the items
					assign(@actuallygiven, pgive_item(@event['player'], @giveid, @givecount))

					#TODO: wtf do we do if they're not equal?

					_msg2(concat('Gave you ', @givecount, ' ', @givename,
									 ' for ', @takecount, ' ', @takename))
					_msg2('Note that you may need to reconnect to the server for the items to appear.'),
				#else:
					_msg2(concat('Please hold the ', @takename, ' in your hand!'))),
			'free',
				assign(@givecount, _signdecode(@text[2]))
				assign(@giveid,	_signdecode(@text[3]))
				assign(@givename, to_lower(data_name(reg_split('\\:', @giveid)[0])))
				pgive_item(@event['player'], @giveid, @givecount)
				_msg2(concat('Enjoy your free ', @givename, '!')),
			'warp',
				if(equals(@text[3], color(0)),
					sudo(concat('/ci ', @event['player'])))
				msg(get_value('warps.'.@text[2]))
			    set_ploc(get_value(concat('warps.', @text[2]))),
				#scriptas('~op', call_alias(concat('/warp ', @text[2]))),
			'kit',
				#if(equals(@text[3], color(0)),
				#	runas('~op', concat('/ci ', @event['player'])))
				#runas('~op', concat('/kit ', @text[2])),
                                _kit(@text[2]),
			'announce',
				assign(@key, 'trade.announces')
				assign(@announces, if(has_value(@key), get_value(@key), array()))
				
				if(not(array_index_exists(@announces, @text[2])), 
					array_set(@announces, @text[2], array())
				)
				
				if(array_contains(@announces[@text[2]], @event['player']),
					_msg2('You can only announce here once!'),
					broadcast(concat(color(10), '[5K] ', color(15), @event['player'], ' has reached ', @text[2], '!')))
				
				array_push(@announces[@text[2]], @event['player'])
				store_value(@key, @announces),
			'effect',
				set_peffect(@event['player'], _signdecode(@text[0]), _signdecode(@text[3]), _signdecode(@text[2]))
				_msg2('OK!'),
			#default:
				_msg2('Unsupported sign!')),
	#else: (not a functional trade sign)
		if(and(equals(pinfo(@event['player'], 6), '290:0'),			 #if they're holding a wood hoe
				msg('OMG WHAT ARE YOU DOING')
			   has_permission(@event['player'], 'tradesigns.create')),  #and if they have permission
			assign(@command, reg_match('\\[(.*)\\]', to_lower(@text[0]))) #  regex match the first line
			if(array_index_exists(@command, 0),						   #  if there's a match...),
				assign(@newsign, array('', concat(' ', color(1), '[', to_upper(@command[1]), ']'), '', ''))
				assign(@valid, 1)
				switch(@command[1],
					'trade',
						#Oh god...
						#Read the 2nd and 3rd line for the quantity and material data
						#Then assign it to the sign encoded as colour characters
						#New format:
						#Line 1: Quantities, separated by 2 spaces.
						#Line 2: '[%s]' % command [note: coloured!]
						#Line 3: Material taken
						#Line 4: Material given
						
						#Do this for the 2nd and 3rd lines...
						for(assign(@i, 1), lte(@i,2), inc(@i),
							assign(@line, reg_match('([0-9]+)x ([0-9]+)\\:?([0-9]*)', @text[@i]))
							if(array_index_exists(@line, 0),
								
								#Encode quantity
								array_set(@newsign, 0, concat(@newsign[0], _signencode(@line[1])))
								
								#Add a spaces to the top (quantity) line
								if(equals(@i, 1),
									array_set(@newsign, 0, concat(@newsign[0], '  ')))
								
								#Encode material
								assign(@material, concat(@line[2], ':',
									if(equals(length(@line[3]), 0),
										'0',
										@line[3])))
								
								array_set(@newsign, add(@i,1), concat(@newsign[add(@i,1)], _signencode(@material))),

							#else:
								_msg2('Invalid trade sign format!')
								assign(@valid, 0)
								break())),
					'free',
						assign(@line, reg_match('([0-9]+)x ([0-9]+)\\:?([0-9]*)', @text[1]))
						if(array_index_exists(@line, 0),
							assign(@material, concat(@line[2], ':',
								if(equals(length(@line[3]), 0),
									'0',
									@line[3])))
							array_set(@newsign, 2, _signencode(@line[1]))
							array_set(@newsign, 3, _signencode(@material)),
						#else:
							_msg2('Invalid free sign format!')
							assign(@valid, 0)),
					'warp',
						array_set(@newsign, 2, @text[1])
						array_set(@newsign, 3, if(equals(@text[2], 'ci'), color(0), '')),
					'kit',
						array_set(@newsign, 2, @text[1])
						array_set(@newsign, 3, if(equals(@text[2], 'ci'), color(0), '')),
					'announce',
						array_set(@newsign, 2, @text[1]),
					'effect',
						#Line 1: ID
						#Line 2: Duration
						#Line 3: Strength (0 by default)
						array_set(@newsign, 0, _signencode(@text[1]))
						array_set(@newsign, 2, _signencode(@text[2]))
						array_set(@newsign, 3, _signencode(
							if(equals('', @text[3]),
								'1',
								@text[3]))),
					#default:
						_msg2('unknown sign type!')
						assign(@valid, 0))
				#end switch
				if(equals(@valid, 1),
					
					set_sign_text(@event['location'], @newsign)
					_msg2('OK, sign is now active!')),
			#else:
				_msg2('First line does not match [] format')))))
			#endif
		#else:
			#do nothing
		#endif
	#endif
#endproc
