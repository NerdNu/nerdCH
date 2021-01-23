# Parse the biome parameter of PvE perfect villager commands (villagers.msa).
# Return the biome, if valid, or else show an error message and return null.
proc _villager_biome(@biome) {
    @biome = to_lower(if(@biome == '', 'plains', @biome));
    @VALID_BIOMES = array('desert', 'jungle', 'plains', 'savanna', 'snow', 'swamp', 'taiga');
    if (array_contains(@VALID_BIOMES, @biome)) {
        return (@biome);
    } else {
        msg(color('RED') . 'Invlid villager biome.');
        msg(color('GOLD') . 'Valid biomes: ' . color('YELLOW') . array_implode(@VALID_BIOMES, color('WHITE') . ', ' . color('YELLOW')));
        return (null);
    }
}
