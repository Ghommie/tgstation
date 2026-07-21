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

/obj/item/circuit_component/mecha/should_receive_input(datum/port/input/port)
	if(isnull(mech))
		return FALSE
	if(requires_mech_on && !(mech.mecha_flags & MECHA_OPERATIONAL))
		return FALSE
	return ..()

/obj/item/circuit_component/mecha/unregister_shell(atom/movable/shell)
	mech = null
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

	target = add_input_port("Target", PORT_TYPE_ATOM)

	right_equipment_used = add_output_port("Right Used", PORT_TYPE_SIGNAL)
	left_equipment_used = add_output_port("Left Used", PORT_TYPE_ATOM)

/obj/item/circuit_component/mecha/movement
	display_name = "Movement"
	desc = "Used to control movement of an exosuit in the four cardinal directions."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/input/direction

	var/datum/port/output/moved
	var/datum/port/output/movement_dir

	var/datum/port/output/dir_changed
	var/datum/port/output/current_dir

	var/planned_direction = NONE

/obj/item/circuit_component/mecha/movement/populate_ports()
	. = ..()
	direction = add_input_port("Direction", PORT_TYPE_DIRECTION)

	moved = add_output_port("Moved", PORT_TYPE_SIGNAL)
	movement_dir = add_output_port("Movement Direction", PORT_TYPE_STRING)

	dir_changed = add_output_port("Direction Changed", PORT_TYPE_SIGNAL)
	current_dir = add_output_port("Current Direction", PORT_TYPE_STRING)

/obj/item/circuit_component/mecha/movement/input_received(datum/port/input/port, list/return_values)
	var/chosen_dir = direction.value
	if(!chosen_dir)
		return
	mech.vehicle_move(chosen_dir)

/obj/item/circuit_component/mecha/punch
	display_name = "Punch"
	desc = "For when you just want to punch things with your exosuit."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	///The punched atom.
	var/datum/port/output/punched_atom

/obj/item/circuit_component/mecha/punch/populate_ports()
	. = ..()
	punched_atom = add_output_port("Punched Entity", PORT_TYPE_ATOM)

/obj/item/circuit_component/mecha/overclock
	display_name = "Overclock"
	desc = "Toggles overclock on and off."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/output/overclocked

/obj/item/circuit_component/mecha/overclock/populate_ports()
	. = ..()
	overclocked = add_output_port("Overclocked", PORT_TYPE_BOOLEAN)
