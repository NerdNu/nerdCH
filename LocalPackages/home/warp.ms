/*
try(
	unregister_command('setwarp');
	unregister_command('delwarp');
	unregister_command('warps');
	unregister_command('warp');
	unregister_command('warpp');
)
*/

if (_config_get('features.warp.enabled', true)) {
	console('NerdCH: Loading feature "warp"');
	register_command('setwarp', array(
		description: 'Sets a warp',
		permission: 'commandhelper.warps.setwarp',
		noPermMsg: colorize(''),
		usage: colorize('&4/setwarp <name>'),
		aliases: array(),
		executor: closure(@al, @p, @args, @cmd,
			_assertperm('restricted', 0);

			if (array_size(@args) == 1) {
				@name = @args[0];
				store_value('warps.' . @name, ploc());
				msg(color(gray) . 'Warp set!');
			}
		)
	));

	register_command('delwarp', array(
		description: 'Deletes a warp',
		permission: 'commandhelper.warps.delwarp',
		noPermMsg: colorize(''),
		usage: colorize('&4/delwarp <name>'),
		aliases: array(),
		executor: closure(@al, @p, @args, @cmd,
			_assertperm('restricted', 0);

			if (array_size(@args) == 1) {
				@name = @args[0];
				clear_value('warps.' . @name);
				msg(color(gray) . 'Warp deleted!');
			}

			return(false);
		)
	));

	register_command('warps', array(
		description: 'Lists warps',
		permission: 'commandhelper.warps.warps',
		noPermMsg: colorize(''),
		usage: colorize('&4/warps'),
		aliases: array(),
		executor: closure(@al, @p, @args, @cmd,

			@o = 'Available warps:' . color(gray);

			@count = 0;
			#The get_value(@name) == null thing here and down there are workarounds for a bug in CH
			foreach(array_keys(get_values('warps')), @name,
				if (get_value(@name) == null) {
					continue()
				}

				@color = 'white';
				if (@count % 2 == 0) {
					@color = gray;
				}

				@count++;

				@o = @o . ' ' . color(@color) . substr(@name, 6);
			)

			msg(@o);
		)
	));

	register_command('warp', array(
		description: 'Warp',
		permission: 'commandhelper.warps.warp',
		noPermMsg: colorize(''),
		usage: colorize('&4/warp <name>'),
		aliases: array(),
		executor: closure(@al, @p, @args, @cmd,

			if (array_size(@args) == 0) {
				run('/warps')
			} else if (array_size(@args) == 1) {
				@warp = @args[0];
				@found = 0;

				foreach(array_keys(get_values('warps')), @name,
					if (equals_ic(@warp, substr(@name, 6))) {
						@warp = get_value(@name);

						if (@warp == null) {
							continue();
						}

						@found = 1;
						set_ploc(@warp);
						pfacing(@warp['yaw'], @warp['pitch']);
					}
				)

				if (@found == 0) {
					msg(color(red) . 'Warp not found!')
					run('/warps')
				}
			}
		)
	));

	register_command('warpp', array(
		description: 'Warps a player',
		permission: 'commandhelper.warps.warpp',
		noPermMsg: colorize(''),
		usage: colorize('&4/warpp <player> <warp>'),
		aliases: array(),
		executor: closure(@al, @p, @args, @cmd,
			_assertperm('mod', 0);

			if (array_size(@args) == 2) {
				@player = @args[0];
				@warp = @args[1];

				if (ponline(@player)) {
					@found = 0;

					foreach(array_keys(get_values('warps')), @name,
						if (equals_ic($, substr(@name, 6))) {
							@found = 1;
							set_ploc($player, get_value(@name))
							pfacing(@warp['yaw'], @warp['pitch'])
							msg('Teleported' @player 'to' @name)
						}
					);

					if (equals_ic(@found, 0)) {
						msg(color(red) . 'Warp' substr(@name, 6) 'not found!');
						call_alias('/warp')
					}
				} else {
					msg(color(red) . 'Player' @player 'is not online!');
				}
			}
		)
	));
}
