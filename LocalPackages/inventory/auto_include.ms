proc _parse_item(@material, @quantity) {
	# You can't just call data_name(). It doesn't understand 1.13 materials.
	# Remove the minecraft: prefix, if present.
	@NAMESPACE = 'MINECRAFT:';
	@material = to_upper(@material);
	if (string_starts_with(@material, @NAMESPACE)) {
		@material = substr(@material, length(@NAMESPACE));
	}

	if (is_integral(@material)) {
		@type = data_name(@material);
	} else if (string_contains(@material, ':')) {
		# data_name() understands '1:1' but not 'stone:1'.
		# So turn 'stone:1' into '1:1'.
		@parts = split(':', @material, 1);
		@materialId = if(is_integral(@parts[0]), @parts[0], data_values(@parts[0]));
		@type = data_name(@materialId . ':' . @parts[1]);
	} else {
		# @material is a type name, with no numeric ID or data.
		@type = @material;
	}

	return (array('name': @type, 'damage': 0, 'qty': @quantity));
}
