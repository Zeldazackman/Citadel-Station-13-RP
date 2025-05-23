/datum/technomancer/equipment/gloves_of_regen
	name = "Gloves of Regeneration"
	desc = "It's a pair of black gloves, with a hypodermic needle on the insides, and a small storage of a secret blend of chemicals \
	designed to be slowly fed into a living person's system, increasing their metabolism greatly, resulting in accelerated healing.  \
	A side effect of this healing is that the wearer will generally get hungry a lot faster.  Sliding the gloves on and off also \
	hurts a lot.  As a bonus, the gloves are more resistant to the elements than most.  It should be noted that synthetics will have \
	little use for these."
	cost = 50
	obj_path = /obj/item/clothing/gloves/regen

/obj/item/clothing/gloves/regen
	name = "gloves of regeneration"
	desc = "A pair of gloves with a small storage of green liquid on the outside.  On the inside, a a hypodermic needle can be seen \
	on each glove."
	icon_state = "regen"
	item_state = "graygloves"
	siemens_coefficient = 0
	cold_protection_cover = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection_cover = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/regen/equipped(mob/user, slot, flags)
	. = ..()
	if(slot == SLOT_ID_GLOVES)
		var/mob/living/L = user
		if(!istype(L))
			return
		if(L.can_feel_pain())
			to_chat(L, "<span class='danger'>You feel a stabbing sensation in your hands as you slide \the [src] on!</span>")
			L.custom_pain("You feel a sharp pain in your hands!",1)

/obj/item/clothing/gloves/regen/unequipped(mob/user, slot, flags)
	. = ..()
	if(slot == SLOT_ID_GLOVES)
		var/mob/living/L = user
		if(!istype(L))
			return
		if(L.can_feel_pain())
			to_chat(user, "<span class='danger'>You feel the hypodermic needles as you slide \the [src] off!</span>")
			L.custom_pain("Your hands hurt like hell!",1)

/obj/item/clothing/gloves/regen/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/gloves/regen/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/gloves/regen/process(delta_time)
	var/mob/living/wearer = get_worn_mob()

	if(!wearer || wearer.isSynthetic() || wearer.stat == DEAD || wearer.nutrition <= 10)
		return // Robots and dead people don't have a metabolism.

	if(wearer.getBruteLoss())
		wearer.adjustBruteLoss(-0.1)
		wearer.nutrition = max(wearer.nutrition - 10, 0)
	if(wearer.getFireLoss())
		wearer.adjustFireLoss(-0.1)
		wearer.nutrition = max(wearer.nutrition - 10, 0)
	if(wearer.getToxLoss())
		wearer.adjustToxLoss(-0.1)
		wearer.nutrition = max(wearer.nutrition - 10, 0)
	if(wearer.getOxyLoss())
		wearer.adjustOxyLoss(-0.1)
		wearer.nutrition = max(wearer.nutrition - 10, 0)
	if(wearer.getCloneLoss())
		wearer.adjustCloneLoss(-0.1)
		wearer.nutrition = max(wearer.nutrition - 20, 0)
