
/**
 * Returns a location array that has been normalized for comparison. This does not include yaw and pitch, just xyz and world.
 * The values are returned as an associative array only.
 */
proc _normalizeLocation(array @location) {
	if(@location == null) {
		return null;
	}
	return array(
		x: double(if(array_index_exists(@location, 'x'), @location['x'], @location[0])),
		y: double(if(array_index_exists(@location, 'y'), @location['y'], @location[1])),
		z: double(if(array_index_exists(@location, 'z'), @location['z'], @location[2])),
		world: if(array_index_exists(@location, 'world'), @location['world'], @location[3]),
		yaw: double(array_get(@location, 'yaw', 0)),
		pitch: double(array_get(@location, 'pitch', 0))
	);
}