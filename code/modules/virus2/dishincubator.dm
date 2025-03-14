/obj/machinery/disease2/incubator/
	name = "pathogenic incubator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	var/obj/item/virusdish/dish
	var/obj/item/reagent_containers/glass/beaker = null
	var/radiation = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxins = 0

/obj/machinery/disease2/incubator/attackby(var/obj/O as obj, var/mob/user as mob)
	if(default_unfasten_wrench(user, O, 20))
		return

	if(istype(O, /obj/item/reagent_containers/glass) || istype(O,/obj/item/reagent_containers/syringe))
		if(beaker)
			to_chat(user, "\The [src] is already loaded.")
			return
		if(!user.attempt_insert_item_for_installation(O, src))
			return

		beaker = O

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SSnanoui.update_uis(src)

		src.attack_hand(user)
		return
	if(istype(O, /obj/item/virusdish))
		if(dish)
			to_chat(user, "The dish tray is aleady full!")
			return
		if(!user.attempt_insert_item_for_installation(O, src))
			return
		dish = O

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SSnanoui.update_uis(src)

		src.attack_hand(user)

/obj/machinery/disease2/incubator/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	nano_ui_interact(user)

/obj/machinery/disease2/incubator/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["chemicals_inserted"] = !!beaker
	data["dish_inserted"] = !!dish
	data["food_supply"] = foodsupply
	data["radiation"] = radiation
	data["toxins"] = min(toxins, 100)
	data["on"] = on
	data["system_in_use"] = foodsupply > 0 || radiation > 0 || toxins > 0
	data["chemical_volume"] = beaker ? beaker.reagents.total_volume : 0
	data["max_chemical_volume"] = beaker ? beaker.volume : 1
	data["virus"] = dish ? dish.virus2 : null
	data["growth"] = dish ? min(dish.growth, 100) : 0
	data["infection_rate"] = dish && dish.virus2 ? dish.virus2.infectionchance * 10 : 0
	data["analysed"] = dish && dish.analysed ? 1 : 0
	data["can_breed_virus"] = null
	data["blood_already_infected"] = null

	if (beaker)
		var/datum/blood_mixture/sample_blood_mixture = legacy_virus2_access_blood_mixture(beaker.reagents)
		data["can_breed_virus"] = dish && dish.virus2 && sample_blood_mixture

		for (var/ID in sample_blood_mixture?.legacy_virus2)
			data["blood_already_infected"] = sample_blood_mixture.legacy_virus2[ID]

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "dish_incubator.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/disease2/incubator/process(delta_time)
	if(dish && on && dish.virus2)
		use_power(50,EQUIP)
		if(!powered(EQUIP))
			on = 0
			icon_state = "incubator"

		if(foodsupply)
			if(dish.growth + 3 >= 100 && dish.growth < 100)
				ping("\The [src] pings, \"Sufficient viral growth density achieved.\"")

			foodsupply -= 1
			dish.growth += 3
			SSnanoui.update_uis(src)

		if(radiation)
			if(radiation > 50 & prob(5))
				dish.virus2.majormutate()
				if(dish.info)
					dish.info = "OUTDATED : [dish.info]"
					dish.basic_info = "OUTDATED: [dish.basic_info]"
					dish.analysed = 0
				ping("\The [src] pings, \"Mutant viral strain detected.\"")
			else if(prob(5))
				dish.virus2.minormutate()
			radiation -= 1
			SSnanoui.update_uis(src)
		if(toxins && prob(5))
			dish.virus2.infectionchance -= 1
			SSnanoui.update_uis(src)
		if(toxins > 50)
			dish.growth = 0
			dish.virus2 = null
			SSnanoui.update_uis(src)
	else if(!dish)
		on = 0
		icon_state = "incubator"
		SSnanoui.update_uis(src)

	if(beaker)
		if(foodsupply < 100 && beaker.reagents.remove_reagent("virusfood",5))
			if(foodsupply + 10 <= 100)
				foodsupply += 10
			SSnanoui.update_uis(src)

		if(toxins < 100)
			for(var/datum/reagent/toxin/tox in beaker.reagents.get_reagent_datums())
				toxins += max(tox.strength,1)
				beaker.reagents.remove_reagent(tox.id,1)
				if(toxins > 100)
					toxins = 100
					break
			SSnanoui.update_uis(src)

/obj/machinery/disease2/incubator/Topic(href, href_list)
	if (..())
		return TRUE

	var/mob/user = usr
	var/datum/nanoui/ui = SSnanoui.get_open_ui(user, src, "main")

	if (href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if (href_list["ejectchem"])
		if(beaker)
			beaker.loc = src.loc
			beaker = null
		return 1

	if (href_list["power"])
		if (dish)
			on = !on
			icon_state = on ? "incubator_on" : "incubator"
		return 1

	if (href_list["ejectdish"])
		if(dish)
			dish.loc = src.loc
			dish = null
		return 1

	if (href_list["rad"])
		radiation = min(100, radiation + 10)
		return 1

	if (href_list["flush"])
		radiation = 0
		toxins = 0
		foodsupply = 0
		return 1

	if(href_list["virus"])
		if (!dish)
			return 1

		var/datum/blood_mixture/mixture = beaker.reagents.reagent_datas?[/datum/reagent/blood::id]
		if(!mixture)
			return TRUE
		LAZYINITLIST(mixture.legacy_virus2)
		mixture.legacy_virus2["[dish.virus2.uniqueID]"] = dish.virus2.getcopy()

		ping("\The [src] pings, \"Injection complete.\"")
		return 1

	return 0
