proc(_convertcolors, @text,
    return(reg_replace('&([0-9a-fA-F]{1})', concat(substr(color(0),0,1), '$1'), @text)))
    
# Record the time this file was loaded as the nominal restart time for /nextrestart.
store_value('nextrestart.startMillis', time())

