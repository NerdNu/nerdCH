proc(_send_hand_item, @target, @i, @count,
    if(player() == '~console',
        msg(color(red), 'You are console. You have no hand!')
        return(false)
    )
    
    assign(@hand, pinv(player(), null))
        
    # If there's nothing there, there's not much else to do
    if(is_null(@hand),
        msg(color(red), 'There\'s nothing in your hand!')
        return(false)
    , # else
        assign(@item, concat(@hand['type'], ':', @hand['data']))
        
        # How many of the item is in their hand?
        assign(@handcount, @hand['qty'])
        
        # If an amount wasn't specified, grab the whole thing
        if(@count == 'i1',
            _mail_debug('No amount was specified. Sending everything.')
            
            set_pinv(player(), array(null: null))
            
            _mail_debug('Removed item')
            
            # No checking necessary. B)
            _send_mail(player(), @target, concat(@item, ',', @handcount), 'item')
            
            return(true)
        , # else
            # Did the user specify more than they had?
            _mail_debug(sconcat('Seeing if', @handcount, 'is greater than or equal to', @count))
            
            if(@handcount >= @count,
                assign(@left, @handcount - @count)
                
                if(!@left,
                    set_pinv(array(null: null))
                    
                    _mail_debug('Removed item')
                , # else
                    assign(@leftovers, @hand)
                    array_set(@leftovers, 'qty', @left)
                    
                    set_pinv(player(), array(null: @leftovers))
                    
                    _mail_debug(sconcat('Leaving item in hand with' @leftovers))
                )
                
                # Locked 'n ready, cap'n!
                _send_mail(player(), @target, concat(@item, ',', @count), 'item')
                
                return(true)
            , # else
                msg(color(red), 'You don\'t have enough of the item!')
                return(false)
            )
        )
    )
)

proc(_send_item, @target, @i, @c,
    # Send items, removing them from this user's inventory.
    
    if(!has_permission(player(), 'chmail.send.item') &&
    !pisop(),
        die(concat(color(red), 'You do not have the required permissions to send items!'))
    )
    
    # Restrict sending items to onesself only by permission.
    if(equals_ic(@target, player()) && 
    !has_permission(player(), 'chmail.send.item.self') &&
    !pisop(),
        die(concat(color(red), 'You do not have the required permissions to send items to yourself!'))
    )
    
    # Restrict users sending to other worlds, if they don't have permission.
    # Always allow the console to send to anyone.
    if(player() != '~console',
        assign(@sourceworld, pworld(player()))
    ,
        assign(@sourceworld, null)
    )
    
    if(ponline(@target),
        # Lets check if that player can receive items.
        if(!has_permission(@target, 'chmail.receive.item') &&
        !pisop(@target),
            die(concat(color(red), 'That player does not have the required permissions to receive items!'))
        )
        
        assign(@targetworld, pworld(@target))
    , # else
        assign(@targetworld, null)
    )
    
    if(!pisop() &&
    !has_permission(player(), 'chmail.send.item.allworlds') &&
    @targetworld != @sourceworld &&
    player() != '~console',
        die(concat(color(red), 'You do not have the required permissions to send items to other worlds or offline players!'))
    )
        
    # Use the item in their hand if they specified "hand"
    if(equals_ic(@i, 'hand'),
        return(_send_hand_item(@target, @i, @c))
    , # else
        assign(@item, _item_name_to_value(@i))
        
        if(!@item,
            # Oops. Maybe they did it backwards? Friendly reminder.
            die(concat(color(red),'Oops!') @i 'is not a valid item type!')
        )
        
        # Find out how many of the item the user has
        if(player() == '~console',
            assign(@itemcount, 99999999)
        , # else
            assign(@itemcount, phas_item(player(), @item))
        )
        
        # If no amount was specified, assume 1
        if(@c == 'i1',
            assign(@count, 1)
        , # else
            assign(@count, @c)
        )
    
        # Lets not give more than the user has!
        _mail_debug('Seeing if' @itemcount 'is greater than' @count)
        
        if(@itemcount >= @count,
            if(player() == '~console',
                assign(@taken, @count)
            , #else
                assign(@taken, ptake_item(player(), @item, @count))
            )
            
            # Double check we are taking the amount we want.
            if(@taken == @count,
                # Send off the payload.
                    
                # TODO: MIGHT revert to copying the other code here instead, as it could
                # be tailored a bit better :/
                _send_mail(player(), @target, concat(@item, ',', @count), 'item')
                
                return(true)
            , # else
                # Oops, give their junk back.
                pgive_item(player(), @item, @taken)
                
                msg(color(red), 'Oops, error occurred. Giving back your stuff!')
                
                return(false)
            )
        , # else
            msg(color(red), 'You don\'t have enough of this item!')
            return(false)
        )
    )
)