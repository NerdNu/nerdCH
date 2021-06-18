# /create-region <name> <owners>...
# Creates a protection region named <name> and adds standard flags
# and the specified owners.

register_command('create-region', array(
	'description': 'Create a protecton region.',
	'usage': colorize(
				'&e/create-region &o<name> <owners>... ' .
				'&f- Create a protection region with the specified name and owners.'
			),
	'permission': 'staff.command.create-region',
	'aliases': array('cregion'),
	'executor':
		closure(@alias, @sender, @args) {
			@argCount = array_size(@args);
			if (@argCount == 0 || (@argCount == 1 && @args[0] == 'help')) {
				return (false);
			}

			@region = @args[0];
			if (sk_region_exists(@region)) {
				die(colorize('&cA region named ' . @region . ' already exists!'));
			}

			@owners = @args[cslice(1, @argCount - 1)];
			if (array_size(@owners) == 0) {
				die(colorize('&cYou must specify at least one owner!'));
			}

			@ownersString = array_implode(@owners, ' ');
			run('/region define ' . @region . ' ' . @ownersString);
			_with_region(@region, 250, 6,
				closure() {
					call_alias('/addflags ' . @region . ' ' . @owners[0]);
				},
				colorize("&cFailed to configure region! It doesn't exist.")
			);
		}
));


# /claim-region <prefix> <owners>...
# Creates a non-protecting region named <prefix>-claim and adds standard flags
# and the specified owners. The passthrough flag is also set so that the region
# does not prevent editing.

register_command('claim-region', array(
	'description': 'Create a non-protecting claim region.',
	'usage': colorize(
				'&e/claim-region &o<prefix> <owners>... ' .
				'&f- Create a non-protecting region whose name is &o<prefix>&r-claim with the specified owners.'
			),
	'permission': 'staff.command.claim-region',
	'executor':
		closure(@alias, @sender, @args) {
			@argCount = array_size(@args);
			if (@argCount == 0 || (@argCount == 1 && @args[0] == 'help')) {
				return (false);
			}

			@region = @args[0] . '-claim';
			if (sk_region_exists(@region)) {
				die(colorize('&cA region named ' . @region . ' already exists!'));
			}

			@owners = @args[cslice(1, @argCount - 1)];
			if (array_size(@owners) == 0) {
				die(colorize('&cYou must specify at least one owner!'));
			}

			@ownersString = array_implode(@owners, ' ');
			call_alias('/cregion ' . @region . ' ' . @ownersString);
			_with_region(@region, 250, 6,
				closure() {
					run('/region flag ' . @region . ' passthrough allow');
				},
				colorize("&cFailed to configure claim region! It doesn't exist.")
			);
		}
));
