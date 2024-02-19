
/**
 * Returns the magnitude between two points.
 */
proc _getVectorMagnitude(array @pointA, array @pointB) {
	return sqrt(
		(@pointA['x'] - @pointB['x']) ** 2
		+ (@pointA['y'] - @pointB['y']) ** 2
		+ (@pointA['z'] - @pointB['z']) ** 2
	)
}