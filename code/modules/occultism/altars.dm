/obj/structure/occultaltar
	name = "Occult Altar"
	icon_state = "sacrificealtar"

	/// How much Favor is currently stored in the altar.
	var/favor = 0

	/// Maximum amount of Favor the altar can hold.
	var/max_favor = 100

	/// Current upgrade tier. Determines available sacraments.
	var/tier = 0

	/// Maximum upgrade tier.
	var/max_tier = 3

	/// Whether the altar has been consecrated.
	///
	/// Consecration is a special state which unlocks additional,
	/// more restricted sacraments. It is not required for every
	/// sacrament.
	var/consecrated = FALSE

	/// Patron associated with this altar.
	var/patron = /datum/patron/godless

	/// Item required to consecrate this altar.
	var/obj/item/consecration_tool

	/// Sacrament datum types available to this altar.
	/// These are instantiated once and owned by the altar.
	var/list/sacrament_types = list()

	/// Persistent sacrament instances belonging to this altar.
	var/list/datum/sacrament/sacraments = list()

	var/list/paraphrenalia = list()

	buckle_lying = 1
	can_buckle = 1
	buckle_prevents_pull = TRUE

	var/list/allowed_offerings = list(
		/obj/item/natural/stone = 10,
		/obj/item/grown/log/tree/stick = 5
	)

	var/list/upgrade_messages = list(
		"Upgrade tier 1",
		"Upgrade tier 2",
		"Upgrade tier 3"
	)


/obj/structure/occultaltar/Initialize()
	. = ..()

	for (var/sacrament_type in sacrament_types)
		sacraments += new sacrament_type(src)


/obj/structure/occultaltar/Destroy()
	QDEL_LIST(sacraments)
	sacraments = null
	return ..()


/obj/structure/occultaltar/proc/adjust_favor(amount)
	/// Adjusts stored Favor by the supplied amount.
	/// Returns the actual amount gained or spent.
	if (!amount)
		return 0

	var/old_favor = favor
	favor = clamp(favor + amount, 0, max_favor)

	return favor - old_favor


/obj/structure/occultaltar/proc/add_favor(amount)
	/// Adds Favor after applying the altar's current generation multiplier.
	/// Returns the actual amount gained after the max_favor cap.
	if (amount <= 0)
		return 0

	var/multiplier = calculate_favor_multiplier()
	var/modified_amount = amount * multiplier

	return adjust_favor(modified_amount)


/obj/structure/occultaltar/proc/calculate_favor_cost(amount)
	/// Returns the actual Favor cost after discounts.
	/// A discount of 0.25 means a 25% reduction.
	if (amount <= 0)
		return 0

	var/discount = clamp(calculate_favor_discount(), 0, 1)

	return max(0, amount * (1 - discount))


/obj/structure/occultaltar/proc/spend_favor(amount)
	/// Attempts to spend Favor.
	/// Returns TRUE if the full cost could be paid.
	if (amount <= 0)
		return TRUE

	var/modified_amount = calculate_favor_cost(amount)

	if (favor < modified_amount)
		return FALSE

	adjust_favor(-modified_amount)
	return TRUE


/obj/structure/occultaltar/proc/calculate_favor_discount()
	/// Returns the current discount applied to Favor expenditures.
	/// Returned as a decimal percentage; 0.25 = 25% discount.
	return 0


/obj/structure/occultaltar/proc/calculate_favor_multiplier()
	/// Returns the current multiplier applied to Favor generation.
	/// Individual cult altars can override this.
	return 1.0


/obj/structure/occultaltar/proc/upgrade_tier()
	/// Attempts to upgrade the altar to the next tier.
	/// Returns TRUE if the upgrade succeeds.
	if (!can_upgrade_tier())
		return FALSE

	tier++
	return TRUE


/obj/structure/occultaltar/proc/can_upgrade_tier()
	/// Returns TRUE if the altar meets all requirements for its next tier.
	/// Individual cult altars should override this.
	return tier < max_tier


/obj/structure/occultaltar/proc/can_use_altar(mob/living/user)
	/// Hook for altar-specific user restrictions.
	/// Individual altars can override this for patron/cult-specific restrictions.
	return TRUE


/obj/structure/occultaltar/attackby(obj/item/attacking_item, mob/living/user, params)
	if (!can_use_altar(user))
		return ..()

	if (attempt_consecrate_altar(user, attacking_item))
		return

	if (attempt_offer_item(attacking_item, user))
		return

	return ..()


/obj/structure/occultaltar/proc/attempt_offer_item(obj/item/offering, mob/living/user)
	/// Attempts to sacrifice an item to the altar.
	/// Offering values are matched by type, so subtypes of an allowed type
	/// are accepted as well.
	/// Returns TRUE if the item was accepted and Favor was actually gained.
	if (!offering)
		return FALSE

	var/offer_value = 0

	for (var/allowed_type in allowed_offerings)
		if (istype(offering, allowed_type))
			offer_value = allowed_offerings[allowed_type]
			break

	if (offer_value <= 0)
		return FALSE

	var/gained_favor = add_favor(offer_value)

	// Do not consume an offering if the altar could not gain any Favor from it.
	if (gained_favor <= 0)
		return FALSE

	qdel(offering)
	return TRUE


/obj/structure/occultaltar/attack_hand(mob/user)
	ui_interact(user)


/obj/structure/occultaltar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if (!ui)
		ui = new(user, src, "OccultAltar", name)
		ui.open()


/obj/structure/occultaltar/ui_data(mob/user)
	var/list/data = ..()

	data["favor"] = favor
	data["max_favor"] = max_favor
	data["tier"] = tier
	data["max_tier"] = max_tier
	data["consecrated"] = consecrated

	return data


/obj/structure/occultaltar/ui_static_data(mob/user)
	var/list/data = ..()
	var/list/sacrament_data = list()

	for (var/datum/sacrament/S in sacraments)
		UNTYPED_LIST_ADD(sacrament_data, list(
			"name" = S.name,
			"description" = S.description,
			"favor_cost" = calculate_favor_cost(S.favor_cost),
			"required_tier" = S.required_tier,
			"needs_consecration" = S.needs_consecration,
			"can_perform" = can_perform_sacrament(S, user),
			"ref" = REF(S)
		))

	data["sacraments"] = sacrament_data

	return data


/obj/structure/occultaltar/ui_act(action, list/params, datum/tgui/ui)
	. = ..()

	if (.)
		return

	var/mob/user = ui.user

	switch (action)
		if ("choose_sacrament")
			var/datum/sacrament/S = locate(params["ref"])

			if (!istype(S))
				return TRUE

			if (!can_use_altar(user))
				return TRUE

			attempt_perform_sacrament(S, user)
			return TRUE

	return FALSE


/obj/structure/occultaltar/proc/attempt_perform_sacrament(datum/sacrament/S, mob/living/user)
	/// Attempts to perform the given Sacrament.
	/// Handles generic altar validation, Sacrament-specific validation,
	/// and Favor expenditure.
	/// Returns TRUE if the Sacrament was successfully performed.
	if (!S || !user)
		return FALSE

	if (!can_perform_sacrament(S, user))
		return FALSE

	if (!S.can_perform(src, user))
		return FALSE

	if (!spend_favor(S.favor_cost))
		return FALSE

	return S.perform(src, user)


/obj/structure/occultaltar/proc/can_perform_sacrament(datum/sacrament/S, mob/living/user)
	/// Generic altar-side validation for a Sacrament.
	/// Individual Sacraments handle their own specific requirements.
	if (!S || !user)
		return FALSE

	if (!S.enabled)
		return FALSE

	if (S.required_tier > tier)
		return FALSE

	if (S.needs_consecration && !consecrated)
		return FALSE

	if (favor < calculate_favor_cost(S.favor_cost))
		return FALSE

	return TRUE


/obj/structure/occultaltar/proc/attempt_consecrate_altar(mob/living/user, obj/item/item)
	/// Attempts to consecrate the altar using the required consecration tool.
	/// Individual altars can override can_consecrate_altar() for role,
	/// patron, or skill requirements.
	if (!user || !item)
		return FALSE

	if (consecrated)
		return FALSE

	if (!consecration_tool || !istype(item, consecration_tool))
		return FALSE

	if (!can_consecrate_altar(user))
		return FALSE

	consecrated = TRUE
	return TRUE


/obj/structure/occultaltar/proc/can_consecrate_altar(mob/living/user)
	var/mob/living/carbon/human/H
	if(!ishuman(user))
		return
	H = user
	//We have to worship the right god...
	if(H.patron?.type != src.patron)
		return FALSE
	//We have to be a full, proper cleric...
	if(H.devotion && H.devotion.level >= CLERIC_T3)
		return TRUE
	//Or we can be a foul witch!
	if(HAS_TRAIT(H, TRAIT_WITCH))
		return TRUE

	return FALSE
