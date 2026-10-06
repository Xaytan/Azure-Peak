/obj/structure/occultaltar/graggar
	name = "Altar of Slaughter"
	consecration_tool = /obj/item/rogueweapon/huntingknife		/// Item used to consecrate the altar
	patron = /datum/patron/inhumen/graggar

	allowed_offerings = list(
		/obj/item/natural/head/saiga = 10,
		/obj/item/natural/head/direbear = 25,
		/obj/item/organ/heart = 100
	)

	sacrament_types = list(
		/datum/sacrament/inhumen/graggar/bloodcrazed_cleaver
	)
