
// This actually creates the shields.  It's an item so that it can be carried, but it could also be placed inside a stationary object if desired.
// It should work inside the contents of any mob.
/obj/item/shield_projector
	name = "combat shield projector"
	desc = "A miniturized and compact shield projector.  This type has been optimized to diffuse lasers or block high velocity projectiles from the outside, \
	but allow those projectiles to leave the shield from the inside.  Blocking too many damaging projectiles will cause the shield to fail."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_sec"
	light_range = 4
	light_power = 4
	var/active = FALSE					// If it's on.
	var/shield_health = 400				// How much damage the shield blocks before breaking.  This is a shared health pool for all shields attached to this projector.
	var/max_shield_health = 400			// Ditto.  This is fairly high, but shields are really big, you can't miss them, and laser carbines pump out so much hurt.
	var/shield_regen_amount = 20		// How much to recharge every process(), after the delay.
	var/shield_regen_delay = 5 SECONDS	// If the shield takes damage, it won't recharge for this long.
	var/last_damaged_time = null		// world.time when the shields took damage, used for the delay.
	var/list/active_shields = list()	// Shields that are active and deployed.
	var/always_on = FALSE				// If true, will always try to reactivate if disabled for whatever reason, ideal if AI mobs are holding this.
	var/high_color = "#0099FF"			// Color the shield will be when at max health.  A light blue.
	var/low_color = "#FF0000"			// Color the shield will drift towards as health is lowered.  Deep red.

/mob/living/simple_mob/Moved()
	for(var/obj/item/shield_projector/C in src.contents)
		C.moved_event()
	return ..()

/mob/living/simple_mob/death()
	for(var/obj/item/shield_projector/C in src.contents)
		QDEL_NULL(C)
	return ..()

/obj/item/shield_projector/Initialize(mapload)
	START_PROCESSING(SSobj, src)
	if(always_on)
		create_shields()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(moved_event))
	return ..()

/obj/item/shield_projector/Destroy()
	destroy_shields()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/item/shield_projector/pickup(mob/user, flags, atom/oldLoc)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(moved_event))

/obj/item/shield_projector/dropped(mob/user, flags, atom/newLoc)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/shield_projector/Moved(atom/oldloc)
	. = ..()
	if(!ismob(loc) && !isturf(loc))
		destroy_shields()

// WIP: recursive for non mob movement detection sometime?

/obj/item/shield_projector/proc/moved_event()
	update_shield_positions()

/obj/item/shield_projector/proc/create_shield(var/newloc, var/new_dir)
	var/obj/effect/directional_shield/S = new(newloc, src)
	S.dir = new_dir
	active_shields += S

/obj/item/shield_projector/proc/create_shields() // Override this for a specific shape.  Be sure to call ..() for the checks, however.
	if(active) // Already made.
		return FALSE
	if(shield_health <= 0)
		return FALSE
	active = TRUE
	return TRUE

/obj/item/shield_projector/proc/destroy_shields()
	for(var/obj/effect/directional_shield/S in active_shields)
		active_shields -= S
		qdel(S)
	set_light(0)
	active = FALSE

/obj/item/shield_projector/proc/update_shield_positions()
	for(var/obj/effect/directional_shield/S in active_shields)
		S.relocate()

/obj/item/shield_projector/proc/adjust_health(amount)
	shield_health = between(0, shield_health + amount, max_shield_health)
	if(amount < 0)
		if(shield_health <= 0)
			destroy_shields()
			var/turf/T = get_turf(src)
			T.visible_message("<span class='danger'>\The [src] overloads and the shield vanishes!</span>")
			playsound(src, 'sound/machines/defib_failed.ogg', 75, 0)
		else
			if(shield_health < max_shield_health / 4) // Play a more urgent sounding beep if it's at 25% health.
				playsound(src, 'sound/machines/defib_success.ogg', 75, 0)
			else
				playsound(src, 'sound/machines/defib_SafetyOn.ogg', 75, 0)
		last_damaged_time = world.time
	update_shield_colors()

// Makes shields become gradually more red as the projector's health decreases.
/obj/item/shield_projector/proc/update_shield_colors()
	// This is done at the projector instead of the shields themselves to avoid needing to calculate this more than once every update.
	var/interpolate_weight = shield_health / max_shield_health

	var/list/low_color_list = hex2rgb(low_color)
	var/low_r = low_color_list[1]
	var/low_g = low_color_list[2]
	var/low_b = low_color_list[3]

	var/list/high_color_list = hex2rgb(high_color)
	var/high_r = high_color_list[1]
	var/high_g = high_color_list[2]
	var/high_b = high_color_list[3]

	var/new_r = LERP(low_r, high_r, interpolate_weight)
	var/new_g = LERP(low_g, high_g, interpolate_weight)
	var/new_b = LERP(low_b, high_b, interpolate_weight)

	var/new_color = rgb(new_r, new_g, new_b)

	set_light(light_range, light_power, new_color)

	// Now deploy the new color to all the shields.
	for(var/obj/effect/directional_shield/S in active_shields)
		S.update_color(new_color)

/obj/item/shield_projector/attack_self(mob/user, datum/event_args/actor/actor)
	if(active)
		if(always_on)
			to_chat(user, "<span class='warning'>You can't seem to deactivate \the [src].</span>")
			return
		set_on(FALSE)
	else
		setDir(user.dir) // Needed for linear shields.
		set_on(TRUE)
	visible_message("<span class='notice'>\The [user] [!active ? "de":""]activates \the [src].</span>")

/obj/item/shield_projector/proc/set_on(var/on)
	if(isnull(on))
		return

	on ? create_shields() : destroy_shields() // Harmless if called when in the wrong state.

/obj/item/shield_projector/process()
	if(shield_health < max_shield_health && ( (last_damaged_time + shield_regen_delay) < world.time) )
		adjust_health(shield_regen_amount)
		if(always_on && !active) // Make shields as soon as possible if this is set.
			create_shields()
		if(shield_health == max_shield_health)
			playsound(src, 'sound/machines/defib_ready.ogg', 75, 0)
		else
			playsound(src, 'sound/machines/defib_safetyOff.ogg', 75, 0)

/obj/item/shield_projector/examine(var/mob/user)
	. = ..()
	if(Adjacent(user))
		. += "Its shield matrix is at [round( (shield_health / max_shield_health) * 100, 0.01)]% strength."

/obj/item/shield_projector/emp_act(var/severity)
	adjust_health(-max_shield_health / severity) // A strong EMP will kill the shield instantly, but weaker ones won't on the first hit.

// Subtypes

/obj/item/shield_projector/rectangle
	name = "rectangular combat shield projector"
	description_info = "This creates a shield in a rectangular shape, which allows projectiles to leave from inside but blocks projectiles from outside.  \
	Everything else can pass through the shield freely, including other people and thrown objects.  The shield also cannot block certain effects which \
	take place over an area, such as flashbangs or explosions."
	var/size_x = 3						// How big the rectangle will be, in tiles from the center.
	var/size_y = 3						// Ditto.

// Weaker and smaller variant.
/obj/item/shield_projector/rectangle/weak
	shield_health = 200 // Half as strong as the default.
	max_shield_health = 200
	size_x = 2
	size_y = 2

// A shortcut for admins to spawn in to put into simple animals or other things where it needs to reactivate automatically.
/obj/item/shield_projector/rectangle/automatic
	always_on = TRUE

/obj/item/shield_projector/rectangle/automatic/weak
	shield_health = 200 // Half as strong as the default.
	max_shield_health = 200
	size_x = 2
	size_y = 2

// Horrible implementation below.
/obj/item/shield_projector/rectangle/create_shields()
	if(!..())
		return FALSE

	// Make a rectangle in a really terrible way.
	var/x_dist = size_x
	var/y_dist = size_y

	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	// Top left corner.
	var/turf/T1 = locate(T.x - x_dist, T.y + y_dist, T.z)
	// Bottom right corner.
	var/turf/T2 = locate(T.x + x_dist, T.y - y_dist, T.z)
	if(!T1 || !T2) // If we're on the edge of the map then don't bother.
		return FALSE

	// Build half of the corners first, as they are 'anchors' for the rest of the code below.
	create_shield(T1, NORTHWEST)
	create_shield(T2, SOUTHEAST)

	// Build the edges.
	// First start with the north side.
	var/current_x = T1.x + 1 // Start next to the top left corner.
	var/current_y = T1.y
	var/length = (x_dist * 2) - 1
	for(var/i = 1 to length)
		create_shield(locate(current_x, current_y, T.z), NORTH)
		current_x++

	// Make the top right corner.
	create_shield(locate(current_x, current_y, T.z), NORTHEAST)

	// Now for the west edge.
	current_x = T1.x
	current_y = T1.y - 1
	length = (y_dist * 2) - 1
	for(var/i = 1 to length)
		create_shield(locate(current_x, current_y, T.z), WEST)
		current_y--

	// Make the bottom left corner.
	create_shield(locate(current_x, current_y, T.z), SOUTHWEST)

	// Switch to the second corner, and make the east edge.
	current_x = T2.x
	current_y = T2.y + 1
	length = (y_dist * 2) - 1
	for(var/i = 1 to length)
		create_shield(locate(current_x, current_y, T.z), EAST)
		current_y++

	// There are no more corners to create, so we can just go build the south edge now.
	current_x = T2.x - 1
	current_y = T2.y
	length = (x_dist * 2) - 1
	for(var/i = 1 to length)
		create_shield(locate(current_x, current_y, T.z), SOUTH)
		current_x--
	// Finally done.
	update_shield_colors()
	return TRUE

/obj/item/shield_projector/line
	name = "linear combat shield projector"
	description_info = "This creates a shield in a straight line perpendicular to the direction where the user was facing when it was activated. \
	The shield allows projectiles to leave from inside but blocks projectiles from outside.  Everything else can pass through the shield freely, \
	including other people and thrown objects.  The shield also cannot block certain effects which take place over an area, such as flashbangs or explosions."
	var/line_length = 5			// How long the line is.  Recommended to be an odd number.
	var/offset_from_center = 2	// How far from the projector will the line's center be.

/obj/item/shield_projector/line/create_shields()
	if(!..())
		return FALSE

	var/turf/T = get_turf(src) // This is another 'anchor', or will be once we move away from the projector.
	for(var/i = 1 to offset_from_center)
		T = get_step(T, dir)
	if(!T) // We went off the map or something.
		return
	// We're at the right spot now.  Build the center piece.
	create_shield(T, dir)

	var/length_to_build = round( (line_length - 1) / 2)
	var/turf/temp_T = T

	// First loop, we build the left (from a north perspective) side of the line.
	for(var/i = 1 to length_to_build)
		temp_T = get_step(temp_T, turn(dir, 90) )
		if(!temp_T)
			break
		create_shield(temp_T, i == length_to_build ? turn(dir, 45) : dir)

	temp_T = T

	// Second loop, we build the right side.
	for(var/i = 1 to length_to_build)
		temp_T = get_step(temp_T, turn(dir, -90) )
		if(!temp_T)
			break
		create_shield(temp_T, i == length_to_build ? turn(dir, -45) : dir)
	// Finished.
	update_shield_colors()
	return TRUE

/obj/item/shield_projector/line/exosuit //Variant for Exosuit design.
	name = "linear exosuit shield projector"
	offset_from_center = 1 //Snug against the exosuit.
	max_shield_health = 200

	var/obj/vehicle/sealed/mecha/my_mecha = null
	var/obj/item/vehicle_module/combat_shield/my_tool = null

/obj/item/shield_projector/line/exosuit/process()
	..()
	if((my_tool && loc != my_tool) && (my_mecha && loc != my_mecha))
		forceMove(my_tool)
	if(active)
		my_tool.set_ready_state(0)
		if(my_mecha.has_charge(my_tool.energy_drain * 50)) //Stops at around 1000 charge.
			my_mecha.use_power(my_tool.energy_drain)
		else
			destroy_shields()
			my_tool.set_ready_state(1)
			my_tool.log_message("Power lost.")
	else
		my_tool.set_ready_state(1)

/obj/item/shield_projector/line/exosuit/attack_self(mob/user, datum/event_args/actor/actor)
	if(active)
		if(always_on)
			to_chat(user, "<span class='warning'>You can't seem to deactivate \the [src].</span>")
			return

		destroy_shields()
	else
		if(istype(user.loc, /obj/vehicle/sealed/mecha))
			setDir(user.loc.dir)
		else
			setDir(user.dir)
		create_shields()
	visible_message("<span class='notice'>\The [user] [!active ? "de":""]activates \the [src].</span>")

/obj/item/shield_projector/line/exosuit/adjust_health(amount)
	..()
	my_mecha.use_power(my_tool.energy_drain)
	if(!active && shield_health < shield_regen_amount)
		my_tool.log_message("Shield overloaded.")
		my_mecha.use_power(my_tool.energy_drain * 4)
