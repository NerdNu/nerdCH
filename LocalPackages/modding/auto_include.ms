include('players.ms')

# Return true if the player has the specified potion effect, identified by numeric type ID.

proc(_has_peffect, @player, @potionID,
	foreach (get_peffect(@player), @effect,
		if (@effect[id] == @potionID) {
			return (true)
		}
	)
	return (false)
)


# _lb_retention_days()
#
# Return the duration to use for rollbacks and redos as an integer in days. 
# This value is set as 'lb.retention.days' in plugins/CommandHelper/main.ms. 
# If unspecified, it defaults to 21.

proc(_lb_retention_days,
	@days = import('lb.retention.days')
	return (if(is_null(@days), 21, @days))
)

proc(
	_3d_distance, @arr1, @arr2,
	return(
		floor(
			sqrt(
				  ((@arr2[0] - @arr1[0]) ** 2)
				+ ((@arr2[1] - @arr1[1]) ** 2)
				+ ((@arr2[2] - @arr1[2]) ** 2)
			)
		)
	)
)

proc(_add_flags, @region, @timeout, @tries,
	if(@tries < 1) {
		msg(color(RED).'Default flags added unsuccessfully.')
	} else {
		if(sk_region_exists(@region)) {
			call_alias('/addflags '.@region)
		} else {
			# WorldGuard 6 handles /region define asynchronously.
			set_timeout(@timeout, closure(){
				_add_flags(@region, @timeout, @tries - 1)
			})
		}
	}
)
