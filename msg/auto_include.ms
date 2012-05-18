#This set of commands, /msg, /r, and /cmsg replaces the built in message system
#and allows for colored messages, so they are more prominent

proc(_getonlinename, @name,
    if(equals(@name, '~console'), return(@name))
    assign(@pattern, concat('^', to_lower(strip_colors(@name))))
    foreach(all_players(), @p,
        assign(@m, reg_match(@pattern, to_lower(strip_colors(@p))))
        if(gt(array_size(@m), 0),
            return(@p)))
    return(null))

proc(_message, @highlight, @from, @to, @text,
        assign(@from2, _getonlinename(@from))
        assign(@to2,   _getonlinename(@to))
        if(or(equals(@from2, null), equals(@to2, null)),
            msg(concat(color(red), 'Error: that player is not online!'))
            return())
        #if(equals(@to2, @from2),
        #    msg(concat(color(red), 'foreveralone.png'))
        #    return())
        assign(@text2, concat(if(equals(@highlight, 1),
            color(green),
            color(white)), @text))
        
        msg(       concat(color(gray), '[me -> ', strip_colors(@to2),   '] ', @text2))
        tmsg(@to2, concat(color(gray), '[', strip_colors(@from2), ' -> me] ', @text2))
        
        store_value(concat('last_message_', to_lower(strip_colors(@to2))), to_lower(strip_colors(@from2)))
        store_value(concat('last_message_', to_lower(strip_colors(@from2))), to_lower(strip_colors(@to2))))
