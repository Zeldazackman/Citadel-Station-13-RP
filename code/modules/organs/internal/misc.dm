//CORTICAL BORER ORGANS.
/obj/item/organ/internal/borer
	name = "cortical borer"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borer"
	organ_tag = "brain"
	desc = "A disgusting space slug."
	parent_organ = BP_HEAD
	vital = 1

/obj/item/organ/internal/borer/tick_life(dt)
	. = ..()
	// Borer husks regenerate health, feel no pain, and are resistant to stuns and brainloss.
	for(var/chem in list("tricordrazine","tramadol","hyperzine","alkysine"))
		if(owner.reagents.get_reagent_amount(chem) < 3)
			owner.reagents.add_reagent(chem, 5)

	// They're also super gross and ooze ichor.
	// if(prob(5))
	// 	var/mob/living/carbon/human/H = owner
	// 	if(!istype(H))
	// 		return

	// 	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in H.vessel.reagent_list
	// 	blood_splatter(H,B,1)
	// 	var/obj/effect/debris/cleanable/blood/splatter/goo = locate() in get_turf(owner)
	// 	if(goo)
	// 		goo.name = "husk ichor"
	// 		goo.desc = "It's thick and stinks of decay."
	// 		goo.basecolor = "#412464"
	// 		goo.update_icon()

/obj/item/organ/internal/borer/removed(var/mob/living/user)

	..()

	var/mob/living/simple_mob/animal/borer/B = owner.has_brain_worms()
	if(B)
		B.leave_host()
		owner.transfer_client_to(B)

	spawn(0)
		qdel(src)

//VOX ORGANS.
/obj/item/organ/internal/stack
	name = "cortical stack"
	parent_organ = BP_HEAD
	icon_state = "brain-prosthetic"
	organ_tag = "stack"
	vital = 1
	var/backup_time = 0
	var/datum/mind/backup

/obj/item/organ/internal/stack/tick_life(dt)
	. = ..()
	if(owner && owner.stat != DEAD && !is_broken())
		backup_time = world.time
		if(owner.mind) backup = owner.mind

/obj/item/organ/internal/stack/vox/stack
	name = "vox cortical stack"
	icon_state = "cortical_stack"
