/obj/item/circuit_component/mecha
	/// The mech we are attached to
	var/obj/vehicle/sealed/mecha/mecha
	abstract_type = /obj/item/circuit_component/mecha

/obj/item/circuit_component/mecha/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/vehicle/sealed/mecha))
		mecha = shell

	if(isnull(mecha))
		return

/obj/item/circuit_component/mecha/main
	display_name = "Engagement"
	desc = "For engaging and disengaging an exosuit, even if it doesn't have an occupant inside."

	///Stop the mecha and eject any eventual occupant.
	var/datum/port/input/disengage
	///Engage the mecha, even without an occupant
	var/datum/port/input/engage

	///Sent when the mecha is engaged, usually after an occupant climbs in.
	var/datum/port/output/engaged
	/// Sent when the mecha is stopped, and the eventual occupant is ejected.
	var/datum/port/output/disengaged

/obj/item/circuit_component/mecha/actions
	display_name = "Toggles"
	desc = "Used to control actions such as toggling safeties, strafting and lights."
	///Toggle the safeties
	var/datum/port/input/toggle_safeties
	///Toggle strafing
	var/datum/port/input/toggle_strafing
	///Toggle lights
	var/datum/port/input/toggle_lights

	///Sent when safeties are (dis)engaged
	var/datum/port/output/safeties_toggled
	///If safeties are on or off
	var/datum/port/output/safeties

	///Sent when strafing is toggled
	var/datum/port/output/stafing_toggled
	///If straging is enabled or disabled
	var/datum/port/output/strafing

	///Sent when the lights are turned on/off
	var/datum/port/output/lights_toggled
	///If lights are on or off
	var/datum/port/output/lights

/obj/item/circuit_component/mecha/equipment
	display_name = "Equipment"
	desc = "Used to trigger and receive signals from the equipment of an exosuit."

	///Use the equipment in our right slot
	var/datum/port/input/use_right_equipment
	///Use the equipment in our left slot
	var/datum/port/input/use_left_equipment

	///Signal sent when the equipment on the right slot is used
	var/datum/port/output/right_equipment_used
	///Signal sent when the equipment on the left slot is used
	var/datum/port/output/left_equipment_used

/obj/item/circuit_component/mecha/movement
	display_name = "Movement"
	desc = "Used to control movement of an exosuit in the four cardinal directions."

	var/datum/port/input/up
	var/datum/port/input/down
	var/datum/port/input/left
	var/datum/port/input/right

	var/datum/port/output/moved
	var/datum/port/output/movement_dir

	var/datum/port/output/dir_changed
	var/datum/port/output/current_dir

/obj/item/circuit_component/mecha/combat
	display_name = "Combat"
	desc = "Used to control basic combat actions with an exosuit."

	///Punches whatever mob, wall or structure (in order of priority) in front of us when triggered.
	var/datum/port/input/punch

	///The punched atom.
	var/datum/port/output/punched_atom
	///Signal sent when the punch action is done.
	var/datum/port/output/punched
