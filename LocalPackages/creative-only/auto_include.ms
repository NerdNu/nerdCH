
proc _ermagerd(@string) {
	# Begin the transformations
	@string = reg_replace('(?i)oo?r?', 'er', @string)
	@string = reg_replace('a', 'er', @string)
	@string = reg_replace('A', 'ER', @string)
	@string = reg_replace('([^a-zA-Z])*?ermg([^a-zA-Z])', '$1ermagerd$2', @string)
	@string = reg_replace('([^a-zA-Z])*?my', '$1ma', @string)
	@string = reg_replace('[\\.,;]', '', @string) #Pfft, who needs punctuation
	return(@string)
}

proc _effecthelp () {
	_assertperm('effect');
	msg(color('GOLD') . 'Usage:');
	msg(color('YELLOW') . '/effect clear ' . color('GOLD') . '- Clear all potion effects.');
	msg(color('YELLOW') . '/effect <id> [<seconds>] [<amplifier>] [<hide-particles>] ');
	msg(color('GOLD') . '- Apply potion effect to yourself.');
	msg(color('GOLD') . '    <id> - name or number, e.g. speed, fire_resistance');
	msg(color('GOLD') . '    <seconds> - duration in seconds');
	msg(color('GOLD') . '    <amplifier> - potion strength; 1, 2 etc.');
	msg(color('GOLD') . '    <hide-particles> - if true, hide particles');
	return (null);
}

// Check the cooldown time of a command.
//
// params:
// @commandName - The name of the command to check. Each player will
//                automatically get a unique cooldown per command.
// @delay       - The cool down delay, in milliseconds.
//
// returns: true if the cooldown is okay, or false if the timer is still
//          running.
proc _checkCooldown (@commandName, @delay) {
	@varName = "cooldown." . @commandName . "." . player();
	@cooldownTime = import(@varName);
	@currentTime = time();
	if(!is_null(@cooldownTime) && @currentTime < @cooldownTime) {
		return (false);
	}
	export(@varName, @currentTime + @delay);
	return(true);
}

