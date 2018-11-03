# Prototype dragon fight changes

bind(creature_spawn, null, null, @event,
	if(equals(@event['type'],"ENDER_DRAGON"),
		set_timeout(1000, closure(
			# Double the max health of the dragon when it spawns without setting its health.
			runas(~console, '/minecraft:entitydata '.@event['id'].' {HealF:400,Attributes:[{Name:"generic.maxHealth",Base:400}]}')
		))
	)
)

bind(entity_damage_player, null, null, @event,
	# Make the dragon breath have special effects
	if(equals(@event['damager'],"AREA_EFFECT_CLOUD"),
		if(equals(@event['location']['world'],"world_the_end"),
			if(equals(entity_spec(@event['id'])['particle'],"DRAGON_BREATH"),
				set_peffect(@event['player'],20,1,10) #Wither player for 10 seconds
				set_peffect(@event['player'],25,1,10) #Levitate player for 10 second
			)
		)
	)
)

bind(entity_damage, null, null, @event,
	if(equals(@event['type'],"ENDER_DRAGON"),

		# When Shot
		if(equals(@event['cause'],"PROJECTILE"),
			set_peffect(@event['shooter'],15,1,5) #Blind player for 5 seconds when shot
		)

		# When punched
		if(equals(@event['cause'],"ENTITY_ATTACK"),
			set_peffect(@event['damager'],2,2,10) #Slow player for 10 seconds when hit
			set_peffect(@event['damager'],18,2,5) #Weaken player to make spamming ineffective
			set_peffect(@event['damager'],17,2,5) #Make player hungry to make spamming less effective
		)

		# When taking any damage
		for(@i=0,@i<rand(2,5),@i++){
			spawn_mob("BLAZE",1,array(rand(-32,32), rand(70,80), rand(-32,32), "world_the_end")) #Spawn blaze for support
		}
		for(@i=0,@i<rand(0,4),@i++){
			set_mob_effect(spawn_mob("SKELETON:STRAY",1,array(rand(-32,32), rand(70,80), rand(-32,32), "world_the_end"))[0],22,20,5) #Spawn strays for support (absorbtion to survive drop)
		}
	)
)
