# Save the mapworld every 5 minutes to support automatic placement of map ID markers in dynmap.
set_interval(5 * 60 * 1000, closure() { save_world('mapworld'); });
