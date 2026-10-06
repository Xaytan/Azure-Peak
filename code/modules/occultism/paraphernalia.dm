
/obj/structure/cult_statue
	name = "Evil Statue"
	desc = "An evil statue that you shouldn't be seeing. Report me! REPORT MEEE!"
	var/patron = /datum/patron/godless
	var/obj/structure/occultaltar/connected_altar


//We register on creation
/obj/structure/cult_statue/Initialize(mapload)
	. = ..()
	for (var/obj/structure/occultaltar/o in oview(5, src))
		if(o.patron == src.patron)
			src.connected_altar = o
			o.paraphrenalia += src

//We unregister ourselves when we're destroyed
/obj/structure/cult_statue/Destroy()
	if (connected_altar && connected_altar.paraphrenalia)
		connected_altar.paraphrenalia -= src
	connected_altar = null
	. = ..()
