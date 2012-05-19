proc(_accept_item, @i,
    # Accept an item a user has sent us. If the inv is filled and not all items are given,
    # save the rest for later.
    
    # Grab their mailbox
    assign(@mail, _player_mail(player()))
    assign(@id, @i - 1)
    
    try(
        # Make sure it's an actual item that we are grabbing.
        switch(@mail[@id][2], 
            'item',
                assign(@data, reg_split(',', @mail[@id][1])) # id,count
                
                # Keep track of how much was given, so we don't lose
                # items due to a full inv.
                assign(@left, @data[1] - pgive_item(player(), @data[0], @data[1]))
                
                if(!@left,
                    # Remove the item mail, as it is no longer useful.
                    
                    # _del_mail assumes a 1-based count, @id is 0-based.
                    _del_mail(player(), @id + 1) 
                    msg(color(green), 'Accepted items sent by' @mail[@id][0], '!')
                    
                    return(true)
                , # else
                    # Looks like we overflowed. Oops. Save the rest.
                    msg(color(red), 'Looks like your inventory is full.' color(green), 'Saving left over items for later :)')
                    
                    assign(@mail[@id][1], concat(@data[0], ',', @left))
                    _update_player_mail(player(), @mail)
                    
                    return(true)
                ),
            'mail',
                assign(@message, concat(color(red), 'There is no item associated with this id.')),
                
            # default
                assign(@message, '(This person sent you -something-, but I have no idea what to do with it!) :(')
        )
        
        msg('[', color(red), @mail[@id][0],color(white),'] ', $message)
        
        return(true)
    , @ex,
        return(false)
    )
)

proc(_read_index, @player, @page,
    assign(@inbox, _player_mail(@player))
    
    # Make sure the user really does have mail.
    if(is_null(@inbox) || length(@inbox) == 0,
        msg(color(red), 'No mail for' to_lower(@player), '.')
        return(false)
    , # else
        # Page the inbox, to not clutter the chatarea too much.
        assign(@pagelimit, _get_p_or_def_option(@player, 'pagesperindex', 5))
        
        assign(@pages, ceil(length(@inbox) / @pagelimit))
        
        # Make sure the page exists.
        if(@page > @pages,
            die(color(red) . 'Invalid inbox page! ( only' @pages 'pages exist )')
        )
        
        msg(color(yellow), 'Inbox for' to_lower(@player), ': [ Page' @page 'of' @pages ']')
        
        # Slice the actual pages we want
        assign(@mail, _page(@inbox, @pagelimit, @page))
        
        # Index for display
        # Depends on which page we are on!
        assign(@id, (@page - 1) * @pagelimit)
        
        foreach(@mail, @msg,
            # Check each message on the fly for it's type.
            switch(@msg[2], 
                'mail',
                    # Display up to 20 characters of the message.
                    # Use /mail read <id> to display full message.
                    
                    if(length(@msg[1]) < 20,
                        assign(@message, @msg[1])
                    ,
                        assign(@message, concat(@msg[1][..17], '...'))
                    ),
                'item',
                    # Quick n' dirty display of the item involved.
                    
                    assign(@data, reg_split(',', @msg[1])) # {item, count}
                    assign(@message, concat('[ ', @data[1] data_name(@data[0]), ' ]')), # [ <num> <item> ]
                # default
                    assign(@message, '(This person sent you -something-, but I have no idea what to do with it!) :(')
            )
            
            # Actually show the message!
            msg(@id + 1, ') [', color(red), @msg[0], color(white),'] ', @message)
            @id++
        )
        
        return(true)
    )
)

proc(_read_mail_id, @player, @i,
    # Read an individual mail.
    
    # Grab the users mailbox.
    assign(@inbox, _player_mail(@player))
    # _expand allows for `1,4-5,6` notation to select mails to view.
    assign(@mails, _expand(@inbox, @i, true))
    
    if(length(@mails) == 0, # This should always be an array.
        return(false)
    )
    
    # iterate over all the matched ids, and spit them out
    foreach(@mails, @mailitem,
        assign(@id, @mailitem[0])
        assign(@mail, @mailitem[1])
        
        # Check the type of the mail, and act on it.
        switch(@mail[2], 
            'mail',
                # Plain message
                assign(@message, @mail[1]),
            'item',
                # Item. Show helpful message on how to accept.
                assign(@data, reg_split(',', @mail[1]))
                assign(@message, concat('[ ', @data[1] data_name(@data[0]), ' ] Type', '`/mail accept ', @id, '`', 'to accept.')),
            # default
                assign(@message, '(This person sent you -something-, but I have no idea what to do with it!) :(')
        )
        
        # Display the message or item.
        msg(@id + 1,')' '[', color(red), @mail[0], color(white),'] ', @message)
    )
    
    return(true)
)

proc(_del_mail, @player, @id,
    # Delete an individual item.
    
    # Get their mailbox
    assign(@mail, _player_mail(@player))
    assign(@remid, @id - 1)
    
    # Make sure the id exists
    ifelse(is_array(@mail) && array_index_exists(@mail, @remid),
        # You are the weakest link. * snip *
        array_remove(@mail, @remid)
        
        _update_player_mail(@player, @mail)
        
        return(true)
    , # else
        return(false)
    )
)