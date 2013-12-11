# Packed Ice: four ice in a square gives four packed ice.
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 174, data: 0, qty: 4), 
		shape: array('AA ', 'AA ', '   '), 
		ingredients: array('A': 79)
	)
)
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 174, data: 0, qty: 4), 
		shape: array('   ', 'AA ', 'AA '),
		ingredients: array('A': 79)
	)
)

# Podzol: dirt + leaves, implemented for all leaf types.
for (@i = 0, @i < 16, inc(@i),
	add_recipe(
		array(
			type: 'SHAPELESS', 
			result: array(type: 3, data: 2, qty: 1), 
			ingredients: array('3', '18:'.@i)
		)
	)
	add_recipe(
		array(
			type: 'SHAPELESS', 
			result: array(type: 3, data: 2, qty: 1), 
			ingredients: array('3', '161:'.@i)
		)
	)
)

# Red sand.
add_recipe(
	array(
		type: 'SHAPELESS', 
		result: array(type: '12', data: 1, qty: 1), 
		ingredients: array('12', '351:1')
	)
)

