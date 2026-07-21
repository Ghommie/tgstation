#define JOYSTICK_ACTION_NORTH "north"
#define JOYSTICK_ACTION_SOUTH "south"
#define JOYSTICK_ACTION_EAST "east"
#define JOYSTICK_ACTION_WEST "west"
#define JOYSTICK_ACTION_UP "up"
#define JOYSTICK_ACTION_DOWN "down"
#define JOYSTICK_BUTTON_ONE "one"
#define JOYSTICK_BUTTON_TWO "two"
#define JOYSTICK_BUTTON_THREE "three"
#define JOYSTICK_BUTTON_FOUR "four"


/**
 * # Joystick Controller
 *
 * A handheld device. Its main features are its ability to be keybound and its directional output port,
 * which can be useful for remotely controlling the movement of other shells.
 */
/obj/item/joystick
	name = "joystick"
	desc = "An arcade-style joystick controller. Whether you're a gamer or an aircraft pilot, you probably already know how to use one."
//	desc_controls = "" //TODO
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "joystick" //TODO SPRITE
	inhand_icon_state = "electronic" //TODO SPRITE
	worn_icon_state = "electronic" //TODO SPRITE
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/list/buttons_style
	var/list/mapped_keys = list()
	var/list/current_actions = list()

/obj/item/joystick/Initialize(mapload)
	. = ..()
	buttons_style = prob(50) ? list("A", "B", "X", "Y") : list("Cross", "Square", "Triangle", "Circle")
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/controller()
	), SHELL_CAPACITY_MEDIUM)

/obj/item/joystick/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HANDS))
		return
	RegisterSignal(user, COMSIG_MOB_KEYDOWN, PROC_REF(keydown))

/obj/item/joystick/dropped(mob/living/user, silent)
	. = ..()
	if(length(current_actions))
		release_all_buttons()
	UnregisterSignal(user, COMSIG_MOB_KEYDOWN, PROC_REF(keydown))

/obj/item/joystick/proc/keydown(mob/source, key, client/client, full_key)
	SIGNAL_HANDLER
	if(isnull(full_key) || !mapped_keys[full_key] || HAS_TRAIT(source, TRAIT_HANDS_BLOCKED))
		return

	if(!length(current_actions))
		RegisterSignal(source, COMSIG_MOB_KEYUP, PROC_REF(keyup))
		RegisterSignals(source, list(COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(release_all_buttons))

	var/action_type = mapped_keys[full_key]

	press_button(action_type, source, key)

/obj/item/joystick/proc/keyup(mob/source, key, client/client)
	SIGNAL_HANDLER
	release_button(source, key)
	if(!length(current_actions))
		UnregisterSignal(source, list(COMSIG_MOB_KEYUP, COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))

/obj/item/joystick/proc/press_button(action_type, mob/user, key)
	if(current_actions[key]) //clear the current action
		release_button(user, key)

	current_actions[key] = action_type
	SEND_SIGNAL(src, COMSIG_JOYSTICK_BUTTON_PRESSED, action_type, user)

/obj/item/joystick/proc/release_button(mob/user, key)
	var/action_type = current_actions[key]
	current_actions -= key
	if(action_type)
		SEND_SIGNAL(src, COMSIG_JOYSTICK_BUTTON_RELEASED, action_type, user)

/obj/item/joystick/proc/release_all_buttons(mob/user)
	SIGNAL_HANDLER
	for(var/key in current_actions)
		release_button(user, key)
	UnregisterSignal(user, list(COMSIG_MOB_KEYUP, COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))

/obj/item/circuit_component/joystick
	display_name = "Controller"
	desc = "Transmits inputs from the joystick shell. Useful for directional outputs."
	var/obj/item/joystick/joystick

	var/datum/port/output/direction

	var/datum/port/output/first_button
	var/datum/port/output/second_button
	var/datum/port/output/third_button
	var/datum/port/output/fourth_button

	/// The entity output
	var/datum/port/output/entity

	var/static/list/directional_actions = list(
		JOYSTICK_ACTION_NORTH = NORTH,
		JOYSTICK_ACTION_SOUTH = SOUTH,
		JOYSTICK_ACTION_EAST = EAST,
		JOYSTICK_ACTION_WEST = WEST,
		JOYSTICK_ACTION_UP = UP,
		JOYSTICK_ACTION_DOWN = DOWN,
	)

/obj/item/circuit_component/joystick/populate_ports()
	entity = add_output_port("User", PORT_TYPE_USER)
	direction = add_direction_output_port("Direction", NORTH|EAST|SOUTH|WEST|UP|DOWN, list(NORTH|SOUTH, EAST|WEST, UP|DOWN))

	first_button = add_output_port("A", PORT_TYPE_BOOLEAN)
	second_button = add_output_port("B", PORT_TYPE_BOOLEAN)
	third_button = add_output_port("X", PORT_TYPE_BOOLEAN)
	fourth_button = add_output_port("Y", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/joystick/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/joystick))
		joystick = shell
		first_button.name = joystick.buttons_style[1]
		second_button.name = joystick.buttons_style[2]
		third_button.name = joystick.buttons_style[3]
		fourth_button.name = joystick.buttons_style[4]

	RegisterSignal(shell, COMSIG_JOYSTICK_BUTTON_PRESSED, PROC_REF(on_button_pressed))
	RegisterSignal(shell, COMSIG_JOYSTICK_BUTTON_RELEASED, PROC_REF(on_button_released))

/obj/item/circuit_component/joystick/unregister_shell(atom/movable/shell)
	joystick?.release_all_buttons()
	joystick = null
	UnregisterSignal(shell, list(COMSIG_JOYSTICK_BUTTON_PRESSED, COMSIG_JOYSTICK_BUTTON_RELEASED))
	STOP_PROCESSING(SScircuit_component, src)

/obj/item/circuit_component/joystick/proc/on_button_pressed(obj/item/joystick/source, action_type, mob/user)
	SIGNAL_HANDLER

	if(action_type in directional_actions)
		START_PROCESSING(SScircuit_component, src)
		return

/obj/item/circuit_component/joystick/proc/on_button_released(obj/item/joystick/source, action_type, mob/user)
	SIGNAL_HANDLER

	if(!(action_type in directional_actions))
		return

	var/list/current_movement_actions = assoc_to_values(joystick.current_actions) & directional_actions
	if(!length(current_movement_actions))
		STOP_PROCESSING(SScircuit_component, src)

/obj/item/circuit_component/joystick/process(seconds_per_tick)
	var/list/current_movement_actions = assoc_to_values(joystick.current_actions) & directional_actions
	var/dir_value = NONE
	for(var/action in current_movement_actions)
		dir_value |= directional_actions[action]

	direction.set_output(dir_value)

#undef JOYSTICK_ACTION_NORTH
#undef JOYSTICK_ACTION_SOUTH
#undef JOYSTICK_ACTION_EAST
#undef JOYSTICK_ACTION_WEST
#undef JOYSTICK_ACTION_UP
#undef JOYSTICK_ACTION_DOWN
#undef JOYSTICK_BUTTON_ONE
#undef JOYSTICK_BUTTON_TWO
#undef JOYSTICK_BUTTON_THREE
#undef JOYSTICK_BUTTON_FOUR
