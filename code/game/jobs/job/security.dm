//////////////////////////////////
//		Head of Security
//////////////////////////////////
/datum/job/hos
	title = "Head of Security"
	flag = HOS
	departments_managed = list(DEPARTMENT_SECURITY)
	departments = list(DEPARTMENT_SECURITY, DEPARTMENT_COMMAND)
	sorting_order = 2
	department_flag = ENGSEC
	disallow_jobhop = TRUE
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Facility Director"
	selection_color = "#8E2929"
	idtype = /obj/item/card/id/security/head
	req_admin_notify = 1
	economic_modifier = 10
	access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_external_airlocks)
	minimal_access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_external_airlocks)
	minimum_character_age = 25
	minimal_player_age = 14

	outfit_type = /decl/hierarchy/outfit/job/security/hos
	alt_titles = list("Security Commander", "Chief of Security","Defense Director")

//////////////////////////////////
//			Warden
//////////////////////////////////
/datum/job/warden
	title = "Warden"
	flag = WARDEN
	departments = list(DEPARTMENT_SECURITY)
	sorting_order = 1
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Security"
	selection_color = "#601C1C"
	idtype = /obj/item/card/id/security/warden
	economic_modifier = 5
	access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory, access_maint_tunnels, access_morgue, access_external_airlocks)
	minimal_access = list(access_security, access_eva, access_sec_doors, access_brig, access_armory, access_maint_tunnels, access_external_airlocks)
	minimal_player_age = 5
	outfit_type = /decl/hierarchy/outfit/job/security/warden
	alt_titles = list("Gaoler", "Senior Constable")

//////////////////////////////////
//			Detective
//////////////////////////////////
/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	departments = list(DEPARTMENT_SECURITY)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Head of Security"
	selection_color = "#601C1C"
	idtype = /obj/item/card/id/security/detective
	access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_eva, access_external_airlocks, access_brig) //Vorestation edit - access_brig
	minimal_access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_eva, access_external_airlocks)
	economic_modifier = 5
	minimal_player_age = 3

	outfit_type = /decl/hierarchy/outfit/job/security/detective
	job_description = "A Detective works to help Security find criminals who have not properly been identified, through interviews and forensic work. \
						For crimes only witnessed after the fact, or those with no survivors, they attempt to piece together what they can from pure evidence."
	alt_titles = list("Forensic Technician" = /datum/alt_title/forensic_tech)

// Detective Alt Titles
/datum/alt_title/forensic_tech
	title = "Forensic Technician"
	title_blurb = "A Forensic Technician works more with hard evidence and labwork than a Detective, but they share the purpose of solving crimes."
	title_outfit = /decl/hierarchy/outfit/job/security/detective/forensic

//////////////////////////////////
//		Security Officer
//////////////////////////////////
/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	departments = list(DEPARTMENT_SECURITY)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Head of Security"
	selection_color = "#601C1C"
	idtype = /obj/item/card/id/security/officer
	economic_modifier = 4
	access = list(access_security, access_eva, access_sec_doors, access_brig, access_maint_tunnels, access_morgue, access_external_airlocks)
	minimal_access = list(access_security, access_eva, access_sec_doors, access_brig, access_maint_tunnels, access_external_airlocks)
	minimal_player_age = 3

	outfit_type = /decl/hierarchy/outfit/job/security/officer
	alt_titles = list("Junior Officer", "Constable", "Security Cadet")
	job_description = "A Security Officer is concerned with maintaining the safety and security of the station as a whole, dealing with external threats and \
						apprehending criminals. A Security Officer is responsible for the health, safety, and processing of any prisoner they arrest. \
						No one is above the Law, not Security or Command."

// Security Officer Alt Titles
/datum/alt_title/junior_officer
	title = "Junior Officer"
	title_blurb = "A Junior Officer is an inexperienced Security Officer. They likely have training, but not experience, and are frequently \
					paired off with a more senior co-worker. Junior Officers may also be expected to take over the boring duties of other Officers \
					including patrolling the station or maintaining specific posts."