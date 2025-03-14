// LEGACY_RECORD_STRUCTURE(all_waypoints, waypoint)
GLOBAL_LIST_EMPTY(all_waypoints)
/datum/computer_file/data/waypoint
	var/list/fields
	filetype = "WPT"

/datum/computer_file/data/waypoint/New()
	..()
	fields = list()
	GLOB.all_waypoints.Add(src)

/datum/computer_file/data/waypoint/Destroy()
	. = ..()
	GLOB.all_waypoints.Remove(src);
// End LEGACY_RECORD_STRUCTURE(all_waypoints, waypoint)

/obj/machinery/computer/ship/helm
	name = "helm control console"
	icon_keyboard = "teleport_key"
	icon_screen = "helm"
	light_color = "#7faaff"
	circuit = /obj/item/circuitboard/helm
	core_skill = /datum/skill/pilot
	var/autopilot = 0
	var/autopilot_disabled = TRUE
	var/list/known_sectors = list()
	var/dx //desitnation
	var/dy //coordinates

	/// Top speed for autopilot, 5
	var/speedlimit = 1/(20 SECONDS)
	/// Manual limiter for acceleration.
	var/accellimit = 0.001
	req_one_access = list(ACCESS_GENERAL_PILOT)

// fancy sprite
/obj/machinery/computer/ship/helm/adv
	icon_keyboard = null
	icon_state = "adv_helm"
	icon_screen = "adv_helm_screen"
	light_color = "#70ffa0"

/obj/machinery/computer/ship/helm/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ship/helm/LateInitialize()
	get_known_sectors()

/obj/machinery/computer/ship/helm/proc/get_known_sectors()
	var/area/overmap/map = locate() in world
	for(var/obj/overmap/entity/visitable/sector/S in map)
		if (S.known)
			var/datum/computer_file/data/waypoint/R = new()
			R.fields["name"] = S.name
			R.fields["x"] = S.get_tile_x()
			R.fields["y"] = S.get_tile_y()
			known_sectors[S.name] = R

/obj/machinery/computer/ship/helm/process(delta_time)
	..()
	if(autopilot && dx && dy && !autopilot_disabled)
		var/turf/T = locate(dx, dy, linked.z)
		if(linked.loc == T)
			if(!linked.is_moving())
				autopilot = 0
			else
				linked.decelerate()
		else
			var/brake_path = linked.get_brake_path()
			var/direction = get_dir(linked.loc, T)
			var/acceleration = min(linked.get_acceleration_legacy(), accellimit)
			var/speed = linked.get_speed_legacy()
			var/heading = linked.get_heading_direction()

			// Destination is current grid or speedlimit is exceeded
			if((get_dist(linked.loc, T) <= brake_path) || speed > speedlimit)
				linked.decelerate()
			// Heading does not match direction
			else if(heading & ~direction)
				linked.accelerate(turn(heading & ~direction, 180), accellimit)
			// All other cases, move toward direction
			else if(speed + acceleration <= speedlimit)
				linked.accelerate(direction, accellimit)
		return

/obj/machinery/computer/ship/helm/ui_interact(mob/user, datum/tgui/ui)
	if(!linked)
		display_reconnect_dialog(user, "helm")
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapHelm", "[linked.name] Helm Control") // 565, 545
		ui.open()

/obj/machinery/computer/ship/helm/ui_data(mob/user, datum/tgui/ui)
	var/list/data = ..()

	var/turf/T = get_turf(linked)
	var/obj/overmap/entity/visitable/sector/current_sector = locate() in T

	data["sector"] = current_sector ? current_sector.name : "Deep Space"
	data["sector_info"] = current_sector ? current_sector.desc : "Not Available"
	data["landed"] = linked.get_landed_info()
	data["s_x"] = linked.get_tile_x()
	data["s_y"] = linked.get_tile_y()
	data["dest"] = dy && dx
	data["d_x"] = dx
	data["d_y"] = dy
	data["speedlimit"] = speedlimit ? speedlimit*1000 : "Halted"
	data["accel"] = min(round(linked.get_acceleration_legacy()*1000, 0.01),accellimit*1000)
	data["heading"] = linked.get_heading()
	data["autopilot_disabled"] = autopilot_disabled
	data["autopilot"] = autopilot
	data["manual_control"] = viewing_overmap(user)
	data["canburn"] = linked.can_burn()
	data["accellimit"] = accellimit*1000

	var/speed = round(linked.get_speed_legacy()*1000, 0.01)
	var/speed_color = null
	if(linked.get_speed_legacy() < SHIP_SPEED_SLOW)
		speed_color = "good"
	if(linked.get_speed_legacy() > SHIP_SPEED_FAST)
		speed_color = "average"
	data["speed"] = speed
	data["speed_color"] = speed_color

	if(linked.get_speed_legacy())
		data["ETAnext"] = "[round(linked.ETA()/10)] seconds"
	else
		data["ETAnext"] = "N/A"

	var/list/locations[0]
	for (var/key in known_sectors)
		var/datum/computer_file/data/waypoint/R = known_sectors[key]
		var/list/rdata[0]
		rdata["name"] = R.fields["name"]
		rdata["x"] = R.fields["x"]
		rdata["y"] = R.fields["y"]
		rdata["reference"] = "\ref[R]"
		locations.Add(list(rdata))

	data["locations"] = locations
	return data

/obj/machinery/computer/ship/helm/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	if(!linked)
		return FALSE

	switch(action)
		if("add")
			var/datum/computer_file/data/waypoint/R = new()
			var/sec_name = input("Input navigation entry name", "New navigation entry", "Sector #[known_sectors.len]") as text
			if(ui_status(usr, ui.state) != UI_INTERACTIVE)
				return FALSE
			if(!sec_name)
				sec_name = "Sector #[known_sectors.len]"
			R.fields["name"] = sec_name
			if(sec_name in known_sectors)
				to_chat(usr, "<span class='warning'>Sector with that name already exists, please input a different name.</span>")
				return TRUE
			switch(params["add"])
				if("current")
					R.fields["x"] = linked.get_tile_x()
					R.fields["y"] = linked.get_tile_y()
				if("new")
					var/newx = input("Input new entry x coordinate", "Coordinate input", linked.get_tile_x()) as num
					if(ui_status(usr, ui.state) != UI_INTERACTIVE)
						return TRUE
					var/newy = input("Input new entry y coordinate", "Coordinate input", linked.get_tile_y()) as num
					if(ui_status(usr, ui.state) != UI_INTERACTIVE)
						return FALSE
					R.fields["x"] = clamp(newx, 1, world.maxx)
					R.fields["y"] = clamp(newy, 1, world.maxy)
			known_sectors[sec_name] = R
			. = TRUE

		if("remove")
			var/datum/computer_file/data/waypoint/R = locate(params["remove"])
			if(R)
				known_sectors.Remove(R.fields["name"])
				qdel(R)
			. = TRUE

		if("setcoord")
			if(params["setx"])
				var/newx = input("Input new destiniation x coordinate", "Coordinate input", dx) as num|null
				if(ui_status(usr, ui.state) != UI_INTERACTIVE)
					return
				if(newx)
					dx = clamp(newx, 1, world.maxx)

			if(params["sety"])
				var/newy = input("Input new destiniation y coordinate", "Coordinate input", dy) as num|null
				if(ui_status(usr, ui.state) != UI_INTERACTIVE)
					return
				if(newy)
					dy = clamp(newy, 1, world.maxy)
			. = TRUE

		if("setds")
			dx = text2num(params["x"])
			dy = text2num(params["y"])
			. = TRUE

		if("reset")
			dx = 0
			dy = 0
			. = TRUE

		if("speedlimit")
			var/newlimit = input("Input new speed limit for autopilot (0 to brake)", "Autopilot speed limit", speedlimit*1000) as num|null
			if(newlimit)
				speedlimit = clamp(newlimit/1000, 0, 100)
			. = TRUE

		if("accellimit")
			var/newlimit = input("Input new acceleration limit", "Acceleration limit", accellimit*1000) as num|null
			if(newlimit)
				accellimit = max(newlimit/1000, 0)
			. = TRUE

		if("move")
			var/ndir = text2num(params["dir"])
			linked.relaymove(usr, ndir, accellimit)
			. = TRUE

		if("brake")
			linked.decelerate()
			. = TRUE

		if("apilot")
			if(autopilot_disabled)
				autopilot = FALSE
			else
				autopilot = !autopilot
			. = TRUE

		if("apilot_lock")
			autopilot_disabled = !autopilot_disabled
			autopilot = FALSE
			. = TRUE

		if("manual")
			viewing_overmap(usr) ? unlook(usr) : look(usr)
			. = TRUE

	add_fingerprint(usr)
	if(. && !issilicon(usr))
		playsound(src, SFX_ALIAS_TERMINAL, 50, 1)


/obj/machinery/computer/ship/navigation
	name = "navigation console"
	icon_keyboard = "generic_key"
	icon_screen = "helm"
	circuit = /obj/item/circuitboard/nav
	var/datum/tgui_module_old/ship/nav/nav_tgui

/obj/machinery/computer/ship/navigation/Initialize(mapload)
	. = ..()
	nav_tgui = new(src)

/obj/machinery/computer/ship/navigation/Destroy()
	QDEL_NULL(nav_tgui)
	. = ..()

/obj/machinery/computer/ship/navigation/sync_linked(user)
	return nav_tgui?.sync_linked()

/obj/machinery/computer/ship/navigation/ui_interact(mob/user, datum/tgui/ui)
	return nav_tgui?.ui_interact(user, ui)

/obj/machinery/computer/ship/navigation/telescreen	//little hacky but it's only used on one ship so it should be okay
	icon_state = "tele_nav"
	layer = ABOVE_WINDOW_LAYER
	icon_keyboard = null
	icon_screen = null
	circuit = /obj/item/circuitboard/nav/tele
	density = FALSE
	depth_projected = FALSE
	climb_allowed = FALSE

/obj/machinery/computer/ship/navigation/telescreen/update_icon()
	if(machine_stat & NOPOWER || machine_stat & BROKEN)
		icon_state = "tele_off"
		set_light(0)
	else
		icon_state = "tele_nav"
		set_light(light_range_on, light_power_on)
	..()
