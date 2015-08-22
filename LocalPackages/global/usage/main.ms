
if(has_value('usagestats')){
	// Go through and clear out stats with less than 10 minutes of data
	@data = get_value('usagestats');
	@toDelete = array();
//	array_remove(@data['players'], 08260826)
	foreach(@player: @value in @data['players']){
		if(@value['min'] < 1000 * 60 * 10){
			@toDelete[] = @player;
		}
	}
	foreach(@p in @toDelete){
		console('Removing '.string(@data['players'][@p]['name']).' from usage stats, as they have less than 10 minutes of play time.');
		array_remove(@data['players'], @p);
	}
	store_value('usagestats', @data);
}

#Every minute, write out to the usagestats value the online player's minute counts. 
#Also, write out the number of days played, and the current date. If the current date
#is today, don't increment the days, but if it isn't, increment the days.

if(array_contains(array('creative', 'pve', 'survival'), import('sharedata.source'))){

export('usage.lastRun', time());
set_interval(1000 * 60, 0, closure(){
	@startTime = time();
	@data = get_value('usagestats');
	if(!is_array(@data)){
		@data = associative_array();
	}
	@data['lastUpdate'] = time();
	if(!array_index_exists(@data, 'players')){
		@data['players'] = associative_array();
	}
	@players = @data['players'];
	@incrementTime = time() - import('usage.lastRun');
	export('usage.lastRun', time());
	@today = simple_date('yyMMdd');
	foreach(@player in all_players()){
		@uuid = _get_puuid(@player);
		if(!array_index_exists(@players, @uuid)){
			@players[@uuid] = array(
				min: 0,
				last: @today,
				days: 1,
				name: strip_colors(@player)
			);
		} else {
			@lastFacing = import(@player.'.lastFacing');
			if(@lastFacing != null && @lastFacing == pfacing(@player)){
				#They haven't moved from this spot, so keep going.
				continue();
			}
			export(@player.'.lastFacing', pfacing(@player));
			@players[@uuid]['min'] = @players[@uuid]['min'] + @incrementTime;
			if(@players[@uuid]['last'] != @today){
				@players[@uuid]['last'] = @today
				@players[@uuid]['days'] = @players[@uuid]['days'] + 1
			}
			# If the player changed their name, we need to update
			# this value to reflect that.
			@players[@uuid]['name'] = strip_colors(@player);
		}
	}
	@data['online'] = all_players()
	store_value('usagestats', @data)
//	console('Usage stats updated, took '.(time() - @startTime).'ms');
	if(time() > @startTime + 50){
		# Uh oh, it took longer than 50 ms, so lets report this to the console.
		console('Updating usage log took longer than 50ms! ('.(time() - @startTime).'ms)')
	}
})

}

