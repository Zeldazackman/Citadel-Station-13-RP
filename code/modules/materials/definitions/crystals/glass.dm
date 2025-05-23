/datum/prototype/material/glass
	id = MAT_GLASS
	name = "glass"
	stack_type = /obj/item/stack/material/glass
	icon_colour = "#00E1FF"
	opacity = 0.3
	relative_integrity = 0.25
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/Glasshit.ogg'
	// glass doesn't conduct
	relative_conductivity = 0
	door_icon_base = "stone"
	destruction_desc = "shatters"
	window_options = list("One Direction" = 1, "Full Window" = 2, "Windoor" = 2)
	created_window = /obj/structure/window/basic
	created_fulltile_window = /obj/structure/window/basic/full
	rod_product = /obj/item/stack/material/glass/reinforced
	table_icon_base = "glass"
	table_reinf_icon_base = "rglass"
	tgui_icon_key = "glass"

	relative_integrity = 0.75
	relative_reactivity = 0
	relative_permeability = 0
	hardness = MATERIAL_RESISTANCE_HIGH
	toughness = MATERIAL_RESISTANCE_VERY_VULNERABLE
	refraction = MATERIAL_RESISTANCE_NONE
	absorption = MATERIAL_RESISTANCE_NONE
	nullification = MATERIAL_RESISTANCE_NONE
	density = 8 * 1
	relative_conductivity = 0

	worth = 0.5

/datum/prototype/material/glass/build_windows(var/mob/living/user, var/obj/item/stack/used_stack)

	if(!user || !used_stack || !created_window || !created_fulltile_window || !window_options.len)
		return 0

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>This task is too complex for your clumsy hands.</span>")
		return 1

	var/title = "Sheet-[used_stack.name] ([used_stack.get_amount()] sheet\s left)"
	var/choice = input(title, "What would you like to construct?") as null|anything in window_options
	var/build_path = /obj/structure/windoor_assembly
	var/sheets_needed = window_options[choice]
	if(choice == "Windoor")
		if(is_reinforced())
			build_path = /obj/structure/windoor_assembly/secure
	else if(choice == "Full Window")
		build_path = created_fulltile_window
	else
		build_path = created_window

	if(used_stack.get_amount() < sheets_needed)
		to_chat(user, "<span class='warning'>You need at least [sheets_needed] sheets to build this.</span>")
		return 1

	if(!choice || !used_stack || !user || used_stack.loc != user || user.stat)
		return 1

	var/turf/T = user.loc
	if(!istype(T))
		to_chat(user, "<span class='warning'>You must be standing on open flooring to build a window.</span>")
		return 1

	// Get data for building windows here.
	var/list/possible_directions = GLOB.cardinal.Copy()
	var/window_count = 0
	for (var/obj/structure/window/check_window in user.loc)
		window_count++
		if(check_window.fulltile)
			possible_directions -= GLOB.cardinal
		else
			possible_directions -= check_window.dir
	for (var/obj/structure/windoor_assembly/check_assembly in user.loc)
		window_count++
		possible_directions -= check_assembly.dir
	for (var/obj/machinery/door/window/check_windoor in user.loc)
		window_count++
		possible_directions -= check_windoor.dir

	// Get the closest available dir to the user's current facing.
	var/build_dir = SOUTHWEST //Default to southwest for fulltile windows.
	var/failed_to_build

	if(window_count >= 4)
		failed_to_build = 1
	else
		if(choice in list("One Direction","Windoor"))
			if(possible_directions.len)
				for(var/direction in list(user.dir, turn(user.dir,90), turn(user.dir,270), turn(user.dir,180)))
					if(direction in possible_directions)
						build_dir = direction
						break
			else
				failed_to_build = 1
	if(failed_to_build)
		to_chat(user, "<span class='warning'>There is no room in this location.</span>")
		return 1

	// Build the structure and update sheet count etc.
	used_stack.use(sheets_needed)
	new build_path(T, build_dir, 1)
	return 1

/datum/prototype/material/glass/proc/is_reinforced()
	return FALSE

/datum/prototype/material/glass/reinforced
	id = "glass_reinf"
	name = "rglass"
	display_name = "reinforced glass"
	stack_type = /obj/item/stack/material/glass/reinforced
	icon_colour = "#00E1FF"
	opacity = 0.
	relative_integrity = 0.5
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/Glasshit.ogg'
	stack_origin_tech = list(TECH_MATERIAL = 2)
	composite_material = list(MAT_STEEL = SHEET_MATERIAL_AMOUNT / 2, MAT_GLASS = SHEET_MATERIAL_AMOUNT)
	window_options = list("One Direction" = 1, "Full Window" = 2, "Windoor" = 2)
	created_window = /obj/structure/window/reinforced
	created_fulltile_window = /obj/structure/window/reinforced/full
	wire_product = null
	rod_product = null
	tgui_icon_key = "rglass"

	relative_integrity = 1
	hardness = MATERIAL_RESISTANCE_HIGH
	toughness = MATERIAL_RESISTANCE_VULNERABLE
	refraction = MATERIAL_RESISTANCE_NONE
	absorption = MATERIAL_RESISTANCE_NONE
	nullification = MATERIAL_RESISTANCE_NONE
	density = 8 * 1.15

/datum/prototype/material/glass/reinforced/is_reinforced()
	return TRUE

/datum/prototype/material/glass/phoron
	id = "glass_boro"
	name = "borosilicate glass"
	display_name = "borosilicate glass"
	stack_type = /obj/item/stack/material/glass/phoronglass
	relative_integrity = 1
	icon_colour = "#FC2BC5"
	stack_origin_tech = list(TECH_MATERIAL = 4)
	window_options = list("One Direction" = 1, "Full Window" = 2)
	created_window = /obj/structure/window/phoronbasic
	created_fulltile_window = /obj/structure/window/phoronbasic/full
	wire_product = null
	rod_product = /obj/item/stack/material/glass/phoronrglass
	tgui_icon_key = "pglass"

	relative_integrity = 1.25
	hardness = MATERIAL_RESISTANCE_HIGH
	toughness = MATERIAL_RESISTANCE_MODERATE
	refraction = MATERIAL_RESISTANCE_LOW
	absorption = MATERIAL_RESISTANCE_LOW
	nullification = MATERIAL_RESISTANCE_NONE
	density = 8 * 1.3

/datum/prototype/material/glass/phoron/reinforced
	id = "glass_boro_reinf"
	name = "reinforced borosilicate glass"
	display_name = "reinforced borosilicate glass"
	stack_type = /obj/item/stack/material/glass/phoronrglass
	stack_origin_tech = list(TECH_MATERIAL = 5)
	relative_integrity = 1.25
	composite_material = list() //todo
	window_options = list("One Direction" = 1, "Full Window" = 2)
	created_window = /obj/structure/window/phoronreinforced
	created_fulltile_window = /obj/structure/window/phoronreinforced/full
	stack_origin_tech = list(TECH_MATERIAL = 2)
	composite_material = list() //todo
	rod_product = null
	tgui_icon_key = "prglass"

	relative_integrity = 1.5
	hardness = MATERIAL_RESISTANCE_HIGH
	toughness = MATERIAL_RESISTANCE_HIGH
	refraction = MATERIAL_RESISTANCE_LOW
	absorption = MATERIAL_RESISTANCE_HIGH
	nullification = MATERIAL_RESISTANCE_NONE
	density = 8 * 1.6

/datum/prototype/material/glass/phoron/reinforced/is_reinforced()
	return TRUE
