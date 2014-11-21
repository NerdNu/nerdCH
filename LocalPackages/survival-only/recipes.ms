# Chiseled Stone Brick
add_recipe(
        array(
                type: 'SHAPELESS',
                result: array(type: '98', data: 3, qty: 1),
                ingredients: array('44:5', '44:5')
        )
)

# Mossy Cobble
add_recipe(
        array(
                type: 'SHAPELESS',
                result: array(type: '48', data: 0, qty: 1),
                ingredients: array('106', '4')
        )
)

# Mossy Stone Brick
add_recipe(
        array(
                type: 'SHAPELESS',
                result: array(type: '98', data: 1, qty: 1),
                ingredients: array('106', '98')
        )
)
/*
# Double Smooth Stone Slab
add_recipe(
	array(
		type: 'SHAPELESS',
		result: array(type: '43', data: 8, qty: 2),
		ingredients: array('44', '44', '44', '44')
	)
)

# Double Sandstone Slab
add_recipe(
	array(
		type: 'SHAPELESS',
		result: array(type: '43', data: 1, qty: 2),
		ingredients: array('44:1', '44:1', '44:1', '44:1')
	)
)
*/

# Seamless double stone slabs upper left
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 8, qty: 2), 
		shape: array('AA ', 'AA ', '   '), 
		ingredients: array('A': 44)
	)
)

# Seamless double stone slabs upper right
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 8, qty: 2), 
		shape: array(' AA', ' AA', '   '), 
		ingredients: array('A': 44)
	)
)

# Seamless double stone slabs lower left
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 8, qty: 2), 
		shape: array('   ', 'AA ', 'AA '), 
		ingredients: array('A': 44)
	)
)

# Seamless double stone slabs lower right
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 8, qty: 2), 
		shape: array('   ', ' AA', ' AA'), 
		ingredients: array('A': 44)
	)
)

# Seamless double sandstone slabs upper left
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 9, qty: 2), 
		shape: array('AA ', 'AA ', '   '), 
		ingredients: array('A': array(type: 44, data: 1, qty: 1))
	)
)

# Seamless double sandstone slabs upper right
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 9, qty: 2), 
		shape: array(' AA', ' AA', '   '), 
		ingredients: array('A': array(type: 44, data: 1, qty: 1))
	)
)

# Seamless double sandstone slabs lower left
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 9, qty: 2), 
		shape: array('   ', 'AA ', 'AA '), 
		ingredients: array('A': array(type: 44, data: 1, qty: 1))
	)
)

# Seamless double sandstone slabs lower right
add_recipe(
	array(
		type: 'SHAPED', 
		result: array(type: 43, data: 9, qty: 2), 
		shape: array('   ', ' AA', ' AA'), 
		ingredients: array('A': array(type: 44, data: 1, qty: 1))
	)
)

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
