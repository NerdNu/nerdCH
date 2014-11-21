#This set of commands, /msg, /r, and /cmsg replaces the built in message system
#and allows for colored messages, so they are more prominent

proc(_message, @highlight, @to, @text,
        assign(@from2, player())
        assign(@to2,   _getonlinename(@to))
        if(is_null(@to2),
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
        
        console(concat('[msg: ', @from2, ' -> ', @to2, '] ', @text))
        export(concat('last_message_', to_lower(strip_colors(@to2))), to_lower(strip_colors(@from2)))
        export(concat('last_message_', to_lower(strip_colors(@from2))), to_lower(strip_colors(@to2)))
)
