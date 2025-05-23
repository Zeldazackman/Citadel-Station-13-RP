var/list/blobs = list()

/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	desc = "A thick wall of writhing tendrils."
	light_range = 2
	density = FALSE // This is false because blob mob AI's walk_to() proc appears to never attempt to move onto dense objects even if allowed by CanPass().
	pass_flags_self = ATOM_PASS_BLOB
	opacity = FALSE
	anchored = TRUE
	layer = MOB_LAYER + 0.1
	integrity = 0
	var/point_return = 0 //How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	integrity_max = 30
	var/health_regen = 2 //how much health this blob regens when pulsed
	var/pulse_timestamp = 0 //we got pulsed when?
	var/heal_timestamp = 0 //we got healed when?
	var/mob/observer/blob/overmind = null
	var/base_name = "blob" // The name that gets appended along with the blob_type's name.

/obj/structure/blob/Initialize(mapload, new_overmind)
	. = ..()
	if(new_overmind)
		overmind = new_overmind
	update_icon()
	if(!integrity)
		integrity = integrity_max
	setDir(pick(GLOB.cardinal))
	blobs += src
	return INITIALIZE_HINT_LATELOAD

// since this WILL cause qdels (on other atoms) to be invoked
/obj/structure/blob/LateInitialize()
	consume_tile()

/obj/structure/blob/Destroy()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Expand() is no longer broken, no check necessary.
	blobs -= src
	overmind = null
	return ..()

/obj/structure/blob/update_icon() //Updates color based on overmind color if we have an overmind.
	. = ..()
	if(overmind)
		name = "[overmind.blob_type.name] [base_name]" // This is in update_icon() because inert blobs can turn into other blobs with magic if another blob core claims it with pulsing.
		color = overmind.blob_type.color
		set_light(3, 3, color)
	else
		name = "inert [base_name]"
		color = null
		set_light(0)

// Blob tiles are not actually dense so we need Special Code(tm).
/obj/structure/blob/CanAllowThrough(atom/movable/mover, turf/target)
	// density is false, can't trust parent procs
	if(check_standard_flag_pass(mover))
		return TRUE
	else if(istype(mover, /mob/living))
		var/mob/living/L = mover
		if(L.has_iff_faction(MOB_IFF_FACTION_BLOB))
			return TRUE
	else if(istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if(isliving(P.firer))
			var/mob/living/L = P.firer
			if(L.has_iff_faction(MOB_IFF_FACTION_BLOB))
				return TRUE
	return FALSE

/obj/structure/blob/examine(mob/user, dist)
	. = ..()
	if(!overmind)
		. += "It seems inert." // Dead blob.
	else
		. += overmind.blob_type.desc

/obj/structure/blob/get_description_info()
	if(overmind)
		return overmind.blob_type.effect_desc
	return ..()

/obj/structure/blob/emp_act(severity)
	if(overmind)
		overmind.blob_type.on_emp(src, severity)

/obj/structure/blob/proc/pulsed()
	if(pulse_timestamp <= world.time)
		consume_tile()
		if(heal_timestamp <= world.time)
			adjust_integrity_blob(health_regen)
			heal_timestamp = world.time + 2 SECONDS
		update_icon()
		pulse_timestamp = world.time + 1 SECOND
		if(overmind)
			overmind.blob_type.on_pulse(src)
		return TRUE //we did it, we were pulsed!
	return FALSE //oh no we failed

/obj/structure/blob/proc/pulse_area(pulsing_overmind = overmind, claim_range = 10, pulse_range = 3, expand_range = 2)
	src.pulsed()
	var/expanded = FALSE
	if(prob(70) && expand())
		expanded = TRUE

	var/list/blobs_to_affect = list()
	for(var/obj/structure/blob/B in urange(claim_range, src, 1))
		blobs_to_affect += B

	shuffle_inplace(blobs_to_affect)

	for(var/L in blobs_to_affect)
		var/obj/structure/blob/B = L
		if(!B.overmind && !istype(B, /obj/structure/blob/core) && prob(30))
			B.overmind = pulsing_overmind //reclaim unclaimed, non-core blobs.
			B.update_icon()

		var/distance = get_dist(get_turf(src), get_turf(B))
		var/expand_probablity = max(50 / (max(distance, 1)), 1)
		if(overmind)
			expand_probablity *= overmind.blob_type.spread_modifier
			if(overmind.blob_type.slow_spread_with_size)
				expand_probablity /= (blobs.len / 10)

		if(distance <= expand_range)
			var/can_expand = TRUE
			if(blobs_to_affect.len >= 120 && B.heal_timestamp > world.time)
				can_expand = FALSE
			if(!expanded && can_expand && B.pulse_timestamp <= world.time && prob(expand_probablity))
				var/obj/structure/blob/newB = B.expand(null, null, !expanded) //expansion falls off with range but is faster near the blob causing the expansion
				if(newB)
					if(expanded)
						qdel(newB)
					expanded = TRUE

		if(distance <= pulse_range)
			B.pulsed()

/obj/structure/blob/proc/expand(turf/T = null, controller = null, expand_reaction = 1)
	if(!T)
		var/list/dirs = GLOB.cardinal.Copy()
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/structure/blob) in T))
				break
			else
				T = null
	if(!T)
		return FALSE

	var/make_blob = TRUE //can we make a blob?

	if(istype(T, /turf/space) && !(locate(/obj/structure/lattice) in T) && prob(80))
		make_blob = FALSE
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) //Let's give some feedback that we DID try to spawn in space, since players are used to it

	consume_tile() //hit the tile we're in, making sure there are no border objects blocking us

	if(!T.CanPass(src, T)) //is the target turf impassable
		make_blob = FALSE
		T.blob_act(src) //hit the turf if it is

	for(var/atom/A in T)
		if(!A.CanPass(src, T)) //is anything in the turf impassable
			make_blob = FALSE
		A.blob_act(src) //also hit everything in the turf

	if(make_blob) //well, can we?
		var/obj/structure/blob/B = new /obj/structure/blob/normal(src.loc)
		if(controller)
			B.overmind = controller
		else
			B.overmind = overmind
		B.density = TRUE
		if(T.Enter(B,src)) //NOW we can attempt to move into the tile
			sleep(1) // To have the slide animation work.
			B.density = initial(B.density)
			B.forceMove(T)
			B.update_icon()
			if(B.overmind && expand_reaction)
				B.overmind.blob_type.on_expand(src, B, T, B.overmind)
			return B

		else
			blob_attack_animation(T, controller)
			T.blob_act(src) //if we can't move in hit the turf again
			qdel(B) //we should never get to this point, since we checked before moving in. destroy the blob so we don't have two blobs on one tile
			return null
	else
		blob_attack_animation(T, controller) //if we can't, animate that we attacked
	return null

/obj/structure/blob/proc/consume_tile()
	for(var/atom/A in loc)
		A.blob_act(src)
	if(loc?.density)
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/blob/proc/blob_glow_animation()
	flick("[icon_state]_glow", src)

/obj/structure/blob/proc/blob_attack_animation(atom/A = null, controller) //visually attacks an atom
	var/obj/effect/temporary_effect/blob_attack/O = new /obj/effect/temporary_effect/blob_attack(src.loc)
	O.setDir(dir)
	if(controller)
		var/mob/observer/blob/BO = controller
		O.color = BO.blob_type.color
		O.alpha = 200
	else if(overmind)
		O.color = overmind.blob_type.color
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/obj/structure/blob/proc/change_to(type, controller)
	if(!ispath(type))
		throw EXCEPTION("change_to(): invalid type for blob")
		return
	var/obj/structure/blob/B = new type(src.loc, controller)
	if(controller)
		B.overmind = controller
	B.update_icon()
	B.setDir(dir)
	qdel(src)
	return B

/obj/structure/blob/attackby(var/obj/item/W, var/mob/user)
	user.setClickCooldownLegacy(DEFAULT_ATTACK_COOLDOWN)
	playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
	visible_message("<span class='danger'>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
	var/damage = W.damage_force
	switch(W.damage_type)
		if(DAMAGE_TYPE_BURN)
			if(overmind)
				damage *= overmind.blob_type.burn_multiplier
			else
				damage *= 2

			if(damage > 0)
				playsound(src.loc, 'sound/items/welder.ogg', 100, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(DAMAGE_TYPE_BRUTE)
			if(overmind)
				damage *= overmind.blob_type.brute_multiplier
			else
				damage *= 2

			if(damage > 0)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
	if(overmind)
		damage = overmind.blob_type.on_received_damage(src, damage, W.damage_type, user)
	adjust_integrity_blob(-damage)
	return

/obj/structure/blob/on_bullet_act(obj/projectile/proj, impact_flags, list/bullet_act_args)
	. = ..()

	if(isliving(proj.firer))
		var/mob/living/L = proj.firer
		if(L.has_iff_faction(MOB_IFF_FACTION_BLOB))
			return TRUE

	var/damage = proj.get_structure_damage() // So tasers don't hurt the blob.
	if(!damage)
		return

	switch(proj.damage_type)
		if(DAMAGE_TYPE_BRUTE)
			if(overmind)
				damage *= overmind.blob_type.brute_multiplier
		if(DAMAGE_TYPE_BURN)
			if(overmind)
				damage *= overmind.blob_type.burn_multiplier

	if(overmind)
		damage = overmind.blob_type.on_received_damage(src, damage, proj.damage_type, proj.firer)

	adjust_integrity_blob(-damage)

/obj/structure/blob/water_act(amount)
	if(overmind)
		overmind.blob_type.on_water(src, amount)

/obj/structure/blob/proc/adjust_integrity_blob(amount)
	integrity = clamp( integrity + amount, 0,  integrity_max)
	if(integrity == 0)
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		if(overmind)
			overmind.blob_type.on_death(src)
		qdel(src)
	else
		update_icon()

/obj/effect/temporary_effect/blob_attack
	name = "blob"
	desc = "The blob lashing out at something."
	icon_state = "blob_attack"
	plane = MOB_PLANE
	layer = ABOVE_MOB_LAYER
	time_to_die = 6
	alpha = 140
	mouse_opacity = 0

/obj/structure/grille/blob_act()
	qdel(src)

/turf/simulated/wall/blob_act()
	inflict_atom_damage(100, damage_flag = ARMOR_MELEE, attack_type = ATTACK_TYPE_MELEE)
