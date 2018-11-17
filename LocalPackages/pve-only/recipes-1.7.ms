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
