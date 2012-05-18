proc(_assertperm, @name, @cmodetrumps
    if(not(or(
        pisop(),
        equals(@name, '~console'),
        or(
            has_permission(concat('nerdch.level.', @name)),
            and(
                equals(@cmodetrumps, 1),
                equals(pmode(), 'CREATIVE'))))),
     #then:   
        msg(concat(color(red), 'You do not have permission to do this!'))
        die())) 
