
/**
 * Retrieves the player's uuid from the database, or null if no player is known with that username
 */
proc(_get_puuid, @playerName) {
	@playerName = to_lower(strip_colors(@playerName));

	if (ponline(@playerName)) {
		@pinfo = pinfo(@playerName);
		return(replace(@pinfo[20], '-', ''));
	}

	if (@playerName == '~console') {
		return(@playerName);
	}

	@uuidCache = import('uuidCache');

	if (array_index_exists(@uuidCache, @playerName)) {
		return(@uuidCache[@playerName]);
	}

	@res = query('uuid', 'SELECT uuid FROM user WHERE last_username=? LIMIT 1', @playerName);
	if (length(@res) == 0) {
		return(null);
	} else {
		@uuidCache[@playerName] = @res[0]['uuid'];
		export('uuidCache', @uuidCache);
		return(@res[0]['uuid']);
	}
}

/**
 * Gets the last known username from the database, or null, if no player is known with that UUID.
 * Hyphens are automatically stripped from the UUID to match the database contents.
 */
proc(_get_username_from_uuid, @uuid) {
	@nameCache = import('nameCache');
	@uuid = replace(@uuid, '-', '');

	if (array_index_exists(@nameCache, @uuid)) {
		return(@nameCache[@uuid]);
	}

	@res = query('uuid', 'SELECT last_username FROM user WHERE uuid=?', @uuid);
	if (length(@res) == 0) {
		return(null);
	} else {
		@nameCache[@uuid] = @res[0]['last_username'];
		export('nameCache', @nameCache);
		return(@res[0]['last_username']);
	}
}

/**
 * Gets the last known display name from the database, or null, if no player is known with that uuid
 */
proc(_get_display_name_from_uuid, @uuid){
	@res = query('uuid', 'SELECT last_display_name FROM user WHERE uuid=?', @uuid);
	if(length(@res) == 0){
		return(null);
	} else {
		return(@res[0]['last_display_name']);
	}
}

proc(_config_get, @name, @default,
	@config = yml_decode(read('nerdch.yml'));

	@path = split('.', @name)

	@value = @config;
	foreach (@id: @key in @path) {
		if (!is_array(@value) || !array_contains_ic(array_keys(@value), @key)) {
			break();
		}

		@value = @value[@key]

		if (@id == array_size(@path) - 1) {
			return(@value);
		}
	}

	return(@default);
)

proc(_assertperm, @name, @cmodetrumps,
	if(player() == '~console', return())
	
	if(pisop(), return())
	
	if(has_permission('nerdch.level.' . @name), return())
	
	if(@cmodetrumps == 1 && pmode() == 'CREATIVE', return())

	msg(concat(color(red), 'You do not have permission to do this! [ap]'))
	die()
)

# mode = AND or OR, invalid modes become AND
proc(_assertperms, @perms, @mode, @cmodetrumps,
	@mode = to_upper(@mode) != 'OR';
	msg(@mode);

	foreach (@perms, @perm,
		msg(has_permission('nerdch.level.' . @perm));
		if (has_permission('nerdch.level.' . @perm) == @mode) {
			return();
		}
	)

	if (@cmodetrumps == true && pmode() == 'CREATIVE') {
		return();
	}

	msg(color(red) . 'You do not have permission to do this! [ap]');
	die();
)

proc(_assertbool, @bool,
	if (@bool) {
		msg(color(red) . 'You do not have permission to do this! [ap]');
		die();
	}
)

proc(_noperm,
	msg(color(red) . 'You do not have permission to do this! [ap]');
	die();
)

#Gets the mods and admins on right now
proc(_get_mods,
	assign(@mods, array())
	assign(@ap, all_players())
	foreach(@ap, @p,
	if(has_permission(@p, 'nerdch.level.mod'),
			array_push(@mods, @p)
	#	console(sconcat(@p, 'has mod perm'))
		)
		#if(array_contains(pgroup(@p), 'Moderators'), array_push(@mods, @p))
		#if(array_contains(pgroup(@p), 'ModMode'), array_push(@mods, @p))
	)
	#assign(@admins, _get_admins())
	#foreach(@admins, @admin,
	#		array_push(@mods, @admin)
	#)
	return(@mods)
)

#Gets just the admins on right now
proc(_get_admins,
	assign(@admins, array())
	assign(@ap, all_players())
	foreach(@ap, @p,
		#if(or(
		#		array_contains(pgroup(@p), 'HeadAdmins'),
		#		array_contains(pgroup(@p), 'CAdmins'),
		#		array_contains(pgroup(@p), 'TechAdmins'),
		#		array_contains(pgroup(@p), 'SAdmins'),
		#		array_contains(pgroup(@p), 'PAdmins')
		#), array_push(@admins, @p))
	   if(has_permission(@p, 'nerdch.level.admin'), array_push(@admins, @p))
	)
	return(@admins)
)

proc(_get_chat_admins,
	assign(@admins, array())
	assign(@ap, all_players())
	foreach(@ap, @p,
		#if(or(
		#		array_contains(pgroup(@p), 'HeadAdmins'),
		#		array_contains(pgroup(@p), 'CAdmins'),
		#		array_contains(pgroup(@p), 'TechAdmins'),
		#		array_contains(pgroup(@p), 'SAdmins'),
		#		array_contains(pgroup(@p), 'PAdmins')
		#), array_push(@admins, @p))
		if(has_permission(@p, 'nerdch.level.adminchat'), array_push(@admins, @p))
	)
	return(@admins)
)

#Messages all mods and admins
proc(_mbroadcast, @msg,
		foreach(_get_mods(), @m,
				tmsg(@m, @msg)
		)
		/*foreach(_get_admins(), @a,
				tmsg(@a, @msg)
		)*/
)

proc(_getonlinename, @name,
	if(equals(@name, ''),
		return(player()),
	#else:
		try(
			assign(@name2, player(@name))
			return(if(equals(@name, '~console'), 'console', @name2)),
		@ex,
			try(
				return(player(concat(color(10), @name))),
			@ex,
				return(null)))))

proc(_contains, @needle, @haystack,
		assign(@repl, replace(to_lower(@haystack), to_lower(@needle), ''))
		#if(equals(to_lower(@haystack), to_lower(@repl)), return(false), return(true))
		return(not(equals_ic(@haystack, @repl)))
)
proc(_kit, @name, 
	if(equals(@name, ''),
		assign(@kits, array())
		foreach(reg_split('\n', read('kits.txt')), @l,
			assign(@m, reg_match('^([^:]+)', @l))
			if(array_index_exists(@m,0),
				array_push(@kits, @m[1])))
		msg(concat(color(gray), 'Usage: /kit <name>'))
		msg(concat(color(gray), 'Available kits: ', array_implode(@kits, ', '))),
	#else:
		assign(@found, 0)
		foreach(reg_split('\n', read('kits.txt')), @l,
			assign(@m, reg_match(concat('^', @name, ': (.*)$'), @l))
			if(array_index_exists(@m,0),
				assign(@found, 1)
				assign(@l, @m[1])
				for(assign(@i,0),true,inc(@i),
					assign(@m, reg_match('^([0-9]+)x ([0-9]+)[ ,]*(.*)$', @l))
					if(array_index_exists(@m,0),
						pgive_item(@m[2], @m[1])
						assign(@l, @m[3]),
					#else:
						break()))))
		if(equals(@found, 0),
			msg(concat(color(red), 'Kit not found!')))))
