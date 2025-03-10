///Around number*2 real seconds to surrender.
#define SECBOT_WAIT_TIME	3
///threat level at which we decide to arrest someone
#define SECBOT_THREAT_ARREST 4
///threat level at which was assume immediate danger and attack right away
#define SECBOT_THREAT_ATTACK 8
/datum/category_item/catalogue/technology/bot/secbot
	name = "Bot - Securitron"
	desc = "The Securitron is a proprietary support bot designed by Nanotrasen. \
	Utilizing the standard Security department helmet, this wheeled automaton moves \
	over floors at high speed to intercept flagged personnel. It is capable of pacifying \
	suspects with its stun baton, and may assist in the arrest process by cuffing disabled \
	targets. Frighteningly effective, these bots are both a boon and a plague thanks to \
	significant vulnerabilities in their electronic warfare systems."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon_state = "secbot0"
	maxHealth = 100
	health = 100
	req_one_access = list(ACCESS_SECURITY_EQUIPMENT, ACCESS_SECURITY_FORENSICS)
	botcard_access = list(ACCESS_SECURITY_EQUIPMENT, ACCESS_SECURITY_MAIN, ACCESS_SECURITY_FORENSICS, ACCESS_ENGINEERING_MAINT)
	patrol_speed = 2
	target_speed = 3
	catalogue_data = list(/datum/category_item/catalogue/technology/bot/secbot)

	density = 1

	var/default_icon_state = "secbot"
	var/idcheck = FALSE // If true, arrests for having weapons without authorization.
	var/check_records = FALSE // If true, arrests people without a record.
	var/check_arrest = TRUE // If true, arrests people who are set to arrest.
	var/arrest_type = FALSE // If true, doesn't handcuff. You monster.
	var/declare_arrests = FALSE // If true, announces arrests over sechuds.
	var/threat = 0 // How much of a threat something is. Set upon acquiring a target.
	var/attacked = FALSE // If true, gives the bot enough threat assessment to attack immediately.

	var/is_ranged = FALSE
	var/awaiting_surrender = 0
	var/can_next_insult = 0			// Uses world.time
	var/stun_strength = 60			// For humans.
	var/xeno_harm_strength = 15 	// How hard to hit simple_mobs.
	var/xeno_stun_strength = 3		// How hard to slimebatoned()'d naughty slimes. Normal securitrons aren't all that good at it but can do it.
	var/baton_glow = "#FF6A00"

	var/used_weapon	= /obj/item/melee/baton	//Weapon used by the bot

	var/list/threat_found_sounds = list('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg')
	var/list/preparing_arrest_sounds = list('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/bcreep.ogg')
	var/list/fighting_sounds = list('sound/voice/biamthelaw.ogg', 'sound/voice/bradio.ogg', 'sound/voice/bjustice.ogg')
// They don't like being pulled. This is going to fuck with slimesky, but meh.	//Screw you. Just screw you and your 'meh'
/mob/living/bot/secbot/Life(seconds, times_fired)
	if((. = ..()))
		return
	if(health > 0 && on && pulledby)
		if(isliving(pulledby))
			var/pull_allowed = FALSE
			for(var/A in req_one_access)
				if(A in pulledby.GetAccess())
					pull_allowed = TRUE
			if(!pull_allowed)
				var/mob/living/L = pulledby
				UnarmedAttack(L)
				say("Do not interfere with active law enforcement routines!")
				GLOB.global_announcer.autosay("[src] was interfered with in <b>[get_area(src)]</b>, activating defense routines.", "[src]", "Security")

/datum/category_item/catalogue/technology/bot/secbot/beepsky
	name = "Bot - Officer Beepsky"
	desc = "Officer Beepsky was designed to be the mascot for \
	Nanotrasen's unveiling of the Securitron line. A favorite among \
	Nanotrasen workers due to its iconic profile and tendency to break out into \
	wild bouts of profanity, the Beepsky pattern chassis is often replicated \
	on individual Nanotrasen facilities as a form of morale booster. \
	The model's increased durability ensures Officer Beepsky stands wheels and visors \
	above its inferior peers."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey."
	will_patrol = TRUE
	maxHealth = 130
	health = 130
	catalogue_data = list(/datum/category_item/catalogue/technology/bot/secbot/beepsky)

/datum/category_item/catalogue/technology/bot/secbot/slime
	name = "Bot - Slime Securitron"
	desc = "A rare Nanotrasen variant of their Securitron designs, \
	Slime Securitrons utilize the same technology and programming as \
	the standard model, but with equipment and parameters designed to \
	pacify Slimes. Prometheans often view these bots with suspicion."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/bot/secbot/slime
	name = "Slime Securitron"
	desc = "A little security robot, with a slime baton substituted for the regular one."
	default_icon_state = "slimesecbot"
	stun_strength = 10 // Slimebatons aren't meant for humans.
	catalogue_data = list(/datum/category_item/catalogue/technology/bot/secbot/slime)

	xeno_harm_strength = 9 // Weaker than regular slimesky but they can stun.
	baton_glow = "#33CCFF"
	req_one_access = list(ACCESS_SCIENCE_MAIN, ACCESS_SCIENCE_ROBOTICS)
	botcard_access = list(ACCESS_SCIENCE_MAIN, ACCESS_SCIENCE_ROBOTICS, ACCESS_SCIENCE_XENOBIO, ACCESS_SCIENCE_XENOARCH, ACCESS_SCIENCE_FABRICATION, ACCESS_SCIENCE_TOXINS, ACCESS_ENGINEERING_MAINT)
	used_weapon = /obj/item/melee/baton/slime
	xeno_stun_strength = 5 // 5 works out to 2 discipline and 5 weaken.

/datum/category_item/catalogue/technology/bot/secbot/slime/slimesky
	name = "Bot - Doctor Slimesky"
	desc = "Although less popular than its inspiration - Officer Beepsky, \
	Doctor Slimesky is still viewed with respect by Xenobiologists due to its \
	equally robust up-armored frame."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/bot/secbot/slime/slimesky
	name = "Doctor Slimesky"
	desc = "An old friend of Officer Beepsky.  He prescribes beatings to rowdy slimes so that real doctors don't need to treat the xenobiologists."
	maxHealth = 130
	health = 130
	catalogue_data = list(/datum/category_item/catalogue/technology/bot/secbot/slime/slimesky)

/mob/living/bot/secbot/update_icons()
	if(on && busy)
		icon_state = "[default_icon_state]-c"
	else
		icon_state = "[default_icon_state][on]"

	if(on)
		set_light(2, 1, baton_glow)
	else
		set_light(0)

/mob/living/bot/secbot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Secbot", name)
		ui.open()

/mob/living/bot/secbot/ui_data(mob/user, datum/tgui/ui)
	var/list/data = ..()

	data["on"] = on
	data["open"] = open
	data["locked"] = locked

	data["idcheck"] = null
	data["check_records"] = null
	data["check_arrest"] = null
	data["arrest_type"] = null
	data["declare_arrests"] = null
	data["will_patrol"] = null

	if(!locked || issilicon(user))
		data["idcheck"] = idcheck
		data["check_records"] = check_records
		data["check_arrest"] = check_arrest
		data["arrest_type"] = arrest_type
		data["declare_arrests"] = declare_arrests
		if((LEGACY_MAP_DATUM).bot_patrolling)
			data["will_patrol"] = will_patrol

	return data

/mob/living/bot/secbot/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	ui_interact(user)

/mob/living/bot/secbot/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	switch(action)
		if("power")
			if(!access_scanner.allowed(usr))
				return FALSE
			if(on)
				turn_off()
			else
				turn_on()
			. = TRUE

	if(locked && !issilicon(usr))
		return TRUE

	switch(action)
		if("idcheck")
			idcheck = !idcheck
			. = TRUE

		if("ignorerec")
			check_records = !check_records
			. = TRUE

		if("ignorearr")
			check_arrest = !check_arrest
			. = TRUE

		if("switchmode")
			arrest_type = !arrest_type
			. = TRUE

		if("patrol")
			will_patrol = !will_patrol
			. = TRUE

		if("declarearrests")
			declare_arrests = !declare_arrests
			. = TRUE

/mob/living/bot/secbot/emag_act(var/remaining_uses, var/mob/user)
	. = ..()
	if(!emagged)
		if(user)
			to_chat(user, SPAN_NOTICE("\The [src] buzzes and beeps."))
		emagged = TRUE
		patrol_speed = 3
		target_speed = 4
		return TRUE
	else
		to_chat(user, SPAN_NOTICE("\The [src] is already corrupt."))

/mob/living/bot/secbot/attackby(var/obj/item/O, var/mob/user)
	var/curhealth = health
	. = ..()
	if(health < curhealth && on == TRUE)
		react_to_attack_polaris(user)

/mob/living/bot/secbot/on_bullet_act(obj/projectile/proj, impact_flags, list/bullet_act_args)
	var/curhealth = health
	var/mob/shooter = proj.firer
	. = ..()
	//if we already have a target just ignore to avoid lots of checking
	if(!target && health < curhealth && shooter && (shooter in view(world.view, src)))
		react_to_attack_polaris(shooter)

/mob/living/bot/secbot/attack_generic(var/mob/attacker)
	if(attacker)
		react_to_attack_polaris(attacker)
	..()

/mob/living/bot/secbot/proc/react_to_attack_polaris(mob/attacker)
	if(!on)		// We don't want it to react if it's off
		return

	if(!target)
		playsound(src.loc, pick(threat_found_sounds), 50)
		GLOB.global_announcer.autosay("[src] was attacked by a hostile <b>[target_name(attacker)]</b> in <b>[get_area(src)]</b>.", "[src]", "Security")
	target = attacker
	attacked = TRUE

// Say "freeze!" and demand surrender
/mob/living/bot/secbot/proc/demand_surrender(mob/target, var/threat)
	var/suspect_name = target_name(target)
	if(declare_arrests)
		GLOB.global_announcer.autosay("[src] is [arrest_type ? "detaining" : "arresting"] a level [threat] suspect <b>[suspect_name]</b> in <b>[get_area(src)]</b>.", "[src]", "Security")
	say("Down on the floor, [suspect_name]! You have [SECBOT_WAIT_TIME*2] seconds to comply.")
	playsound(src.loc, pick(preparing_arrest_sounds), 50)
	// Register to be told when the target moves
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(target_moved))

// Callback invoked if the registered target moves
/mob/living/bot/secbot/proc/target_moved(atom/movable/moving_instance, atom/old_loc, atom/new_loc)
	if(get_dist(get_turf(src), get_turf(target)) >= 1)
		awaiting_surrender = INFINITY	// Done waiting!
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/mob/living/bot/secbot/resetTarget()
	..()
	if(target)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	awaiting_surrender = 0
	attacked = FALSE
	walk_to(src, 0)

/mob/living/bot/secbot/startPatrol()
	if(!locked) // Stop running away when we set you up
		return
	..()

/mob/living/bot/secbot/confirmTarget(var/atom/A)
	if(!..())
		return FALSE
	check_threat(A)
	if(threat >= SECBOT_THREAT_ARREST)
		return TRUE

/mob/living/bot/secbot/lookForTargets()
	for(var/mob/living/M in view(src))
		if(M.stat == DEAD)
			continue
		if(confirmTarget(M))
			target = M
			awaiting_surrender = 0
			say("Level [threat] infraction alert!")
			custom_emote(1, "points at [M.name]!")
			playsound(src.loc, pick(threat_found_sounds), 50)
			return

/mob/living/bot/secbot/handleAdjacentTarget()
	var/mob/living/carbon/human/H = target
	check_threat(target)
	if(awaiting_surrender < SECBOT_WAIT_TIME && istype(H) && !H.lying && threat < SECBOT_THREAT_ATTACK)
		if(awaiting_surrender == 0) // On first tick of awaiting...
			demand_surrender(target, threat)
		++awaiting_surrender
	else
		if(declare_arrests)
			var/action = arrest_type ? "detaining" : "arresting"
			if(!ishuman(target))
				action = "fighting"
			GLOB.global_announcer.autosay("[src] is [action] a level [threat] [action != "fighting" ? "suspect" : "threat"] <b>[target_name(target)]</b> in <b>[get_area(src)]</b>.", "[src]", "Security")
		UnarmedAttack(target)

/mob/living/bot/secbot/handlePanic()	// Speed modification based on alert level.
	. = 0
	switch(get_security_level())
		if("green")
			. = 0

		if("yellow")
			. = 0

		if("violet")
			. = 0

		if("orange")
			. = 0

		if("blue")
			. = 1

		if("red")
			. = 2

		if("delta")
			. = 2

	return .

// So Beepsky talks while beating up simple mobs.
/mob/living/bot/secbot/proc/insult(var/mob/living/L)
	if(can_next_insult > world.time)
		return
	if(threat >= 10)
		playsound(src.loc, 'sound/voice/binsult.ogg', 75)
		can_next_insult = world.time + 20 SECONDS
	else
		playsound(src.loc, pick(fighting_sounds), 75)
		can_next_insult = world.time + 5 SECONDS


/mob/living/bot/secbot/UnarmedAttack(var/mob/M, var/proximity)
	if(!..())
		return

	if(!istype(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/cuff = TRUE

		if(CHECK_MOBILITY(H, MOBILITY_CAN_MOVE | MOBILITY_CAN_USE) || H.handcuffed || arrest_type)
			cuff = FALSE
		if(!cuff)
			H.electrocute(0, 0, stun_strength, NONE, BP_TORSO, src)
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			do_attack_animation(H)
			busy = TRUE
			update_icons()
			spawn(2)
				busy = FALSE
				update_icons()
			visible_message("<span class='warning'>\The [H] was prodded by \the [src] with a stun baton!</span>")
			insult(H)
		else
			playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			visible_message("<span class='warning'>\The [src] is trying to put handcuffs on \the [H]!</span>")
			busy = TRUE
			if(do_mob(src, H, 60))
				if(!H.handcuffed)
					var/type
					if(istype(H.back, /obj/item/hardsuit) && istype(H.gloves,/obj/item/clothing/gloves/gauntlets/hardsuit))
						type = /obj/item/handcuffs/cable // Better to be cable cuffed than stun-locked
					else
						type = /obj/item/handcuffs
					var/obj/item/handcuffs/hc = new type(H)
					// force equip because no mercy
					H.force_equip_to_slot_or_del(hc, SLOT_ID_HANDCUFFED, user = src)
			busy = FALSE
	else if(istype(M, /mob/living))
		var/mob/living/L = M
		if(istype(L, /mob/living/simple_mob/slime/xenobio))
			var/mob/living/simple_mob/slime/xenobio/S = L
			var/datum/ai_holder/polaris/simple_mob/xenobio_slime/sai = S.ai_holder
			if(!S.is_justified_to_discipline() && !sai?.rabid) //will kill angry slimes.
				attacked = FALSE //quit abusing the damn slimes. I don't care if they're hurting you.
				return
			S.slimebatoned(src, xeno_stun_strength)
		L.adjustBruteLoss(xeno_harm_strength)
		do_attack_animation(M)
		playsound(loc, "swing_hit", 50, 1, -1)
		busy = TRUE
		update_icons()
		spawn(2)
			busy = FALSE
			update_icons()
		visible_message("<span class='warning'>\The [M] was beaten by \the [src] with a stun baton!</span>")
		insult(L)

/mob/living/bot/secbot/explode()
	visible_message("<span class='warning'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.add_overlay(image('icons/obj/aibots.dmi', "hs_hole"))
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)
	new used_weapon(Tsec)
	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/debris/cleanable/blood/oil(Tsec)
	qdel(src)

/mob/living/bot/secbot/proc/target_name(mob/living/T)
	if(ishuman(T))
		var/mob/living/carbon/human/H = T
		return H.get_id_name("unidentified person")
	return "unidentified lifeform"

/mob/living/bot/secbot/proc/check_threat(var/mob/living/M)
	if(!M || !istype(M) || M.stat == DEAD || src == M || (isslime(M) && M.incapacitated()))
		threat = 0

	else if(emagged && !M.incapacitated()) //check incapacitated so emagged secbots don't keep attacking the same target forever
		threat = 10

	else
		threat = M.assess_perp(access_scanner, 0, idcheck, check_records, check_arrest) // Set base threat level
		if(attacked)
			threat += SECBOT_THREAT_ATTACK // Increase enough so we can attack immediately in return

//Secbot Construction

/obj/item/clothing/head/helmet/attackby(var/obj/item/assembly/signaler/S, mob/user as mob)
	..()
	if(!issignaler(S))
		..()
		return

	if(type != /obj/item/clothing/head/helmet) //Eh, but we don't want people making secbots out of space helmets.
		return

	if(S.secured)
		qdel(S)
		var/obj/item/secbot_assembly/A = new /obj/item/secbot_assembly
		user.put_in_hands_or_drop(A)
		to_chat(user, "You add the signaler to the helmet.")
		qdel(src)
	else
		return

/obj/item/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_icons = list(
			SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_hats.dmi',
			SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_hats.dmi',
			)
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron"

/obj/item/secbot_assembly/attackby(var/obj/item/W, var/mob/user)
	..()
	if(istype(W, /obj/item/weldingtool) && !build_step)
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			build_step = 1
			add_overlay(image('icons/obj/aibots.dmi', "hs_hole"))
			to_chat(user, "You weld a hole in \the [src].")

	else if(isprox(W) && (build_step == 1))
		if(!user.attempt_insert_item_for_installation(W, src))
			return
		build_step = 2
		to_chat(user, "You add \the [W] to [src].")
		add_overlay(image('icons/obj/aibots.dmi', "hs_eye"))
		name = "helmet/signaler/prox sensor assembly"

	else if((istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm) || (istype(W, /obj/item/organ/external/arm) && ((W.name == "robotic right arm") || (W.name == "robotic left arm")))) && build_step == 2)
		if(!user.attempt_insert_item_for_installation(W, src))
			return
		build_step = 3
		to_chat(user, "You add \the [W] to [src].")
		name = "helmet/signaler/prox sensor/robot arm assembly"
		add_overlay(image('icons/obj/aibots.dmi', "hs_arm"))

	else if(istype(W, /obj/item/melee/baton) && build_step == 3)
		if(!user.attempt_insert_item_for_installation(W, src))
			return
		to_chat(user, "You complete the Securitron! Beep boop.")
		if(istype(W, /obj/item/melee/baton/slime))
			var/mob/living/bot/secbot/slime/S = new /mob/living/bot/secbot/slime(get_turf(src))
			S.name = created_name
		else
			var/mob/living/bot/secbot/S = new /mob/living/bot/secbot(get_turf(src))
			S.name = created_name
		qdel(src)

	else if(istype(W, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
