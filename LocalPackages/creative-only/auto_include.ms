
proc(_ermagerd, @string,
	# Begin the transformations
	@string = reg_replace('(?i)oo?r?', 'er', @string)
	@string = reg_replace('a', 'er', @string)
	@string = reg_replace('A', 'ER', @string)
	@string = reg_replace('([^a-zA-Z])*?ermg([^a-zA-Z])', '$1ermagerd$2', @string)
	@string = reg_replace('([^a-zA-Z])*?my', '$1ma', @string)
	@string = reg_replace('[\\.,;]', '', @string) #Pfft, who needs punctuation
	return(@string)
)

