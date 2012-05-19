/*
    persistence layout:
    
    chmail.
        |
        +- inbox.<username> (array) # storage of actual mail messages.
        |           |
        |           +- message: {<sender>, <msg>, 'mail'}
        |           |
        |           +- item: {<sender>, '<itemid[:data]>,<count>', 'item'}
        |           |
        |           +- multiline message: {<sender>, <msg>, 'multiline-mail'}
        |
        +- options (array) # systemwide options.
        |   |
        |   +- <name>: value
        |
        +- poptions.<username> (array) # for users to customise their experience
        |   |
        |   +- <name>: value
        |   
        +- tracking.<username>.<trackid> (variable) # tracking of things like cooldown timeouts
        
        Permission nodes:
        chmail.send
        chmail.send.bypasstimeout
        chmail.send.item
        chmail.receive.item
        chmail.send.item.self
        chmail.send.item.allworlds
        
        System options:
        sendtimeout
        
        Player options
        sendtimeout (overrides system option)

*/

include('dispatch.ms')
include('util.ms')
include('read.ms')
include('send.ms')
include('senditem.ms')

# Proc that will initialize multiline mail composition
proc(_init_mail_chat, @recipient,
    import(@mail_messages)
    import(@recipients)
    
    # Add the user to the list of people composing mail, and add their message's recipient.
    assign(@mail_messages[to_lower(player())], null)
    export(@mail_messages)
    
    assign(@recipients[to_lower(player())], @recipient)
    export(@recipients)
    
    # Are there already people composing mail?
    # (check for an empty array too, just in case something derped ##wait until we make sure it actually works!##)
    if(not(is_null(@mail_messages)) || length(@mail_messages) == 0,
        # If there aren't, go ahead and bind everything.
        
        # Event for accumulating chat messages to be sent back to the user upon completion of their mail message
        bind(player_chat, 'mail-hold-back-chat', null, @event,
        
            import(@mail_messages)
            
            # Is the user composing mail?
            if(array_index_exists(@mail_messages, to_lower(player())),
                # If they are, die. They're not chatting anything :P
                cancel()
                return()
                
            , # else
                # If they aren't, first make sure that their chat doesn't go to the people composing mail.
                foreach(array_keys(@mail_messages), @player,
                    foreach(@event[recipients], @i,
                        if(array_contains_ic(@event[recipients][@i], @player),
                            array_remove(@event[recipients], @i)
                        )
                    )
                )
                
                # Then, add their chat to each mail-composing player's hold queue.
                import(@held_back_chat)
                # The pinfo(4) here is to make sure the player's display name is used (instead of just player()) as it appears in the chat.
                assign(@message, concat('<', pinfo(4), '> ', @event[message]))
                
                foreach(array_keys(@mail_messages), @player,
                    assign(@held_back_chat[@player], @message)
                )
                
                export(@held_back_chat)
                
            )
        )
        
        # Event for composing multi-line mail messages
        bind(player_chat, 'mail-compose', null, @event,
        
            import(@mail_messages)
            import(@recipients)
            
            # Is the player actually composing mail?
            if(not(array_contains_ic(array_keys(@mail_messages), to_lower(player()))),
                # If they aren't, die. Let's get everything to the right place, people!
                cancel()
                return()
                
            , # else
                # If they are, see what they typed.
                # But first, make sure their chat message doesn't actually end up being a chat message. :P
                assign(@event[recipients], null)
                
                switch(@event[message],
                    '-send',
                        # If they typed -send, send off the message!
                        _send_mail(player(), @recipients[to_lower(player())], @mail_messages[to_lower(player())], 'multiline-mail')
                        # And let them know it was sent, of course.
                        msg(color(green), 'Mail successfully sent to ', color(yellow), @recipients[to_lower(player())], color(green), '!')
                        
                        # Resolve their removal from the mail-composing list.
                        _resolve_mail_list_removal()
                    ,
                    '-cancel',
                        # If they typed -cancel, toss out the message and remove them from the mail-composing and recipient lists
                        # without actually sending or saving anything.
                        msg(color(c), 'Message canceled.')
                        
                        # Resolve their removal from the mail-composing list.
                        _resolve_mail_list_removal()
                    ,
                    # default
                        # If they didn't type a "command", start/continue writing to their mail message.
                        # Firstly, though, is there actually a mail message there yet?
                        if(not(@mail_messages[to_lower(player())]),
                            # If not, simply set the mail message to the chat message.
                            assign(@mail_messages[to_lower(player())], @event[message])
                            
                        , # else
                            # Otherwise, append to the mail message instead.
                            assign(@mail_messages[to_lower(player())], concat(@mail_messages[to_lower(player())], '\n', @event[message]))
                        )
                        
                        export(@mail_messages)
                        
                        # Then, we give them back what they typed in the chat, for readability and mental organization.
                        msg(color(7), @event[message])
                    #
                )
            )
        )
    )
)
