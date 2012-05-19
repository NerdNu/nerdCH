#TODO: Blacklisting (inc pots)

proc(_parseiargs, @input, 
    assign(@m, reg_match('^([^ :]+)(:[0-9]+)?( [0-9]+)?$', @input))
    if(array_index_exists(@m,0),
        assign(@itemid,  data_values(@m[1]))
        assign(@metadata, 0)
        assign(@quantity, if(equals(pmode(), 'CREATIVE'), 1, max_stack_size(@itemid)))
        
        #ITEM ID
        if(equals(@itemid, null),
            msg(concat(color('red'), 'Unknown item: ', @m[1]))
            return(null),
        #else:
            
            #METADATA
            if(not(equals(@m[2], null)),
                assign(@metadata, integer(substr(@m[2], 1))))
            
            #QUANTITY
            if(not(equals(@m[3], null)),
                assign(@quantity, min(512, integer(substr(@m[3], 1)))))
            
            return(array(@itemid, @metadata, @quantity))),
    #else:
        return(null)))
        #msg(concat(color(gray), 'Usage: /i <itemid>[:metadata] [quantity]'))
