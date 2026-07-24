/obj/item/circuit_component/mecha
	/// The mech we are attached to
	var/obj/vehicle/sealed/mecha/mech
	var/required_mech_type = /datum/action/vehicle/sealed/mecha
	var/requires_mech_on = TRUE
	abstract_type = /obj/item/circuit_component/mecha

/obj/item/circuit_component/mecha/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, required_mech_type))
		mech = shell

/obj/item/circuit_component/mecha/unregister_shell(atom/movable/shell)
	mech = null
	return ..()

/obj/item/circuit_component/mecha/should_receive_input(datum/port/input/port)
	if(isnull(mech))
		return FALSE
	if(requires_mech_on && !(mech.mecha_flags & MECHA_OPERATIONAL))
		return FALSE
	return ..()

/obj/item/circuit_component/mecha/main
	display_name = "Engagement"
	desc = "For engaging and disengaging an exosuit, even if it doesn't have an occupant inside."
	requires_mech_on = FALSE

	///Boot up the mecha, even without an occupant
	var/datum/port/input/boot
	///Stop the mecha and eject any eventual occupant.
	var/datum/port/input/shutdown

	///Sent when the mecha is engaged, usually after an occupant climbs in.
	var/datum/port/output/booted
	/// Sent when the mecha is stopped, and the eventual occupant is ejected.
	var/datum/port/output/has_shutdown

/obj/item/circuit_component/mecha/main/populate_ports()
	. = ..()
	boot = add_input_port("Boot", PORT_TYPE_SIGNAL)
	shutdown = add_input_port("Shut Down", PORT_TYPE_SIGNAL)

	booted = add_output_port("Booted", PORT_TYPE_SIGNAL)
	has_shutdown = add_output_port("Has Shut Down", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mecha/main/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECHA_IS_OPERATIONAL, PROC_REF(on_operational))
	RegisterSignal(shell, COMSIG_MECHA_NOT_OPERATIONAL, PROC_REF(on_not_operational))

/obj/item/circuit_component/mecha/main/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_MECHA_IS_OPERATIONAL, COMSIG_MECHA_NOT_OPERATIONAL))
	return ..()

/obj/item/circuit_component/mecha/main/input_received(datum/port/input/port, list/return_values)
	if(COMPONENT_TRIGGERED_BY(boot, port))
		if(mech.set_to_operational())
			playsound(src, mech.stepsound, 30, TRUE)
		return
	if(COMPONENT_TRIGGERED_BY(shutdown, port))
		mech.eject_everyone()

/obj/item/circuit_component/mecha/main/proc/on_operational(datum/source)
	SIGNAL_HANDLER
	booted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mecha/main/proc/on_not_operational(datum/source)
	SIGNAL_HANDLER
	has_shutdown.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mecha/actions
	display_name = "Toggles"
	desc = "Used to control actions such as toggling safeties, strafting and lights."

	///Toggle the safeties
	var/datum/port/input/toggle_safeties
	///If safeties are on or off
	var/datum/port/output/safeties
	///Sent when safeties are (dis)engaged
	var/datum/port/output/safeties_toggled

	///Toggle strafing
	var/datum/port/input/toggle_strafing
	///If straging is enabled or disabled
	var/datum/port/output/strafing
	///Sent when strafing is toggled
	var/datum/port/output/stafing_toggled

	///Toggle lights
	var/datum/port/input/toggle_lights
	///If lights are on or off
	var/datum/port/output/lights
	///Sent when the lights are turned on/off
	var/datum/port/output/lights_toggled

/obj/item/circuit_component/mecha/actions/populate_ports()
	. = ..()
	toggle_safeties = add_input_port("Toggle Safeties", PORT_TYPE_SIGNAL)
	safeties = add_output_port("Safeties", PORT_TYPE_BOOLEAN)
	safeties_toggled = add_output_port("Safeties Toggled", PORT_TYPE_SIGNAL)
	if(mech.mecha_flags & CAN_STRAFE)
		toggle_strafing = add_input_port("Toggle Strafing", PORT_TYPE_SIGNAL)
		strafing = add_output_port("Strafing", PORT_TYPE_BOOLEAN)
		stafing_toggled = add_output_port("Strafing Toggled", PORT_TYPE_SIGNAL)
	if(mech.mecha_flags & HAS_LIGHTS)
		toggle_lights = add_input_port("Toggle Lights", PORT_TYPE_SIGNAL)
		lights = add_output_port("Lights", PORT_TYPE_BOOLEAN)
		lights_toggled = add_output_port("Lights Toggled", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mecha/equipment
	display_name = "Equipment"
	desc = "Used to trigger and receive signals from the equipment of an exosuit."

	///Use the equipment in our right slot
	var/datum/port/input/use_right_equipment
	///Use the equipment in our left slot
	var/datum/port/input/use_left_equipment

	///The target for the equipment
	var/datum/port/input/target

	///Signal sent when the equipment on the right slot is used
	var/datum/port/output/right_equipment_used
	///Signal sent when the equipment on the left slot is used
	var/datum/port/output/left_equipment_used

/obj/item/circuit_component/mecha/equipment/populate_ports()
	. = ..()
	use_right_equipment = add_input_port("Use Right", PORT_TYPE_SIGNAL)
	use_left_equipment = add_input_port("Use Left", PORT_TYPE_SIGNAL)

	target = add_input_port("Target", PORT_TYPE_ATOM, trigger = null)

	right_equipment_used = add_output_port("Right Used", PORT_TYPE_SIGNAL)
	left_equipment_used = add_output_port("Left Used", PORT_TYPE_ATOM)

/obj/item/circuit_component/mecha/equipment/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECHA_RECEIVED_EQUIPMENT, PROC_REF(register_equipment))
	if(mech)
		for(var/key, item in mech.equip_by_category)
			if(!item)
				continue
			register_equipment(mech, item)

/obj/item/circuit_component/mecha/equipment/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_MECHA_RECEIVED_EQUIPMENT)
	if(mech)
		for(var/key, item in mech.equip_by_category)
			if(!item)
				continue
			unregister_equipment(item)
	return ..()

/obj/item/circuit_component/mecha/equipment/input_received(datum/port/input/port, list/return_values)
	var/atom/chosen_target
	//TODO target-picking code
	if(isnull(chosen_target))
		return

	var/list/modifiers = list()
	if(COMPONENT_TRIGGERED_BY(use_right_equipment, port))
		modifiers[BUTTON] = RIGHT_CLICK
	else
		modifiers[BUTTON] = LEFT_CLICK

	mech.interact_with_atom(chosen_target, modifiers = modifiers)

/obj/item/circuit_component/mecha/equipment/proc/register_equipment(datum/source, obj/item/mecha_parts/mecha_equipment/equipment)
	SIGNAL_HANDLER
	RegisterSignal(equipment, COMSIG_MOB_USED_MECH_EQUIPMENT, PROC_REF(on_mech_equipment_used))
	RegisterSignal(equipment, COMSIG_MECHA_EQUIPMENT_DETACHED, PROC_REF(unregister_equipment))

/obj/item/circuit_component/mecha/equipment/proc/on_mech_equipment_used(obj/item/mecha_parts/mecha_equipment/equipment, obj/vehicle/sealed/mecha/chassis)
	SIGNAL_HANDLER
	if(equipment == mech.equip_by_category[MECHA_R_ARM])
		right_equipment_used.set_output(COMPONENT_SIGNAL)
	else if(equipment == mech.equip_by_category[MECHA_L_ARM])
		left_equipment_used.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mecha/equipment/proc/unregister_equipment(obj/item/mecha_parts/mecha_equipment/equipment)
	SIGNAL_HANDLER
	UnregisterSignal(equipment, list(COMSIG_MOB_USED_MECH_EQUIPMENT, COMSIG_MECHA_EQUIPMENT_DETACHED))

/obj/item/circuit_component/mecha/movement
	display_name = "Movement"
	desc = "Used to control movement of an exosuit in the four cardinal directions."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/input/move

	var/datum/port/output/moved

	var/datum/port/output/mecha_dir

/obj/item/circuit_component/mecha/movement/populate_ports()
	. = ..()
	move = add_direction_input_port("Move", NORTH|EAST|SOUTH|WEST, list(NORTH|SOUTH, WEST|EAST))

	moved = add_direction_output_port("Moved")

	mecha_dir = add_direction_output_port("Faced Direction")

/obj/item/circuit_component/mecha/movement/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECHA_VEHICULAR_MOVE, PROC_REF(on_vehicle_moved))
	RegisterSignal(shell, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_dir_changed))

/obj/item/circuit_component/mecha/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_MECHA_VEHICULAR_MOVE, COMSIG_ATOM_POST_DIR_CHANGE))
	return ..()

/obj/item/circuit_component/mecha/movement/proc/on_vehicle_moved(datum/source, direction)
	SIGNAL_HANDLER
	moved.set_output(direction)

/obj/item/circuit_component/mecha/movement/proc/on_dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	mecha_dir.set_output(new_dir)

/obj/item/circuit_component/mecha/movement/input_received(datum/port/input/port, list/return_values)
	var/direction = move.value
	if(!direction)
		return
	mech.vehicle_move(direction)

/obj/item/circuit_component/mecha/punch
	display_name = "Melee Attack"
	desc = "For when you just want to give someone or something a big stompy knuckle sandwhich."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///The punched atom.
	var/datum/port/output/attacked
	var/datum/port/output/attacker

/obj/item/circuit_component/mecha/punch/populate_ports()
	. = ..()
	attacked = add_output_port("Attacked Entity", PORT_TYPE_ATOM)
	attacker = add_output_port("Attacker", PORT_TYPE_USER)

/obj/item/circuit_component/mecha/punch/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECH_MELEE_ATTACK, PROC_REF(on_mecha_attacking))

/obj/item/circuit_component/mecha/punch/input_received(datum/port/input/port, list/return_values)
	var/atom/target //TODO code for choosing a valid target
	mech.interact_with_atom(target, only_melee = TRUE)

/obj/item/circuit_component/mecha/punch/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_MECH_MELEE_ATTACK)
	return ..()

/obj/item/circuit_component/mecha/punch/proc/on_mecha_attacking(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	attacked.set_output(target)
	if(user)
		attacker.set_output(user)

/obj/item/circuit_component/mecha/overclock
	display_name = "Overclock"
	desc = "Toggles overclock on and off."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/output/overclocked

/obj/item/circuit_component/mecha/overclock/populate_ports()
	. = ..()
	overclocked = add_output_port("Overclocked", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/mecha/overclock/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_MECHA_TOGGLE_OVERCLOCK, PROC_REF(on_overclock_toggled))

/obj/item/circuit_component/mecha/overclock/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_MECHA_TOGGLE_OVERCLOCK)
	return ..()

/obj/item/circuit_component/mecha/overclock/input_received(datum/port/input/port, list/return_values)
	mech.toggle_overclock()

/obj/item/circuit_component/mecha/overclock/proc/on_overclock_toggled(datum/source, new_overclock)
	SIGNAL_HANDLER
	overclocked.set_output(new_overclock)
