/obj/vehicle/sealed/mecha/phazon
	name = "\improper Phazon"
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge anomalous technology and expensive materials."
	icon_state = "phazon"
	base_icon_state = "phazon"
	movedelay = 2
	step_energy_drain = 4
	max_integrity = 200
	armor_type = /datum/armor/mecha_phazon
	max_temperature = 25000
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/phazon
	mech_type = EXOSUIT_MODULE_PHAZON
	force = 15
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)

	/// Are we currently phasing through walls?
	var/phasing = FALSE
	/// Power we use every time we phaze through something
	var/phasing_energy_drain = 0.2 * STANDARD_CELL_CHARGE
	/// Icon_state for flick() when phasing
	var/phase_state = "phazon-phase"

/datum/armor/mecha_phazon
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 30
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/phazon/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_phasing)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_switch_damtype)

/obj/vehicle/sealed/mecha/phazon/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	if(!phasing || get_charge() <= phasing_energy_drain || throwing)
		return ..()
	if(phase_state)
		flick(phase_state, src)
	var/turf/destination_turf = get_step(loc, movement_dir)
	if(!check_teleport_valid(src, destination_turf) || SSmapping.level_trait(destination_turf.z, ZTRAIT_NOPHASE))
		return FALSE
	return TRUE

/obj/vehicle/sealed/mecha/phazon/vehicle_move(direction, forcerotate)
	. = ..()
	if(. && phasing)
		use_energy(phasing_energy_drain)

/obj/vehicle/sealed/mecha/phazon/try_bumpsmash(atom/obstacle)
	if(phasing) // Theres only one cause for phasing canpass fails
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("A dull, universal force is preventing you from phasing here!")]")
		spark_system.start()
		return
	return ..()

/obj/vehicle/sealed/mecha/phazon/update_energy_drain()
	. = ..()
	if(capacitor)
		phasing_energy_drain = initial(phasing_energy_drain) / capacitor.rating
	else
		phasing_energy_drain = initial(phasing_energy_drain)

/obj/vehicle/sealed/mecha/phazon/can_interact_with(atom/target, mob/user, list/modifiers)
	. = ..()
	if (!. || !phasing)
		return
	balloon_alert(user, "not while phasing!")
	return FALSE

/obj/vehicle/sealed/mecha/phazon/proc/change_damage_type(new_damtype)
	damtype = new_damtype
	playsound(src, 'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	SEND_SIGNAL(src, COMSIG_MECH_CHANGE_DAMAGE_TYPE)

/obj/vehicle/sealed/mecha/phazon/proc/toggle_phasing(mob/user)
	phasing = phasing
	balloon_alert(user, "[phasing ? "enabled" : "disabled"] phasing")
	SEND_SIGNAL(src, COMSIG_MECHA_TOGGLE_PHASING, phasing)

/obj/vehicle/sealed/mecha/phazon/get_shell_circuit_components()
	. = ..()
	. += /obj/item/circuit_component/mecha/phase
	. += /obj/item/circuit_component/mecha/damtype

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/set_chassis(passed_chassis)
	. = ..()
	RegisterSignal(chassis, COMSIG_MECH_CHANGE_DAMAGE_TYPE, PROC_REF(on_damtype_switched))

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			chassis.balloon_alert(owner, "your punches will now deal brute damage")
		if(BRUTE)
			new_damtype = BURN
			chassis.balloon_alert(owner, "your punches will now deal burn damage")
		if(BURN)
			new_damtype = TOX
			chassis.balloon_alert(owner,"your punches will now deal toxin damage")
	var/obj/vehicle/sealed/mecha/phazon/phazon = chassis
	phazon.change_damage_type(new_damtype)

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/proc/on_damtype_switched(datum/source)
	SIGNAL_HANDLER
	button_icon_state = "mech_damtype_[chassis.damtype]"
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/set_chassis(passed_chassis)
	. = ..()
	RegisterSignal(chassis, COMSIG_MECHA_TOGGLE_PHASING, PROC_REF(on_phasing_toggled))

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/phazon/phazon = chassis
	phazon.toggle_phasing(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/proc/on_phasing_toggled(datum/source, phasing)
	SIGNAL_HANDLER
	button_icon_state = "mech_phasing_[phasing ? "on" : "off"]"
	build_all_button_icons()

/obj/item/circuit_component/mecha/phase
	display_name = "Phase"
	desc = "Used to toggle phasing."
	required_mech_type = /obj/vehicle/sealed/mecha/phazon
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL
	var/datum/port/output/phasing

/obj/item/circuit_component/mecha/phase/populate_ports()
	. = ..()
	phasing = add_output_port("Phasing", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/mecha/phase/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECHA_TOGGLE_PHASING, PROC_REF(on_phasing_toggled))

/obj/item/circuit_component/mecha/phase/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_MECHA_TOGGLE_PHASING)
	return ..()

/obj/item/circuit_component/mecha/phase/input_received(datum/port/input/port, list/return_values)
	var/obj/vehicle/sealed/mecha/phazon/phazon = mech
	phazon.toggle_phasing()

/obj/item/circuit_component/mecha/phase/proc/on_phasing_toggled(datum/source, phasing_val)
	SIGNAL_HANDLER
	phasing.set_output(phasing_val)

/obj/item/circuit_component/mecha/damtype
	display_name = "Cycle Damage Type"
	desc = "Used to select the type of damage that the Phazon can deal when punching."
	required_mech_type = /obj/vehicle/sealed/mecha/phazon
	var/datum/port/input/option/damage_mode
	var/datum/port/output/current_mode

/obj/item/circuit_component/mecha/damtype/populate_ports()
	. = ..()
	var/static/component_options = list(
		BRUTE,
		BURN,
		TOX,
	)
	damage_mode = add_option_port("Damage Mode", component_options)
	current_mode = add_output_port("Damage Mode", PORT_TYPE_STRING)

/obj/item/circuit_component/mecha/damtype/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECH_CHANGE_DAMAGE_TYPE, PROC_REF(on_damtype_switched))

/obj/item/circuit_component/mecha/damtype/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_MECH_CHANGE_DAMAGE_TYPE)
	return ..()

/obj/item/circuit_component/mecha/damtype/input_received(datum/port/input/port, list/return_values)
	var/new_damtype = damage_mode.value
	if(!new_damtype)
		return
	var/obj/vehicle/sealed/mecha/phazon/phazon = mech
	phazon.change_damage_type(new_damtype)

/obj/item/circuit_component/mecha/damtype/proc/on_damtype_switched(datum/source)
	SIGNAL_HANDLER
	current_mode.set_output(mech.damtype)
