proc(_mail_dispatch, @args,
    # Parse the incoming command, depending on it's first
    # word.
    
    _mail_debug('_mail_dispatch called with ' @args)
    
    # Called with empty command?
    ifelse(array_index_exists(@args, 0),
        assign(@first, @args[0]) # pop first item
        array_remove(@args, 0)
    , # else
        assign(@first, '')    
    )
    
    switch(to_lower(@first),
        # Commands that aren't handled well should show their usage by default.
        
        'send',
            # /mail send <player> <message>
            _mail_debug('_mail_dispatch.send')
            
            # Make sure there is at least 2 items in the args.
            if(array_index_exists(@args, 1),
                # Everything from second item and on is the message.
                _mail_debug('sending' @args[1..] 'to' @args[0])
                
                # Send off the payload.
                if(_send_mail(player(), @args[0], array_implode(@args[1..])),
                    die(concat(color(green), 'Mail successfully sent to ', @args[0]))
                , # else
                    die(concat(color(red), 'Oops, there was an error! Try again later?'))
                )
            , # else
                die('Usage: /mail send <player> <message>')
            ),
            
        'set',
            # /mail set [global] <node> <value>
            _mail_debug('_mail_dispatch.set')
            
            # Need at least 2 args
            if(array_index_exists(@args, 1),
                # Is the player asking to set a global value?
                if(equals(to_lower(@args[0]), 'global'),
                    # Throw away global.
                    array_remove(@args, 0)
                    
                    if(not(has_permission(player(), 'chmail.globalset')),
                        die(concat(color(red), 'You do not have permission to set global values!'))
                    )
                    
                    # Make sure there are enough args! (2 needed)
                    if(array_index_exists(@args, 1),
                        # Set the option, and leave the building.
                        _set_option(@args[0], array_implode(@args[1..]))
                        
                        die(concat(color(green), 'Global' @args[0] 'set to' array_implode(@args[1..])))
                    , # else
                        # Complain.
                        die('Usage: /mail set global <option> <value>')
                    )
                , # else
                    # Make sure there are enough args!
                    if(array_index_exists(@args, 1),
                        # Set the option, and leave the building.
                        _set_poption(player(), @args[0], array_implode(@args[1..]))
                        
                        die(concat(color(green), @args[0] 'set to' array_implode(@args[1..])))
                    , # else
                        die('Usage: /mail set <option> <value>')
                    )
                )
            , # else
                die('Usage: /mail set [global] <option> <value>')
            ),
            
        'senditem',
            # /mail send <player> <item> [count]
            _mail_debug('_mail_dispatch.senditem')
            
            # Check number of arguments.
            if(and(lte(length(@args), 3), gte(length(@args), 2)),
                # Send off payload.
                
                if(equals(length(@args), 2),
                    # Push the special value "i1" onto the last arg if an amount wasn't specified.
                    # This way we send the whole stack if the item is "hand", or send 1 item if it's a name.
                    array_push(@args, i1)
                )
                
                if(_send_item(@args[0], @args[1], @args[2]),
                    die(concat(color(green), 'Item(s) successfully sent to ', @args[0]))
                )
            , # else
                die('Usage: /mail send <player> <item> [count]')
            ),
            
        'accept',
            _mail_debug('_mail_dispatch.accept')
            # /mail accept <id>
            
            # Check arguments.
            if(@args,
                # Try to accept items, as many as possible, then delete the mail.
                # If not all items were received, amend the mail and keep it.
                
                if(not(_accept_item(@args[0])),
                    die(concat(color(red), 'Oops, there was an error! Try again later?'))
                )
            , # else
                die('Usage: /mail accept <id>')
            ),
            
        'inbox',
            # /mail inbox
            _mail_debug('_mail_dispatch.index')
            
            if(array_index_exists(@args, 0),
                assign(@page, @args[0])
            , # else
                assign(@page, 1)
            )
            
            # Display brief index, max 20 chars per mail.
            if(_read_index(player(), @page),
                die(concat(color(yellow), '/mail to see available options. /mail inbox <page> for more pages.'))
            ),
            
        'read',
            # /mail read [id]
            _mail_debug('_mail_dispatch.read')
            
            if(array_index_exists(@args, 0),
                # /mail read <id>
                _mail_debug('reading id' @args[0])
                
                # Display a single mail.
                ifelse(_read_mail_id(player(), @args[0]),
                    die('Type /mail to see available options.')
                , #else
                    die(concat(color(red), 'That id does not exist'))
                )
            , # else
                die('Usage: /mail read <id[,id][,id-id]>')
            ),
            
        'clear',
            # /mail clear
            _mail_debug('_mail_dispatch.clear')
            
            _clear_player_mail(player())
            die(concat(color(green), 'Mail successfully cleared.')),
            
        'delete',
            # /mail delete <id>
            _mail_debug('_mail_dispatch.delete')
            
            # Check args. Don't care about extras.
            ifelse(array_index_exists(@args, 0),
                _mail_debug('deleting id' @args[0])
                
                # Delete a single mail.
                # TODO: Make sensitive to item mails.
                ifelse(_del_mail(player(), @args[0]),
                    die(concat(color(green), 'Message with id' @args[0] 'deleted.'))
                , # else
                    die(concat(color(red), 'That index does not exist!'))
                )
            )
            
            msg('Usage: /mail delete <id>'),
            
        # default
        _mail_debug('_mail_dispatch.help')
        
        msg('The following commands are available:')
        msg('- ', color(green), '/mail', color(white), ': show this message')
        if(has_permission('chmail.send'),
            msg('- ', color(green), '/mail send <player> <message>', color(white), ': send <message> to player.')
        )
        # A little long for the in-game console. Possibly move the long explanation to the actual trigger, when incorrectly put?
        if(has_permission('chmail.send.item'),
            msg('- ', color(green), '/mail senditem <player> <item> [count]', color(white), ': send [count] (default 1) of <item> to <player> if you have it in your inventory. <item> can also be "hand" for the item in your hand.')
        )
        msg('- ', color(green), '/mail read <id[,id][,id-id]>', color(white), ': read messages by id.')
        msg('- ', color(green), '/mail inbox [page]', color(white), ': read mail index.')
        if(has_permission('chmail.receive.item'),
            msg('- ', color(green), '/mail accept <id>', color(white), ': accept an item a player sent you.')
        )
        msg('- ', color(green), '/mail clear', color(white), ': clear all messages.')
        msg('- ', color(green), '/mail set [global] <option> <value>', color(white), ': set an option.')
        die(concat('- ', color(green), '/mail delete <id>', color(white), ': delete message <id>.'))
    )
)