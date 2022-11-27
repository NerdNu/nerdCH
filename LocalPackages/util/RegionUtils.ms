
/**
 * Checks if a point is within the cube bounds.
 */
proc _pointInRegion(@point, @pos1, @pos2) {
	return(
		min(@pos1['x'], @pos2['x']) <= @point['x'] && @point['x'] <= max(@pos1['x'], @pos2['x']) &&
		min(@pos1['y'], @pos2['y']) <= @point['y'] && @point['y'] <= max(@pos1['y'], @pos2['y']) &&
		min(@pos1['z'], @pos2['z']) <= @point['z'] && @point['z'] <= max(@pos1['z'], @pos2['z']) &&
		@pos1['world'] == @point['world']
	);
}

/**
 * Given two blocks, iterates through all the blocks inside the cuboid, and calls the 
 * user defined closure on them. The used defined closure should accept 3 parameters,
 * the x, y, and z coordinates of the block.
 */
proc _iterate_cuboid(array @b1, array @b2, Callable @callback){
	for(@x = min(@b1['x'], @b2['x']), @x <= max(@b1['x'], @b2['x']), @x++){
		for(@y = min(@b1['y'], @b2['y']), @y <= max(@b1['y'], @b2['y']), @y++){
			for(@z = min(@b1['z'], @b2['z']), @z <= max(@b1['z'], @b2['z']), @z++){
				@callback(@x, @y, @z);
			}
		}
	}
}

/**
 * Given two blocks, iterates through all the blocks inside the cuboid, and calls the 
 * user defined closure on them. The used defined closure should accept 3 parameters,
 * the x, y, and z coordinates of the block. The processing of each z/y plane happens in
 * its own queue entry, in the given queue, for processing of large areas.
 */
proc _iterate_cuboid_queue_plane(array @b1, array @b2, string @queue, Callable @callback){
	for(@x = min(@b1['x'], @b2['x']), @x <= max(@b1['x'], @b2['x']), @x++){
		queue_push(closure() {
			for(@y = min(@b1['y'], @b2['y']), @y <= max(@b1['y'], @b2['y']), @y++){
				for(@z = min(@b1['z'], @b2['z']), @z <= max(@b1['z'], @b2['z']), @z++){
					@callback(@x, @y, @z);
				}
			}
		}, @queue);
	}
}

/**
 * Given two blocks, iterates through all the blocks inside the cuboid, and calls the 
 * user defined closure on them. The used defined closure should accept 3 parameters,
 * the x, y, and z coordinates of the block. The processing of each z row happens in
 * its own queue entry, in the given queue, for processing of large areas.
 */
proc _iterate_cuboid_queue_row(array @b1, array @b2, string @queue, Callable @callback){
	for(@x = min(@b1['x'], @b2['x']), @x <= max(@b1['x'], @b2['x']), @x++){
		for(@y = min(@b1['y'], @b2['y']), @y <= max(@b1['y'], @b2['y']), @y++){
			queue_push(closure() {
				for(@z = min(@b1['z'], @b2['z']), @z <= max(@b1['z'], @b2['z']), @z++){
					@callback(@x, @y, @z);
				}
			}, @queue);
		}
	}
}

/**
 * Given a length 2 array, generates a flat list of points in a cuboid.
 */
proc _getBlocksInCuboid(array @cuboidArray) {
	array @b1 = @cuboidArray[0];
	array @b2 = @cuboidArray[1];
	string @world = @cuboidArray[0]['world'];
	array @ret = array();
	for(@x = min(@b1['x'], @b2['x']), @x <= max(@b1['x'], @b2['x']), @x++){
		for(@y = min(@b1['y'], @b2['y']), @y <= max(@b1['y'], @b2['y']), @y++){
			for(@z = min(@b1['z'], @b2['z']), @z <= max(@b1['z'], @b2['z']), @z++){
				@ret[] = array(x: @x, y: @y, z: @z, world: @world);
			}
		}
	}
	return @ret;
}

/**
 * Replaces blocks matching the mask in the given region with the given pattern. Supports
 * the mask and pattern formats defined in WorldEdit.
 */
proc _regionReplace(array @regionBounds, string @mask, string @pattern) {
	sk_pos1(null, @regionBounds[0]);
	sk_pos2(null, @regionBounds[1]);
	sk_replace_blocks(null, @mask, @pattern);
}

proc _entitiesInRegion(array @regionBounds) {
	@pos1 = @regionBounds[0];
	@pos2 = @regionBounds[1];
	@midpoint = array(
		x: average(@pos1['x'], @pos2['x']),
		y: average(@pos1['y'], @pos2['y']),
		z: average(@pos1['z'], @pos2['z']),
		world: @pos1['world']
	)

	@radius = max(abs(@pos1['x'] - @pos2['x']), abs(@pos1['y'] - @pos2['y']), abs(@pos1['z'] - @pos2['z'])) + 2;
	@ret = array();
	foreach(@entity in entities_in_radius(@midpoint, @radius)) {
		if(_pointInRegion(entity_loc(@entity), @pos1, @pos2)) {
			@ret[] = @entity;
		}
	}
	return(@ret);
}

proc _playersInRegion(array @regionBounds) {
	@pos1 = @regionBounds[0];
	@pos2 = @regionBounds[1];
	@midpoint = array(
		x: average(@pos1['x'], @pos2['x']),
		y: average(@pos1['y'], @pos2['y']),
		z: average(@pos1['z'], @pos2['z']),
		world: @pos1['world']
	)

	@radius = max(abs(@pos1['x'] - @pos2['x']), abs(@pos1['y'] - @pos2['y']), abs(@pos1['z'] - @pos2['z'])) + 2;
	@ret = array();
	foreach(@player in players_in_radius(@midpoint, @radius)) {
		if(_pointInRegion(ploc(@player), @pos1, @pos2)) {
			@ret[] = @player;
		}
	}
	return(@ret);
}

/**
 * Given a source and destination region (each a length 2 array containing the bounding blocks), copies the blocks
 * from one region to the other. The orientation of the blocks will be the same. Not all block types are supported.
 */
proc _copyRegion(array @sourceRegion, array @destRegion) {
	@world = @sourceRegion[0]['world'];
	@xOffset = @destRegion[0]['x'] - @sourceRegion[0]['x'];
	@yOffset = @destRegion[0]['y'] - @sourceRegion[0]['y'];
	@zOffset = @destRegion[0]['z'] - @sourceRegion[0]['z'];
	_iterate_cuboid(@sourceRegion[0], @sourceRegion[1], closure(@x, @y, @z) {
		@block = get_blockdata_string(array(@x, @y, @z, @world));
		set_blockdata_string(array(@x + @xOffset, @y + @yOffset, @z + @zOffset, @world), @block);
	});
}

/**
 * Given a region, deletes all the blocks in it. @withQueue is necessary to ensure some blocks destroy
 * correctly, (also for performance reasons) but for "standard" blocks in small regions, this can be set to false.
 */
proc _removeBlocksInRegion(array @region, boolean @withQueue = true) {
	@world = @region[0]['world'];
	@queue = string(rand());
	_iterate_cuboid(@region[0], @region[1], closure(@x, @y, @z) {
		if(@withQueue) {
			queue_push(closure(){
				set_block(array(@x, @y, @z, @world), 'AIR');
			}, @queue);
		} else {
			set_block(array(@x, @y, @z, @world), 'AIR');
		}
	});
}

/**
 * For simple block replacements where all blocks should be set to the same.
 */
proc _setBlocksInRegion(@region, @block) {
	@world = @region[0]['world'];
	_iterate_cuboid(@region[0], @region[1], closure(@x, @y, @z) {
		set_timeout(50, closure() {
			set_block(array(x: @x, y: @y, z: @z, world: @world), @block);
		});
	});
}