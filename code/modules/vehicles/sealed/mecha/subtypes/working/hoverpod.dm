/obj/vehicle/sealed/mecha/working/hoverpod
	desc = "Stubby and round, this space-capable craft is an ancient favorite."
	name = "Hover Pod"
	catalogue_data = list(/datum/category_item/catalogue/technology/hoverpod)
	icon_state = "engineering_pod"
	initial_icon = "engineering_pod"
	internal_damage_threshold = 80
	step_in = 4
	step_energy_drain = 10
	max_temperature = 20000
	integrity = 150
	integrity_max = 150
	infra_luminosity = 6
	wreckage = /obj/effect/decal/mecha_wreckage/hoverpod
	cargo_capacity = 5
	max_equip = 3
	var/datum/effect_system/ion_trail_follow/ion_trail
	var/stabilization_enabled = 1

	stomp_sound = 'sound/machines/hiss.ogg'
	swivel_sound = null

	max_hull_equip = 2
	max_weapon_equip = 0
	max_utility_equip = 2
	max_universal_equip = 1
	max_special_equip = 1

/obj/vehicle/sealed/mecha/working/hoverpod/Initialize(mapload)
	. = ..()
	ion_trail = new /datum/effect_system/ion_trail_follow()
	ion_trail.set_up(src)

/obj/vehicle/sealed/mecha/working/hoverpod/occupant_added(mob/adding, datum/event_args/actor/actor, control_flags, silent)
	. = ..()
	ion_trail.start()

/obj/vehicle/sealed/mecha/working/hoverpod/occupant_removed(mob/removing, datum/event_args/actor/actor, control_flags, silent)
	. = ..()
	if(!length(occupants))
		ion_trail.stop()

//Modified phazon code
/obj/vehicle/sealed/mecha/working/hoverpod/Topic(href, href_list)
	..()
	if (href_list["toggle_stabilization"])
		stabilization_enabled = !stabilization_enabled
		send_byjax(src.occupant_legacy,"exosuit.browser","stabilization_command","[stabilization_enabled?"Dis":"En"]able thruster stabilization")
		src.occupant_message("<span class='notice'>Thruster stabilization [stabilization_enabled? "enabled" : "disabled"].</span>")
		return

/obj/vehicle/sealed/mecha/working/hoverpod/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_stabilization=1'><span id="stabilization_command">[stabilization_enabled?"Dis":"En"]able thruster stabilization</span></a><br>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/vehicle/sealed/mecha/working/hoverpod/can_ztravel()
	return (stabilization_enabled && has_charge(step_energy_drain))

// No space drifting
/obj/vehicle/sealed/mecha/working/hoverpod/check_for_support()
	//does the hoverpod have enough charge left to stabilize itself?
	if (!has_charge(step_energy_drain))
		ion_trail.stop()
	else
		if (!ion_trail.on)
			ion_trail.start()
		if (stabilization_enabled)
			return 1

	return ..()

// No falling if we've got our boosters on
/obj/vehicle/sealed/mecha/working/hoverpod/can_fall()
	if(stabilization_enabled && has_charge(step_energy_drain))
		return FALSE
	else
		return TRUE

/*	// One horrific bastardization of glorious inheritence dead. A billion to go. ~Mech
//these three procs overriden to play different sounds
/obj/vehicle/sealed/mecha/working/hoverpod/mechturn(direction)
	setDir(direction)
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/obj/vehicle/sealed/mecha/working/hoverpod/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result


/obj/vehicle/sealed/mecha/working/hoverpod/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result
*/

//Hoverpod variants
/obj/vehicle/sealed/mecha/working/hoverpod/combatpod
	desc = "An ancient, run-down combat spacecraft." // Ideally would have a seperate icon.
	name = "Combat Hoverpod"
	integrity = 200
	integrity_max = 200
	internal_damage_threshold = 35
	cargo_capacity = 2
	max_equip = 2
	max_hull_equip = 2
	max_weapon_equip = 2
	max_utility_equip = 2
	max_universal_equip = 1
	max_special_equip = 1

/obj/vehicle/sealed/mecha/working/hoverpod/combatpod/Initialize(mapload)
	. = ..()
	var/obj/item/vehicle_module/ME = new /obj/item/vehicle_module/weapon/energy/laser
	ME.attach(src)
	ME = new /obj/item/vehicle_module/weapon/ballistic/missile_rack/explosive
	ME.attach(src)


/obj/vehicle/sealed/mecha/working/hoverpod/shuttlepod
	desc = "Who knew a tiny ball could fit three people?"

/obj/vehicle/sealed/mecha/working/hoverpod/shuttlepod/Initialize(mapload)
	. = ..()
	var/obj/item/vehicle_module/ME = new /obj/item/vehicle_module/tool/passenger
	ME.attach(src)
	ME = new /obj/item/vehicle_module/tool/passenger
	ME.attach(src)
