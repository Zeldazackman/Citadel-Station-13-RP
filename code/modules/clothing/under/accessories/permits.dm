//This'll be used for gun permits, such as for heads of staff, antags, and bartenders

/obj/item/clothing/accessory/permit
	name = "permit"
	desc = "A permit for something."
	icon = 'icons/obj/card_cit.dmi'
	icon_state = "permit-generic"
	w_class = WEIGHT_CLASS_TINY
	slot = ACCESSORY_SLOT_MEDAL
	var/owner = 0	//To prevent people from just renaming the thing if they steal it

/obj/item/clothing/accessory/permit/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(isliving(user))
		if(!owner)
			set_name(user.name)
			to_chat(user, "[src] registers your name.")
		else
			to_chat(user, "[src] already has an owner!")

/obj/item/clothing/accessory/permit/proc/set_name(var/new_name)
	owner = 1
	if(new_name)
		src.name += " ([new_name])"
		desc += " It belongs to [new_name]."

/obj/item/clothing/accessory/permit/emag_act(var/remaining_charges, var/mob/user)
	to_chat(user, "You reset the naming locks on [src]!")
	owner = 0

/obj/item/clothing/accessory/permit/gun
	name = "weapon permit"
	desc = "A card indicating that the owner is allowed to carry a weapon."
	icon_state = "permit-security"

/obj/item/clothing/accessory/permit/gun/nka
	name = "New Kingdom Hunter's Permit"
	desc = "A card issued by the New Kingdom of Adhomai indicating that the owner is allowed to carry a \
	firearm for the purpose of hunting. This license could be revoked if the hunter is caught doing illegal activities."
	icon_state = "permit-nka"

/obj/item/clothing/accessory/permit/gun/bar
	name = "bar shotgun permit"
	desc = "A card indicating that the owner is allowed to carry a shotgun in the bar."

/obj/item/clothing/accessory/permit/gun/planetside
	name = "planetside weapon permit"
	desc = "A card indicating that the owner is allowed to carry a weapon while on the surface."
	icon_state = "permit-science"

/obj/item/clothing/accessory/permit/drone
	name = "drone identification card"
	desc = "A card issued by the EIO, indicating that the owner is a Drone Intelligence. Drones are mandated to carry this card within Nanotrasen space, by law."
	icon_state = "permit-drone"

/obj/item/clothing/accessory/permit/gun/paramedic
	name = "paramedic weapon permit"
	desc = "A card indicating that the owner is allowed to carry a weapon while on EVA retrieval missions."
	icon_state = "permit-medical"

/obj/item/clothing/accessory/permit/chaplain
	name = "holy weapon permit"
	desc = "A card indicating that the owner is allowed to carry a weapon for religious rites and purposes."
	icon_state = "permit-holy"

/obj/item/clothing/accessory/permit/gun/planetside
	name = "explorer weapon permit"
	desc = "A card indicating that the owner is allowed to carry weaponry during active exploration missions."

