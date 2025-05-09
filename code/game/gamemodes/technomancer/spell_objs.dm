
/obj/item/spell
	name = "glowing particles"
	desc = "Your hands appear to be glowing brightly."
	icon = 'icons/obj/spells.dmi'
	icon_state = "generic"
	item_icons = list(
		SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_magic.dmi',
		SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_magic.dmi',
		)
	throw_force = 0
	damage_force = 0
	show_examine = FALSE
//	var/mob/living/carbon/human/owner = null
	var/mob/living/owner = null
	var/del_for_null_core = TRUE
	var/obj/item/technomancer_core/core = null
	var/cast_methods = null			// Controls how the spell is casted.
	var/aspect = null				// Used for combining spells.
	var/toggled = 0					// Mainly used for overlays.
	var/cooldown = 0 				// If set, will add a cooldown overlay and adjust click delay.  Must be a multiple of 5 for overlays.
	var/cast_sound = null			// Sound file played when this is used.

// Proc: on_use_cast()
// Parameters: 1 (user - the technomancer casting the spell)
// Description: Override this for clicking the spell in your hands.
/obj/item/spell/proc/on_use_cast(mob/user)
	return

// Proc: on_throw_cast()
// Parameters: 1 (hit_atom - the atom hit by the spell object)
// Description: Override this for throwing effects.
/obj/item/spell/proc/on_throw_cast(atom/hit_atom)
	return

// Proc: on_ranged_cast()
// Parameters: 2 (hit_atom - the atom clicked on by the user, user - the technomancer that clicked hit_atom)
// Description: Override this for ranged effects.
/obj/item/spell/proc/on_ranged_cast(atom/hit_atom, mob/user)
	return

// Proc: on_melee_cast()
// Parameters: 3 (hit_atom - the atom clicked on by the user, user - the technomancer that clicked hit_atom, def_zone - unknown)
// Description: Override this for effects that occur at melee range.
/obj/item/spell/proc/on_melee_cast(atom/hit_atom, mob/living/user, def_zone)
	return

// Proc: on_combine_cast()
// Parameters: 2 (I - the item trying to merge with the spell, user - the technomancer who initiated the merge)
// Description: Override this for combining spells, like Aspect spells.
/obj/item/spell/proc/on_combine_cast(obj/item/I, mob/user)
	return

// Proc: on_innate_cast()
// Parameters: 1 (user - the entity who is casting innately (without using hands).)
// Description: Override this for casting without using hands (and as a result not using spell objects).
/obj/item/spell/proc/on_innate_cast(mob/user)
	return

// Proc: on_scepter_use_cast()
// Parameters: 1 (user - the holder of the Scepter that clicked.)
// Description: Override this for spell casts which have additional functionality when a Scepter is held in the offhand, and the
// scepter is being clicked by the technomancer in their hand.
/obj/item/spell/proc/on_scepter_use_cast(mob/user)
	return

// Proc: on_scepter_use_cast()
// Parameters: 2 (hit_atom - the atom clicked by user, user - the holder of the Scepter that clicked.)
// Description: Similar to the above proc, however this is for when someone with a Scepter clicks something far away with the scepter
// while holding a spell in the offhand that reacts to that.
/obj/item/spell/proc/on_scepter_ranged_cast(atom/hit_atom, mob/user)
	return

// Proc: pay_energy()
// Parameters: 1 (amount - how much to test and drain if there is enough)
// Description: Use this to make spells cost energy.  It returns false if the technomancer cannot pay for the spell for any reason, and
// if they are able to pay, it is deducted automatically.
/obj/item/spell/proc/pay_energy(var/amount)
	if(!core)
		return 0
	return core.pay_energy(amount)

// Proc: give_energy()
// Parameters: 1 (amount - how much to give to the technomancer)
// Description: Redirects the call to the core's give_energy().
/obj/item/spell/proc/give_energy(var/amount)
	if(!core)
		return 0
	return core.give_energy(amount)

// Proc: adjust_instability()
// Parameters: 1 (amount - how much instability to give)
// Description: Use this to quickly add or subtract instability from the caster of the spell.  Owner is set by New().
/obj/item/spell/proc/adjust_instability(var/amount)
	if(!owner || !core)
		return 0
	amount = round(amount * core.instability_modifier, 0.1)
	owner.adjust_instability(amount)

// Proc: get_technomancer_core()
// Parameters: 0
// Description: Returns the technomancer's core, assuming it is being worn properly.
/mob/living/proc/get_technomancer_core()
	return null

/mob/living/carbon/human/get_technomancer_core()
	var/obj/item/technomancer_core/core = back
	if(istype(core))
		return core
	return null

// Proc: New()
// Parameters: 0
// Description: Sets owner to equal its loc, links to the owner's core, then applies overlays if needed.
/obj/item/spell/Initialize(mapload)
	. = ..()
	if(isliving(loc))
		owner = loc
	if(owner)
		core = owner.get_technomancer_core()
		if(!core && del_for_null_core)
			to_chat(owner, "<span class='warning'>You need a Core to do that.</span>")
			qdel(src)
			return
//		if(istype(/obj/item/technomancer_core, owner.back))
//			core = owner.back
	update_icon()

// Proc: Destroy()
// Parameters: 0
// Description: Nulls object references so it can qdel() cleanly.
/obj/item/spell/Destroy()
	owner.unref_spell(src)
	owner = null
	core = null
	return ..()

// Proc: unref_spells()
// Parameters: 0
// Description: Nulls object references on specific mobs so it can qdel() cleanly.
/mob/proc/unref_spell(var/obj/item/spell/the_spell)
	return

// Proc: update_icon()
// Parameters: 0
// Description: Applys an overlay if it is a passive spell.
/obj/item/spell/update_icon()
	if(toggled)
		var/image/new_overlay = image('icons/obj/spells.dmi',"toggled")
		add_overlay(new_overlay)
	else
		cut_overlays()
	..()

// Proc: run_checks()
// Parameters: 0
// Description: Ensures spells should not function if something is wrong.  If a core is missing, it will try to find one, then fail
// if it still can't find one.  It will also check if the core is being worn properly, and finally checks if the owner is a technomancer.
/obj/item/spell/proc/run_checks()
	if(!owner)
		return 0
	if(!core)
		core = locate(/obj/item/technomancer_core) in owner
		if(!core)
			to_chat(owner, "<span class='danger'>You need to be wearing a core on your back!</span>")
			return 0
	if(core.loc != owner || owner.back != core) //Make sure the core's being worn.
		to_chat(owner, "<span class='danger'>You need to be wearing a core on your back!</span>")
		return 0
	if(!technomancers.is_antagonist(owner.mind)) //Now make sure the person using this is the actual antag.
		to_chat(owner, "<span class='danger'>You can't seem to figure out how to make the machine work properly.</span>")
		return 0
	return 1

// Proc: check_for_scepter()
// Parameters: 0
// Description: Terrible code to check if a scepter is in the offhand, returns 1 if yes.
/obj/item/spell/proc/check_for_scepter()
	if(isnull(owner))
		return FALSE
	var/our_index = owner.get_held_index(src)
	if(!our_index)
		return FALSE
	for(var/i in 1 to length(owner.inventory.held_items))
		if(i == our_index)
			continue
		if(!istype(owner.inventory.held_items[i], /obj/item/scepter))
			continue
		return TRUE
	return FALSE

// Proc: get_other_hand()
// Parameters: 1 (I - item being compared to determine what the offhand is)
// Description: Helper for Aspect spells.
/mob/living/carbon/human/proc/get_other_hand(var/obj/item/I)
	var/our_index = get_held_index(src)
	if(!our_index)
		return FALSE
	for(var/i in 1 to length(inventory.held_items))
		if(i == our_index)
			continue
		if(isnull(inventory.held_items[i]))
			continue
		return inventory.held_items[i]

// Proc: attack_self()
// Parameters: 1 (user - the Technomancer that invoked this proc)
// Description: Tries to call on_use_cast() if it is allowed to do so.  Don't override this, override on_use_cast() instead.
/obj/item/spell/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(run_checks() && (cast_methods & CAST_USE))
		on_use_cast(user)

// Proc: attackby()
// Parameters: 2 (W - the item this spell object is hitting, user - the technomancer who clicked the other object)
// Description: Tries to combine the spells, if W is a spell, and has CHROMATIC aspect.
/obj/item/spell/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/spell))
		var/obj/item/spell/spell = W
		if(run_checks() & (cast_methods & CAST_COMBINE))
			spell.on_combine_cast(src, user)
	else
		..()

// Proc: afterattack()
// Parameters: 4 (target - the atom clicked on by user, user - the technomancer who clicked with the spell, (clickchain_flags & CLICKCHAIN_HAS_PROXIMITY) - argument
// telling the proc if target is adjacent to user, click_parameters - information on where exactly the click occured on the screen.)
// Description: Tests to make sure it can cast, then casts a combined, ranged, or melee spell based on what it can do and the
// range the click occured.  Melee casts have higher priority than ranged if both are possible.  Sets cooldown at the end.
// Don't override this for spells, override the on_*_cast() spells shown above.
/obj/item/spell/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(!run_checks())
		return
	if(!(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY))
		if(cast_methods & CAST_RANGED)
			on_ranged_cast(target, user)
	else
		if(istype(target, /obj/item/spell))
			var/obj/item/spell/spell = target
			if(spell.cast_methods & CAST_COMBINE)
				spell.on_combine_cast(src, user)
				return
		if(cast_methods & CAST_MELEE)
			on_melee_cast(target, user)
		else if(cast_methods & CAST_RANGED) //Try to use a ranged method if a melee one doesn't exist.
			on_ranged_cast(target, user)
	if(cooldown)
		var/effective_cooldown = round(cooldown * core.cooldown_modifier, 5)
		user.setClickCooldownLegacy(effective_cooldown)
		flick("cooldown_[effective_cooldown]",src)

// Proc: place_spell_in_hand()
// Parameters: 1 (path - the type path for the spell that is desired.)
// Description: Returns immediately, this is here to override for other mobs as needed.
/mob/living/proc/place_spell_in_hand(var/path)
	return

// Proc: place_spell_in_hand()
// Parameters: 1 (path - the type path for the spell that is desired.)
// Description: Gives the spell to the human mob, if it is allowed to have spells, hands are not full, etc.  Otherwise it deletes itself.
/mob/living/carbon/human/place_spell_in_hand(var/path)
	if(!path || !ispath(path))
		return 0

	//var/obj/item/spell/S = new path(src)
	var/obj/item/spell/S = new path(src)

	//No hands needed for innate casts.
	if(S.cast_methods & CAST_INNATE)
		if(S.run_checks())
			S.on_innate_cast(src)

	// todo: shitcode, doesn't properly support multihanding
	var/obj/item/l_hand = get_left_held_item()
	var/obj/item/r_hand = get_right_held_item()
	if(l_hand && r_hand) //Make sure our hands aren't full.
		if(istype(r_hand, /obj/item/spell)) //If they are full, perhaps we can still be useful.
			var/obj/item/spell/r_spell = r_hand
			if(r_spell.aspect == ASPECT_CHROMATIC) //Check if we can combine the new spell with one in our hands.
				r_spell.on_combine_cast(S, src)
		else if(istype(l_hand, /obj/item/spell))
			var/obj/item/spell/l_spell = l_hand
			if(l_spell.aspect == ASPECT_CHROMATIC) //Check the other hand too.
				l_spell.on_combine_cast(S, src)
		else //Welp
			to_chat(src, "<span class='warning'>You require a free hand to use this function.</span>")
			return 0

	if(S.run_checks())
		put_in_hands(S)
		return 1
	else
		qdel(S)
		return 0

// Proc: dropped()
// Parameters: 0
// Description: Deletes the spell object immediately.
/obj/item/spell/dropped(mob/user, flags, atom/newLoc)
	. = ..()
	qdel(src)

// Proc: throw_impact()
// Parameters: 1 (hit_atom - the atom that got hit by the spell as it was thrown)
// Description: Calls on_throw_cast() on whatever was hit, then deletes itself incase it missed.
/obj/item/spell/throw_impact(atom/hit_atom)
	..()
	if(cast_methods & CAST_THROW)
		on_throw_cast(hit_atom)

	// If we miss or hit an obstacle, we still want to delete the spell.
	spawn(20)
		if(src)
			qdel(src)
