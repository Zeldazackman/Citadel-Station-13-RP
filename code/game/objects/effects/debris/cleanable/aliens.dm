/obj/effect/debris/cleanable/blood/xeno
	name = "xeno blood"
	desc = "It's green and acidic. It looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	basecolor = "#05EE05"

/obj/effect/debris/cleanable/blood/gibs/xeno
	name = "xeno gibs"
	desc = "Gnarly..."
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	basecolor = "#05EE05"

/obj/effect/debris/cleanable/blood/gibs/xeno/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/debris/cleanable/blood/gibs/xeno/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/debris/cleanable/blood/gibs/xeno/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/debris/cleanable/blood/gibs/xeno/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/debris/cleanable/blood/gibs/xeno/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/debris/cleanable/blood/xtracks
	basecolor = "#05EE05"
