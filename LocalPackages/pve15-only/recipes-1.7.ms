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
/*
add_recipe(
	array(
		type: 'SHAPELESS', 
		result: array(type: '12', data: 1, qty: 1), 
		ingredients: array('12', '351:1')
	)
)
*/

# Seamless double stone slabs upper
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 8, qty: 2), 
		shape: array('AA ', 'AA ', '   '), 
		ingredients: array('A': 44)
	)
)

# Seamless double stone slabs lower
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 8, qty: 2), 
		shape: array('   ', 'AA ', 'AA '), 
		ingredients: array('A': 44)
	)
)

# Seamless double sandstone slabs upper
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 9, qty: 2), 
		shape: array('AA ', 'AA ', '   '), 
		ingredients: array('A': array(type: 44, data: 1, qty: 1))
	)
)

# Seamless double sandstone slabs lower
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 9, qty: 2), 
		shape: array('   ', 'AA ', 'AA '), 
		ingredients: array('A': array(type: 44, data: 1, qty: 1))
	)
)

# Seamed double stone slabs upper left (and right)
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 0, qty: 1),
		shape: array('A  ', 'A  ', '   '), 
		ingredients: array('A': array(type: 44, data: 0, qty: 1))
	)
)

# Seamed double stone slabs lower left (and right)
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 0, qty: 1),
		shape: array('   ', 'A  ', 'A  '), 
		ingredients: array('A': array(type: 44, data: 0, qty: 1))
	)
)

# Seamed double stone slabs upper middle
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 0, qty: 1),
		shape: array(' A ', ' A ', '   '), 
		ingredients: array('A': array(type: 44, data: 0, qty: 1))
	)
)

# Seamed double stone slabs lower middle
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 0, qty: 1),
		shape: array('   ', ' A ', ' A '), 
		ingredients: array('A': array(type: 44, data: 0, qty: 1))
	)
)

# 1.8 Mossy stone brick
add_recipe(
	array(
		type: 'SHAPELESS',
		result: array(type: 98, data: 1, qty: 1),
		ingredients: array('98', '106')
	)
)

# 1.8 Chiseled stone brick upper left (and right)
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 98, data: 3, qty: 1),
		shape: array('A  ', 'A  ', '   '), 
		ingredients: array('A': array(type: 44, data: 5, qty: 1))
	)
)

# 1.8 Chiseled stone brick lower left (and right)
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 98, data: 3, qty: 1),
		shape: array('   ', 'A  ', 'A  '), 
		ingredients: array('A': array(type: 44, data: 5, qty: 1))
	)
)

# 1.8 Chiseled stone brick upper middle
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 98, data: 3, qty: 1),
		shape: array(' A ', ' A ', '   '), 
		ingredients: array('A': array(type: 44, data: 5, qty: 1))
	)
)

# 1.8 Chiseled stone brick lower middle
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 98, data: 3, qty: 1),
		shape: array('   ', ' A ', ' A '), 
		ingredients: array('A': array(type: 44, data: 5, qty: 1))
	)
)

# 1.8 Cracked stone brick
add_recipe(
	array(
		type: 'FURNACE',
		result: array(type: 98, data: 2, qty: 1),
		input: array(type: 98, data: 0)
	)
)

# 1.8 Moss stone
add_recipe(
	array(
		type: 'SHAPELESS',
		result: array(type: 48, data: 0, qty: 1),
		ingredients: array('4', '106')
	)
)

