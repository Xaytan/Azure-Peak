/// Trade an ordinary cleaver for a Bloodcrazed Cleaver through Graggar's consecrated altar.
/datum/sacrament/inhumen/graggar/bloodcrazed_cleaver
	name = "Bloodcrazed Cleaver"
	description = "Offer an ordinary cleaver to Graggar and receive a Bloodcrazed Cleaver in return."
	favor_cost = 500
	needs_consecration = TRUE
	required_skills = list(
		/datum/skill/labor/butchering = 5
	)
	required_offerings = list(
		/obj/item/rogueweapon/huntingknife/chefknife/cleaver
	)

/datum/sacrament/inhumen/graggar/bloodcrazed_cleaver/can_perform(var/obj/structure/occultaltar/altar, mob/living/user)
	if (!..())
		return FALSE

	var/obj/item/held_item = user.get_active_held_item()
	if (!held_item || held_item.type != /obj/item/rogueweapon/huntingknife/chefknife/cleaver)
		return FALSE

	return TRUE

/datum/sacrament/inhumen/graggar/bloodcrazed_cleaver/perform(var/obj/structure/occultaltar/altar, mob/living/user)
	var/obj/item/cleaver = user.get_active_held_item()
	if (!cleaver || cleaver.type != /obj/item/rogueweapon/huntingknife/chefknife/cleaver)
		return FALSE

	qdel(cleaver)

	var/obj/item/rogueweapon/huntingknife/chefknife/cleaver/bloodcrazed/reward = new
	user.put_in_active_hand(reward)

	return TRUE



/datum/sacrament/inhumen/graggar/rage_of_graggar
	name = "Bloody Rage Of Graggar"
	description = "Offer a heart to Graggar and be granted the liquid rage of the Sinistar."
	favor_cost = 100
	needs_consecration = TRUE
	required_skills = list(
		/datum/skill/labor/butchering = 2,
		/datum/skill/combat/knives = 2
	)
	required_offerings = list(
		/obj/item/organ/heart
	)

/datum/sacrament/inhumen/graggar/rage_of_graggar/perform(var/obj/structure/occultaltar/altar, mob/living/user)
	new /obj/structure/ritualcircle/graggar(get_turf(altar))

//TODO: Move this, make better, etc. We're prototyping here.
//I would like more interesting mechanics than this.
/datum/reagent/organpoison/graggars_rage
	name = "Rage of the Sinistar"
	description = "Lightly poisonous, causes nausea. Restores energy and empowers those of Graggar's Horde."
	reagent_state = LIQUID
	color = "#2c1818"
	taste_description = "bloodthirst"
	scent_description = "rancid meat"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	harmful = TRUE

/datum/reagent/organpoison/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_HORDE))
		M.apply_status_effect(/datum/status_effect/buff/graggars_rage)
	return ..()

//TODO: Balance adjustments, give interesting mechanics
/datum/status_effect/buff/graggars_rage
	id = "rabies"
	alert_type = /atom/movable/screen/alert/status_effect/buff/druqks
	effectedstats = list(STATKEY_STR = 2, STATKEY_CON = 2, STATKEY_INT = -4, STATKEY_PER = -2)
	duration = 30 SECONDS
