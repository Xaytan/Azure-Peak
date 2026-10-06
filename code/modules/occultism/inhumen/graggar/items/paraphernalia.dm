/obj/structure/cult_statue/graggar
	name = "Scrimshaw Totem"
	desc = "A monument of carved bone and animal hide, glorifying Graggar in violence."
	//Placeholders from Maniac
	icon = 'icons/roguetown/maniac/creations.dmi'
	icon_state = "creation1"

//TODO - Lock behind Horde trait.
/datum/crafting_recipe/roguetown/structure/cult_statue/graggar
	name = "Scrimshaw Totem - GRAGGARITE"
	result = /obj/structure/cult_statue/graggar
	reqs = list(
		/obj/item/natural/bone = 3,
		/obj/item/reagent_containers/food/snacks/rogue/meat = 2
	)
	tools = list(/obj/item/rogueweapon/huntingknife)
	verbage_simple = "carves"
	verbage = "carves"
	skillcraft = /datum/skill/labor/butchering
