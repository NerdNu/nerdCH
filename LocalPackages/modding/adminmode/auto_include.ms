proc _adminModeTabcompleter() {
	return closure(@alias, @sender, @args) {
		if(array_contains(@args, 'status')) {
			return array();
		}
		if(array_contains(pgroup(@sender), 'superduper')) {
			return array('noModMode', 'status');
		}
		if(array_contains(@args, 'noModMode')) {
			return array('makeSticky');
		} else {
			return array('noModMode', 'status');
		}
	};
}