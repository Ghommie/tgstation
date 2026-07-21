/obj/vehicle/sealed/mecha/phazon
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge anomalous technology and expensive materials."
	name = "\improper Phazon"
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
	phase_state = "phazon-phase"

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

/obj/vehicle/sealed/mecha/phazon/proc/change_damage_type(new_damtype)
	damtype = new_damtype
	playsound(src, 'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	SEND_SIGNAL(src, COMSIG_MECH_CHANGE_DAMAGE_TYPE)

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

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "phasing"
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "enabled" : "disabled"] phasing")
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/proc/on_damtype_switched(datum/source)
	SIGNAL_HANDLER
	button_icon_state = "mech_damtype_[chassis.damtype]"
	build_all_button_icons()

/obj/vehicle/sealed/mecha/phazon/get_shell_circuit_components()
	. = ..()
	. += /obj/item/circuit_component/mecha/phase
	. += /obj/item/circuit_component/mecha/damtype

/obj/item/circuit_component/mecha/phase
	display_name = "Phase"
	desc = "Used to toggle phasing."
	required_mech_type = /obj/vehicle/sealed/mecha/phazon
	var/datum/port/input/toggle
	var/datum/port/output/phasing
	var/datum/port/output/toggled

/obj/item/circuit_component/mecha/phase/populate_ports()
	. = ..()
	toggle = add_input_port("Toggle", PORT_TYPE_SIGNAL)
	phasing = add_output_port("Phasing", PORT_TYPE_BOOLEAN)
	toggled = add_output_port("Toggled", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mecha/damtype
	display_name = "Cycle Damage Type"
	desc = "Used to select the type of damage that the Phazon can deal when punching."
	required_mech_type = /obj/vehicle/sealed/mecha/phazon
	var/datum/port/input/option/damage_mode
	var/datum/port/output/current_mode
	var/datum/port/output/changed

/obj/item/circuit_component/mecha/damtype/populate_ports()
	. = ..()
	var/static/component_options = list(
		BRUTE,
		BURN,
		TOX,
	)
	damage_mode = add_option_port("Damage Mode", component_options)
	current_mode = add_output_port("Damage Mode", PORT_TYPE_STRING)
	changed = add_output_port("Changed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mecha/damtype/register_shell(atom/movable/shell)
	. = ..()
	if(isnull(mech))
		return

	RegisterSignal(mech, COMSIG_MECH_CHANGE_DAMAGE_TYPE, PROC_REF(on_damtype_switched))

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
	changed.set_output(COMPONENT_SIGNAL)
