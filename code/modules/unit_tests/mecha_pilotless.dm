///Ensure that it's techincally possible to have a mecha that moves and does (mostly) everything a mecha can do, even without a pilot
/datum/unit_test/mecha_pilotless

/datum/unit_test/mecha_pilotless/Run()
	var/obj/vehicle/sealed/mecha/marauder/loaded/mech = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	mecha.set_to_operational()
	TEST_ASSERT(mech.mecha_flags & MECHA_OPERATIONAL, "mech doesn't have the MECHA_OPERATIONAL flag")

	//move the mecha around
	for(var/i in 1 to 8)
		mech.vehicle_move(pick(GLOB.alldirs))
	mech.toggle_strafe()
	//do it again for good measure
	for(var/i in 1 to 8)
		mech.vehicle_move(pick(GLOB.alldirs))

	var/turf/in_front_of_us = get_step(mech, mech.dir)

	//Check that we can properly attack things even without a pilot
	var/obj/structure/girder/girder = allocate(__IMPLIED_TYPE__, in_front_of_us)
	mech.interact_with_atom(girder, null, only_melee = TRUE)

	//Ditto
	var/obj/structure/chair/chair = allocate(__IMPLIED_TYPE__, in_front_of_us)
	mech.interact_with_atom(chair, null, modifiers = list(BUTTON = RIGHT_CLICK))
	if(QDELETED(chair))
		chair = allocate(__IMPLIED_TYPE__, in_front_of_us)
	mech.interact_with_atom(chair, null, modifiers = list(BUTTON = LEFT_CLICK))

	mech.emp_act(EMP_HEAVY) //Let's see if something awful happens when an active mecha is emped without a pilot...

	mech.reset_to_non_operational()
	TEST_ASSERT_NOT(mech.mecha_flags & MECHA_OPERATIONAL, "mech still has the MECHA_OPERATIONAL flag")
