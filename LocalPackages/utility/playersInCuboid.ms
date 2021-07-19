
proc _playersInCuboid(array @first, array @second) {
	@ready = array();
	@mid = array(average(@first[0], @second[0]), average(@first[1], @second[1]), average(@first[2], @second[2]), @first[3]);
	@distance = max(abs(@first[0] - @second[0]), abs(@first[1] - @second[1]), abs(@first[2] - @second[2]));
	foreach(@player in players_in_radius(@mid, @distance)) {
		@ploc = ploc(@player);
		if(@ploc[0] >= min(@first[0], @second[0]) && @ploc[0] <= max(@first[0], @second[0])
			&& @ploc[1] >= min(@first[1], @second[1]) && @ploc[1] <= max(@first[1], @second[1])
			&& @ploc[2] >= min(@first[2], @second[2]) && @ploc[2] <= max(@first[2], @second[2])) {
			@ready[] = @player;
		}
	}
	return(@ready);
}
