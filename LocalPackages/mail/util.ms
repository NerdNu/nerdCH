#export(assign(@_mail_debug, false))

# Will return {{id, item},...} from @array for an @input of 'x,y-z,a'
proc(_expand, @array, @input, assign(@decr, false),
    # Too lazy to comment this right now.
    assign(@parts, reg_split(',', @input))
    assign(@retn, array()) # Returned object
    
    foreach(@parts, @part,
        ifelse(
        is_integral(@part),
            if(@decr,
                assign(@index, subtract(@part, 1))
            , # else
                assign(@index, @part)
            )
            
            try(
                array_push(@retn, array(@index, @array[@index]))
            ),
        equals(reg_count('-', @part), 1), 
            assign(@range, reg_split('-', @part))
            
            if(@decr,
                assign(@first, subtract(@range[0], 1))
                assign(@last, subtract(@range[1], 1))
            , # else
                assign(@first, @range[0])
                assign(@last, @range[1])
            )
            
            if(lt(@first, @last),
                foreach(range(@first, @last), @id,
                    try(
                        console(@id @array[@id])
                        array_push(@retn, array(@id, @array[@id]))
                    )
                )
            )
        )
    )
    
    return(@retn)
)

proc(_cooleddown, @time, @id,
    if(player() == '~console',
        return(true)
    )
    
    assign(@node, concat('chmail.tracking.', strip_colors(player()), '.', @id))
    assign(@oldTime, get_value(@node))
    msg(@oldtime)
 
    if(and(
    not(is_null(@oldTime)),
    lt(divide(subtract(time(), @oldTime), 1000), @time)),
        return(false)
    , # else
        store_value(@node, time())
        return(true)
    )
)

# _page(array(1, 2, 3, 4, 5, 6, 7), 3, 1)
proc(_page, @array, @itemsperpage, @p,
    # @page = 0
    assign(@page, subtract(@p, 1))

    # @firstitem = 3 * 0 = 0
    assign(@firstitem, multiply(@itemsperpage, @page))
    
    # @lastitem = 0 + (3 - 1) = 2
    assign(@last, subtract(add(@firstitem, @itemsperpage), 1))
    
    # Limit to last item
    if(gte(@last, length(@array)),
        assign(@lastitem, subtract(length(@array), 1))
    , # else
        assign(@lastitem, @last)
    )
    
    # @pages = @array[0..2] = {0, 1, 2}
    assign(@pages, @array[cslice(@firstitem, @lastitem)])
    return(@pages)
)

proc(_player_mail, @player,
    assign(@mail, get_value(concat('chmail.inbox.', to_lower(strip_colors(@player)))))
    
    return(@mail)
)

proc(_update_player_mail, @player, @mail,
    store_value(concat('chmail.inbox.', to_lower(strip_colors(@player))), @mail)
)

# Proc for removing a player from the multiline-mail-composing list
proc(_resolve_mail_list_removal, assign(@player, player()),
    
    import(@mail_messages)
    import(@recipients)

    # Is there actually anybody composing mail?
    # (Again, checks for an empty array ##wait until it works!##)
    if(equals(@mail_messages, ''),
        throw(null, 'No one is composing multiline mail')
    
    , # else
        # Otherwise, carry on.
        
        # Is this the last person sending mail?
        if(equals(array_size(@mail_messages), 1),
            # If so, set the mail-composing and recipient lists to an empty string (equivalent to a nonexistent import()'d ivar),
            # and unbind the two mail chat events.
            assign(@mail_messages, '')
            assign(@recipients, '')
            export(@mail_messages)
            export(@recipients)
            unbind('mail-hold-back-chat')
            unbind('mail-compose')
        
        , # else
            # Otherwise, simply remove them from the lists.
            array_remove(@mail_messages, to_lower(@player))
            array_remove(@recipients, to_lower(@player))
            export(@mail_messages)
            export(@recipients)
        )
    )
)

proc(_get_p_or_def_option, @p, @n, assign(@default, null),
    return(_get_poption(@p, @n, _get_option(@n, @default)))
)

proc(_get_option, @n, assign(@default, null),
    assign(@name, to_lower(@n))
    assign(@id, concat('chmail.options.', @name))
    
    if(has_value(@id),
        assign(@opt, get_value(@id))
    , # else
        assign(@opt, @default)
    )
    
    return(@opt)
)

proc(_set_option, @n, @value,
    assign(@name, to_lower(@n))
    assign(@id, concat('chmail.options.', @name))
    
    store_value(@id, @value)
)

proc(_clear_option, @n,
    assign(@name, to_lower(@n))
    assign(@id, concat('chmail.options.', @name))
    
    clear_value(@id)
)

proc(_get_poption, @player, @n, assign(@default, null),
    assign(@name, to_lower(@n))
    assign(@id, concat('chmail.poptions.', to_lower(strip_colors(@player)), '.', @name))
    
    if(has_value(@id),
        assign(@opt, get_value(@id))
    , # else
        assign(@opt, @default)
    )
    
    return(@opt)
)

proc(_set_poption, @player, @n, @value,
    assign(@name, to_lower(@n))
    assign(@id, concat('chmail.poptions.', to_lower(strip_colors(@player)), '.', @name))
    
    store_value(@id, @value)
)

proc(_clear_poption, @player, @n,
    assign(@name, to_lower(@n))
    assign(@id, concat('chmail.poptions.', to_lower(strip_colors(@player)), '.', @name))
    
    clear_value(@id)
)

proc(_clear_poptions, @player,
    assign(@options, get_values(concat('chmail.poptions.', to_lower(strip_colors(@player)))))
    
    foreach(@options, @option,
        clear_value(@option)
    )
)
    

proc(_clear_player_mail, @player,
    clear_value(concat('chmail.inbox.', to_lower(strip_colors(@player))))
)

proc(_clear_all_mail,
    assign(@inboxes, get_values(concat('chmail.inbox')))
    
    foreach(@inboxes, @inbox,
        clear_value(@inboxes)
    )
)

proc(_item_name_to_value, @i,
    # Translates an item's human-readable name, if present, into its
    # integer equivalent. Keeps damage values in mind.
    
    assign(@parts, reg_split(':', @i)) # {item [, damage]}
    
    switch(length(@parts),
        # Check to see if damage data was included.
        2,
            assign(@item, data_values(@parts[0]))
            
            # Make sure the value returned was sane. If not, bail.
            if(not(is_null(@item)),
                assign(@retn, concat(@item, ':', @parts[1]))
            , # else
                assign(@retn, null)
            ),
        1,
            assign(@retn, data_values(@parts[0])),
        # default
        assign(@retn, null)
    )
    
    return(@retn)
)

proc(_mail_debug, @msg,
    import(@_mail_debug)
    
    if(equals(@_mail_debug, true),
        console(@msg)
    )
)
