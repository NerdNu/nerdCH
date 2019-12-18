# _spawn_horse(@loc, @color, @pattern) -> entityID
#	Spawn a horse at the specified location.
#	If the color or pattern are null or empty strings, they are chosen 
#	randomly.
#
#	Return the entity ID of the spawned horse.

proc _spawn_horse(@loc, @color, @pattern) {
	@HORSE_COLORS = array('black', 'brown', 'chestnut', 'creamy', 'dark_brown', 'gray', 'white');
	@HORSE_PATTERNS = array('none', 'socks', 'whitefield', 'white_dots', 'black_dots');

	@color = if (is_null(@color), '', to_lower(@color));
	@pattern = if (is_null(@pattern), '', to_lower(@pattern));
	
	if (@color != '' && ! array_contains(@HORSE_COLORS, @color)) {
		die(color('RED').@color.' is not a valid horse color.');
	}
	if (@pattern != '' && ! array_contains(@HORSE_PATTERNS, @pattern)) {
		die(color('RED').@pattern.' is not a valid horse pattern.');
	}
	
	if (@color == '') {
		@color = @HORSE_COLORS[rand(array_size(@HORSE_COLORS))];
	}
	if (@pattern == '') {
		@pattern = @HORSE_PATTERNS[rand(array_size(@HORSE_PATTERNS))];
	}
	
	@type = 'horse:'.@color.'-'.@pattern;
	@id = spawn_entity(@type, 1, @loc)[0];
	# Sets the max health to a reasonable default and make it an adult.
	set_max_health(@id, 20);
	set_mob_age(@id, 0);
	return (@id);
}
