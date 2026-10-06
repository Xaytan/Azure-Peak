/// Base datum for an occult altar Sacrament.
/// Individual cults should create subtypes of this datum.
/datum/sacrament
	var/name = "Unnamed Sacrament"
	var/description = "An unknown occult rite."
	var/favor_cost = 0
	var/required_tier = 0
	var/needs_consecration = FALSE
	var/list/required_skills = list()
	var/list/required_offerings = list()

	/// Whether this Sacrament is currently available to the altar.
	var/enabled = TRUE

/// Called by the altar before Favor is spent.
/// Returns TRUE if the Sacrament can be performed.
/datum/sacrament/proc/can_perform(var/obj/structure/occultaltar/altar, mob/living/user)
	if (!altar || !user)
		return FALSE

	if (!enabled)
		return FALSE

	if (altar.tier < required_tier)
		return FALSE

	for (var/required_skill in required_skills)
		if (user.get_skill_level(required_skill) < required_skills[required_skill])
			return FALSE

	return TRUE

/// Called after the altar has validated and paid for the Sacrament.
/// Override this proc to implement the actual effect.
/datum/sacrament/proc/perform(var/obj/structure/occultaltar/altar, mob/living/user)
	return FALSE

/// Returns the display name of this Sacrament.
/datum/sacrament/proc/get_name()
	return name

/// Returns the description shown to the player.
/datum/sacrament/proc/get_description()
	return description

/// Returns the base Favor cost.
/// This exists as a proc so individual Sacraments can have dynamic costs.
/datum/sacrament/proc/get_favor_cost(var/obj/structure/occultaltar/altar)
	return favor_cost

/// Datum containing individual requirements to perform a sacrament.
/// Used for things not covered by basic skill and offering checks.
/// Done as datums for easy modularity!
/datum/sacrament_requirement
	var/description = "Do a thing"

/datum/sacrament_requirement/proc/check_requirement_met()

/datum/sacrament_requirement/skill
	var/skill
	var/level
