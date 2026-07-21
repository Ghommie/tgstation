#define JOYSTICK_NORTH "north"
#define JOYSTICK_SOUTH "south"
#define JOYSTICK_EAST "east"
#define JOYSTICK_WEST "west"
#define JOYSTICK_UP "up"
#define JOYSTICK_DOWN "down"
#define JOYSTICK_BUTTON_A "a"
#define JOYSTICK_BUTTON_B "b"
#define JOYSTICK_BUTTON_X "x"
#define JOYSTICK_BUTTON_Y "y"

/**
 * # Joystick Controller
 *
 * A handheld device. Its main features are its ability to be keybound and its directional output port,
 * which can be useful for remotely controlling the movement of other shells.
 */
/obj/item/joystick
	name = "joystick"
	desc = "An arcade-style joystick controller. Whether you're a gamer or an aircraft pilot, you probably already know how to use one."
	desc_controls = "<b>Alt-click</b> it to map its inputs."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "joystick" //TODO SPRITE
	inhand_icon_state = "electronic" //TODO SPRITE
	worn_icon_state = "electronic" //TODO SPRITE
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/list/current_actions = list()
	VAR_PRIVATE/ball_color
	VAR_PRIVATE/is_powered = FALSE
	VAR_PRIVATE/list/mapped_keys = list()
	VAR_PRIVATE/alist/action_names_to_type
	VAR_PRIVATE/alist/action_types_to_name = list()
	VAR_PRIVATE/mapping = FALSE

/obj/item/joystick/Initialize(mapload)
	. = ..()
	action_names_to_type = alist(
		"North" = JOYSTICK_NORTH,
		"South" = JOYSTICK_SOUTH,
		"East" = JOYSTICK_EAST,
		"West" = JOYSTICK_WEST,
		"Up" = JOYSTICK_UP,
		"Down" = JOYSTICK_DOWN,
		"A Button" = JOYSTICK_BUTTON_A,
		"B Button" = JOYSTICK_BUTTON_B,
		"X Button" = JOYSTICK_BUTTON_X,
		"Y Button" = JOYSTICK_BUTTON_Y,
	)
	for(var/action_name, action_type  in action_names_to_type)
		action_types_to_name[action_type] = action_name

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/controller()
	), SHELL_CAPACITY_MEDIUM)

	RegisterSignal(src, COMSIG_SHELL_CIRCUIT_ATTACHED, PROC_REF(on_circuit_attached))
	RegisterSignal(src, COMSIG_SHELL_CIRCUIT_REMOVED, PROC_REF(on_circuit_removed))

	ball_color = pick(COLOR_RED, COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/joystick/proc/on_circuit_attached(datum/source, obj/item/integrated_circuit/circuitboard)
	SIGNAL_HANDLER
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_SET_ON, PROC_REF(on_circuit_on_off))
	if(circuitboard.on)
		is_powered = TRUE
		update_appearance(UPDATE_OVERLAYS)

/obj/item/joystick/proc/on_circuit_on_off(obj/item/integrated_circuit/circuitboard, new_value)
	SIGNAL_HANDLER
	is_powered = new_value
	update_appearance(UPDATE_OVERLAYS)

/obj/item/joystick/proc/on_circuit_removed(datum/source, obj/item/integrated_circuit/circuitboard)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	UnregisterSignal(circuitboard, COMSIG_CIRCUIT_SET_ON)
	if(is_powered)
		is_powered = FALSE
		update_appearance(UPDATE_OVERLAYS)

/obj/item/joystick/update_overlays()
	. = ..()
	var/list/current_action_types = assoc_to_keys(current_actions)
	var/joystick_dir = NONE
	var/anti_joystick_dir = NONE
	if(JOYSTICK_NORTH in current_action_types)
		joystick_dir |= NORTH
		anti_joystick_dir |= SOUTH
	if(JOYSTICK_SOUTH in current_action_types)
		joystick_dir |= SOUTH
		anti_joystick_dir |= NORTH
	if(JOYSTICK_EAST in current_action_types)
		joystick_dir |= EAST
		anti_joystick_dir |= WEST
	if(JOYSTICK_WEST in current_action_types)
		joystick_dir |= WEST
		anti_joystick_dir |= EAST

	joystick_dir &= ~anti_joystick_dir

	var/dir_text = dir2text(joystick_dir)
	. += "joystick_[dir_text]"
	var/mutable_appearance/joystick_ball = mutable_appearance(icon, "joystick_ball_[dir_text]")
	joystick_ball.color = ball_color
	. += joystick_ball

	var/going_up = (JOYSTICK_UP in current_action_types)
	var/going_down = (JOYSTICK_DOWN in current_action_types)
	if(going_up != going_down)
		. += "joystick_going_[going_up ? "up" : "down"]"

	for(var/button_action in list(JOYSTICK_BUTTON_A, JOYSTICK_BUTTON_B, JOYSTICK_BUTTON_X, JOYSTICK_BUTTON_Y))
		. += "joystick_[button_action][(button_action in current_action_types) ? "_pressed" : ""]"

	if(is_powered)
		. += "joystick_powered"
		. += emissive_appearance(icon, "joystick_powered_emissive", src)

/obj/item/joystick/examine(mob/user)
	. = ..()
	if(!length(mapped_keys))
		. += span_warning("None of its inputs have been mapped yet!")
		return
	. += span_notice("The current input map is:")
	var/list/boxed_inputs = list()
	for(var/full_key in mapped_keys)
		var/action_type = mapped_keys[full_key]
		var/action_name = action_types_to_name[action_type]
		boxed_inputs += span_notice("\u2022 [action_name] - <b>[full_key]</b>")
		break
	. += boxed_message(boxed_inputs.Join("\n"))

/obj/item/joystick/click_alt(mob/user)
	. = ..()
	if(length(current_actions))
		balloon_alert(user, "release buttons and stick first!")
		return CLICK_ACTION_BLOCKING
	if(mapping)
		balloon_alert(user, "already mapping inputs!")
		return CLICK_ACTION_BLOCKING

	mapping = TRUE

	var/action_name = tgui_input_list(user, "Choose an input to (re)bind to a key", "Joystick Mapping", action_names_to_type)
	if(isnull(action_name))
		mapping = FALSE
		return CLICK_ACTION_SUCCESS

	var/action_type = action_names_to_type[action_name]
	var/current_full_key
	for(var/full_key in mapped_keys)
		if(mapped_keys[full_key] == action_type)
			current_full_key = full_key
			break

	var/new_full_key = tgui_input_keycombo(user, "Please bind a key for this input. (Press Alt to unbind).", title = "Joystick Mapping", default = current_full_key)
	if(!new_full_key)
		mapping = FALSE
		return CLICK_ACTION_SUCCESS
	var/existing_action_type = mapped_keys[new_full_key]
	if(existing_action_type)
		mapping = FALSE
		if(existing_action_type == action_type)
			balloon_alert(user, "input conflict with [action_types_to_name[existing_action_type]]!")
		return CLICK_ACTION_SUCCESS

	mapped_keys -= current_full_key
	if(new_full_key != "Alt") //niche case. Cuz if you were to bind alt, it'd definitely lock you out of rebinding inputs as long as you hold the joystick
		mapped_keys[new_full_key] = action_type
	mapping = FALSE

	return CLICK_ACTION_SUCCESS

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
	if(isnull(full_key) || mapping || !mapped_keys[full_key] || HAS_TRAIT(source, TRAIT_HANDS_BLOCKED))
		return

	if(!length(current_actions))
		RegisterSignal(source, COMSIG_MOB_KEYUP, PROC_REF(keyup))
		RegisterSignals(source, list(COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(release_all_buttons))

	var/action_type = mapped_keys[full_key]

	press_button(action_type, source, key) //we don't use the full key because keyup doesn't check for alt/shift/crtl click modifiers

/obj/item/joystick/proc/keyup(mob/source, key, client/client)
	SIGNAL_HANDLER
	release_button(source, key)
	if(!length(current_actions))
		UnregisterSignal(source, list(COMSIG_MOB_KEYUP, COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))

/obj/item/joystick/proc/press_button(action_type, mob/user, key)
	if(current_actions[key]) //clear the current action
		release_button(user, key, FALSE)

	current_actions[key] = action_type
	SEND_SIGNAL(src, COMSIG_JOYSTICK_BUTTON_PRESSED, action_type, user)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/joystick/proc/release_button(mob/user, key, update_appearance = TRUE)
	var/action_type = current_actions[key]
	current_actions -= key
	if(action_type)
		SEND_SIGNAL(src, COMSIG_JOYSTICK_BUTTON_RELEASED, action_type, user)
		update_appearance(UPDATE_OVERLAYS)

/obj/item/joystick/proc/release_all_buttons(mob/user)
	SIGNAL_HANDLER
	for(var/key in current_actions)
		release_button(user, key, FALSE)
	UnregisterSignal(user, list(COMSIG_MOB_KEYUP, COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))
	update_appearance(UPDATE_OVERLAYS)

/obj/item/circuit_component/joystick
	display_name = "Controller"
	desc = "Transmits inputs from the joystick shell. Useful for maneuvering remotely controlled shells."
	ui_color = "pink"
	//each button press is followed eventually by a button release, so the energy usage is doubled. Also direction inputs are fired every SScircuit_component tick.
	energy_usage_per_input = 0.0005 * STANDARD_CELL_CHARGE
	var/obj/item/joystick/joystick

	var/datum/port/output/direction

	var/datum/port/output/first_button
	var/datum/port/output/second_button
	var/datum/port/output/third_button
	var/datum/port/output/fourth_button

	/// The entity output
	var/datum/port/output/entity

	var/static/list/directional_actions = list(
		JOYSTICK_NORTH = NORTH,
		JOYSTICK_SOUTH = SOUTH,
		JOYSTICK_EAST = EAST,
		JOYSTICK_WEST = WEST,
		JOYSTICK_UP = UP,
		JOYSTICK_DOWN = DOWN,
	)

/obj/item/circuit_component/joystick/populate_ports()
	entity = add_output_port("User", PORT_TYPE_USER)
	direction = add_direction_output_port("Direction", dirs_blacklist = list(NORTH|SOUTH, EAST|WEST, UP|DOWN))

	first_button = add_output_port("A Button", PORT_TYPE_BOOLEAN)
	second_button = add_output_port("B Button", PORT_TYPE_BOOLEAN)
	third_button = add_output_port("X Button", PORT_TYPE_BOOLEAN)
	fourth_button = add_output_port("Y Button", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/joystick/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/joystick))
		joystick = shell

	RegisterSignal(shell, COMSIG_JOYSTICK_BUTTON_PRESSED, PROC_REF(on_button_pressed))
	RegisterSignal(shell, COMSIG_JOYSTICK_BUTTON_RELEASED, PROC_REF(on_button_released))

/obj/item/circuit_component/joystick/unregister_shell(atom/movable/shell)
	joystick?.release_all_buttons()
	joystick = null
	UnregisterSignal(shell, list(COMSIG_JOYSTICK_BUTTON_PRESSED, COMSIG_JOYSTICK_BUTTON_RELEASED))
	STOP_PROCESSING(SScircuit_component, src)

/obj/item/circuit_component/joystick/get_ui_notices()
	. = ..()
	. += create_ui_notice("Button outputs are set to 1 on press and 0 on release", "info", "gamepad")

/obj/item/circuit_component/joystick/proc/on_button_pressed(obj/item/joystick/source, action_type, mob/user)
	SIGNAL_HANDLER

	if(action_type in directional_actions)
		START_PROCESSING(SScircuit_component, src)
		return

	switch(action_type)
		if(JOYSTICK_BUTTON_A)
			first_button.set_output(TRUE)
		if(JOYSTICK_BUTTON_B)
			second_button.set_output(TRUE)
		if(JOYSTICK_BUTTON_X)
			third_button.set_output(TRUE)
		if(JOYSTICK_BUTTON_Y)
			fourth_button.set_output(TRUE)

/obj/item/circuit_component/joystick/proc/on_button_released(obj/item/joystick/source, action_type, mob/user)
	SIGNAL_HANDLER

	if(action_type in directional_actions)
		var/list/current_movement_actions = assoc_to_values(joystick.current_actions) & directional_actions
		if(!length(current_movement_actions))
			STOP_PROCESSING(SScircuit_component, src)
		return

	switch(action_type)
		if(JOYSTICK_BUTTON_A)
			first_button.set_output(FALSE)
		if(JOYSTICK_BUTTON_B)
			second_button.set_output(FALSE)
		if(JOYSTICK_BUTTON_X)
			third_button.set_output(FALSE)
		if(JOYSTICK_BUTTON_Y)
			fourth_button.set_output(FALSE)

/obj/item/circuit_component/joystick/process(seconds_per_tick)
	var/list/current_movement_actions = assoc_to_values(joystick.current_actions) & directional_actions
	var/dir_value = NONE
	for(var/action in current_movement_actions)
		dir_value |= directional_actions[action]

	direction.set_output(dir_value)

#undef JOYSTICK_NORTH
#undef JOYSTICK_SOUTH
#undef JOYSTICK_EAST
#undef JOYSTICK_WEST
#undef JOYSTICK_UP
#undef JOYSTICK_DOWN
#undef JOYSTICK_BUTTON_A
#undef JOYSTICK_BUTTON_B
#undef JOYSTICK_BUTTON_X
#undef JOYSTICK_BUTTON_Y
