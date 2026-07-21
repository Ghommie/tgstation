/**
 * # Drone
 *
 * A movable mob that can be fed inputs on which direction to travel.
 */
/mob/living/circuit_drone
	name = "drone"
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "setup_medium_med"
	maxHealth = 300
	health = 300
	mob_biotypes = MOB_ROBOTIC
	living_flags = NONE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE

/mob/living/circuit_drone/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bot_circuit(),
		new /obj/item/circuit_component/remotecam/drone()
	), SHELL_CAPACITY_LARGE)

/mob/living/circuit_drone/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += "[src]'s parts look loose."
		else
			. += "[src]'s parts look very loose!"
	else
		. += "[src] is in pristine condition."

/mob/living/circuit_drone/updatehealth()
	. = ..()
	if(health < 0)
		gib()

/mob/living/circuit_drone/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(health == maxHealth)
		balloon_alert(user, "already at maximum integrity!")
		return TRUE
	if(tool.use_tool(src, user, 1 SECONDS, volume = 50))
		heal_overall_damage(50, 50)
	return TRUE

/obj/item/circuit_component/bot_circuit
	display_name = "Drone"
	desc = "Used to send movement output signals to the drone shell."

	/// The input to allow for the drone to move
	var/datum/port/input/direction

	// Done like this so that travelling diagonally is more simple
	COOLDOWN_DECLARE(move_delay)

	/// Delay between each movement
	var/delay_duration = 0.2 SECONDS

/obj/item/circuit_component/bot_circuit/register_shell(atom/movable/shell)
	. = ..()
	if(ismob(shell))
		RegisterSignal(shell, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))

/obj/item/circuit_component/bot_circuit/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	return ..()

/obj/item/circuit_component/bot_circuit/proc/on_borg_charge(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER
	if (isnull(parent.cell))
		return
	charge_cell.Invoke(parent.cell, seconds_per_tick)

/obj/item/circuit_component/bot_circuit/populate_ports()
	direction = add_direction_input_port("Move", NORTH|EAST|SOUTH|WEST, list(NORTH|SOUTH, WEST|EAST))

/obj/item/circuit_component/bot_circuit/input_received(datum/port/input/port)
	var/mob/living/shell = parent.shell
	if(!istype(shell) || shell.stat || !COOLDOWN_FINISHED(src, move_delay))
		return

	var/dir_value = direction.value
	if(!dir_value)
		return

	COOLDOWN_START(src, move_delay, delay_duration)

	if(ismovable(shell.loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = shell.loc
		loc_atom.relaymove(shell, dir_value)
		return

	if(shell.Process_Spacemove(dir_value))
		shell.Move(get_step(shell, dir_value), dir_value)
