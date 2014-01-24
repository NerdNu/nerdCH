
console('Starting up the marquees')
if(is_array(get_value('chmarquee.list'))){
	foreach(get_value('chmarquee.list'), @marquee,
		_start_marquee(@marquee)
	)
}

