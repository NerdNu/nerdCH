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
        
        
#Gets the mods and admins on right now
proc(_get_mods,
        assign(@mods, array())
        assign(@ap, all_players())
        foreach(@ap, @p,
                if(array_contains(pgroup(@p), 'Moderators'), array_push(@mods, @p))
                if(array_contains(pgroup(@p), 'ModMode'), array_push(@mods, @p))
        )
        assign(@admins, _get_admins())
        foreach(@admins, @admin,
                array_push(@mods, @admin)
        )
        return(@mods)
)

#Gets just the admins on right now
proc(_get_admins,
        assign(@admins, array())
        assign(@ap, all_players())
        foreach(@ap, @p,
                if(or(
                        array_contains(pgroup(@p), 'HeadAdmins'),
                        array_contains(pgroup(@p), 'CAdmins'),
                        array_contains(pgroup(@p), 'TechAdmins'),
                        array_contains(pgroup(@p), 'SAdmins'),
                        array_contains(pgroup(@p), 'PAdmins')
                ), array_push(@admins, @p))
        )
        return(@admins)
)

#Messages all mods and admins
proc(_mbroadcast, @msg,
        foreach(_get_mods(), @m,
                tmsg(@m, @msg)
        )
        /*foreach(_get_admins(), @a,
                tmsg(@a, @msg)
        )*/
)

proc(_getonlinename, @name,
    if(equals(@name, '~console'), return('console'))
    assign(@pattern, concat('^', to_lower(strip_colors(@name))))
    foreach(all_players(), @p,
        assign(@m, reg_match(@pattern, to_lower(strip_colors(@p))))
        if(gt(array_size(@m), 0),
            return(@p)))
    return(null))

proc(_contains, @needle, @haystack,
        assign(@repl, replace(to_lower(@haystack), to_lower(@needle), ''))
        if(equals(to_lower(@haystack), to_lower(@repl)), return(false), return(true))
)
