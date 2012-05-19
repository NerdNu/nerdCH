proc(_send_mail, @from, @to, @msg, assign(@type, null),
    # Send an abstract mail to someone.
    
    # Restrict permissions for this.
    if(player() != '~console' &&
    !has_permission(player(), 'chmail.send') &&
    !pisop(),
        die(color(red) . 'You do not have the required permissions to send mail!')
    )
    
    if(reg_count('[^a-zA-Z0-9_]', @to),
        die(color(red) . 'Bad username provided! Only letters, numbers and underscores allowed!')
    )
    
    # Keep the user from sending messages too quickly,
    # unless they have an overriding permission.
    assign(@timeout, _get_option('sendtimeout', 10))
    assign(@cooleddown, _cooleddown(@timeout, 'send'))
    assign(@hasperms, player() == '~console' || has_permission(player(), 'chmail.send.bypasstimeout') || pisop())
    
    if(not(@cooleddown) && not(@hasperms),
        die(color(red) . 'You need to wait' @timeout 'seconds between messages!')
    )
    
    if(is_null(@type),
        # allow for a reasonable default
        assign(@type, 'mail')
    )
    
    # Grab the player's mailbox
    assign(@mail, _player_mail(@to))
    
    # Creation of actual mail.
    assign(@msg, array(@from, @msg, to_lower(@type)))
    
    if(is_null(@mail),
        # Be absolutely sure @mail is an array
        assign(@mail, array())
    )
    
    # Add the mail to the list and store it.
    array_push(@mail, @msg)
    _update_player_mail(@to, @mail)
    
    # Let the player know.
    if(ponline(@to),
        tmsg(@to, color(green), 'You have mail! Type `/mail inbox` to view.')
    )
    
    return(true)
)
