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
	desc_controls = "<b>Alt-click</b> it to map its inputs. <b>Right-Click</b> while it's in your active hand to toggle the output reset when a button is released on/off."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "joystick" //TODO SPRITE
	inhand_icon_state = "electronic" //TODO SPRITE
	worn_icon_state = "electronic" //TODO SPRITE
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/iron= SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass= SHEET_MATERIAL_AMOUNT,
	)
	///If TRUE, buttons A, B, X and Y will fire outputs when released as well.
	var/release_output_enabled = TRUE
	///A list of keys that are currently pressed, and the type of action they're bound to.
	var/list/current_actions = list()
	///An associative list of some types of actions as keys, and the relative directions as values.
	var/static/alist/directional_actions = list(
		JOYSTICK_NORTH = NORTH,
		JOYSTICK_SOUTH = SOUTH,
		JOYSTICK_EAST = EAST,
		JOYSTICK_WEST = WEST,
		JOYSTICK_UP = UP,
		JOYSTICK_DOWN = DOWN,
	)
	///An associative list of names for the various actions and the type of action they're associated to.
	VAR_PRIVATE/static/alist/action_names_to_type = alist(
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
	///An associative list of action types as keys and names as values (e.g. JOYSTICK_BUTTON_A = "A button")
	VAR_PRIVATE/static/alist/action_types_to_name
	///The color of the ball on the joystick shift. Purely visual.
	VAR_PRIVATE/ball_color
	///If TRUE, a light will shine on the joystick icon. Purely just a visual cue.
	VAR_PRIVATE/is_powered = FALSE
	///A list of keys and the action types as value
	VAR_PRIVATE/list/mapped_keys = list()
	///Set to true if the click_alt() proc is running.
	VAR_PRIVATE/mapping = FALSE

/obj/item/joystick/Initialize(mapload)
	. = ..()
	if(!action_types_to_name)
		action_types_to_name = list()
		for(var/action_name, action_type  in action_names_to_type)
			action_types_to_name[action_type] = action_name

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/controller()
	), SHELL_CAPACITY_MEDIUM, SHELL_FLAG_USB_PORT)

	RegisterSignal(src, COMSIG_SHELL_CIRCUIT_ATTACHED, PROC_REF(on_circuit_attached))
	RegisterSignal(src, COMSIG_SHELL_CIRCUIT_REMOVED, PROC_REF(on_circuit_removed))

	ball_color = pick(COLOR_RED, COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE)
	update_appearance(UPDATE_OVERLAYS)

///Called when a circuit is attached to this shell.
/obj/item/joystick/proc/on_circuit_attached(datum/source, obj/item/integrated_circuit/circuitboard)
	SIGNAL_HANDLER
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_SET_ON, PROC_REF(on_circuit_on_off))
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_SET_CELL, PROC_REF(on_circuit_set_cell))
	set_powered(circuitboard.on && !QDELETED(circuitboard.cell))

///Called when a circuit is enabled or disabled
/obj/item/joystick/proc/on_circuit_on_off(obj/item/integrated_circuit/circuitboard, new_value)
	SIGNAL_HANDLER
	set_powered(new_value && !QDELETED(circuitboard.cell))

///Called when a cell is removed or added
/obj/item/joystick/proc/on_circuit_set_cell(obj/item/integrated_circuit/circuitboard, obj/item/stock_parts/power_store/cell_to_set)
	SIGNAL_HANDLER
	set_powered(circuitboard.on && !QDELETED(circuitboard.cell))

///If circuit could not be used before and now can (or viceversa), update the overlays.
/obj/item/joystick/proc/set_powered(new_value)
	if(new_value == is_powered)
		return
	is_powered = new_value
	update_appearance(UPDATE_OVERLAYS)

///Called when a circuit is removed from this shell.
/obj/item/joystick/proc/on_circuit_removed(datum/source, obj/item/integrated_circuit/circuitboard)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	UnregisterSignal(circuitboard, list(COMSIG_CIRCUIT_SET_ON, COMSIG_CIRCUIT_SET_CELL))
	set_powered(FALSE)

///Update the joystick overlays each time the shaft is moved or released, each time a button is pressed or released, or whenever a circuit becomes available, is disabled or missing.
/obj/item/joystick/update_overlays()
	. = ..()
	var/list/current_action_types = assoc_to_keys(current_actions)

	var/joystick_dir = NONE
	var/anti_joystick_dir = NONE
	for(var/action_type, direction in ((current_action_types & directional_actions) - list(JOYSTICK_UP, JOYSTICK_DOWN)))
		joystick_dir |= direction
		anti_joystick_dir |= REVERSE_DIR(direction)

	joystick_dir &= ~anti_joystick_dir

	var/dir_text = dir2text(joystick_dir)
	. += "joystick_[dir_text]"
	var/mutable_appearance/joystick_ball = mutable_appearance(icon, "joystick_ball_[dir_text]")
	joystick_ball.color = ball_color
	. += joystick_ball
	var/mutable_appearance/pad_stripes = mutable_appearance(icon, "joystick_pad_strips")
	pad_stripes.color = ball_color
	. += pad_stripes

	var/going_up = (JOYSTICK_UP in current_action_types)
	var/going_down = (JOYSTICK_DOWN in current_action_types)
	if(going_up != going_down)
		. += "joystick_arrow_[going_up ? "up" : "down"]"

	for(var/button_action in list(JOYSTICK_BUTTON_A, JOYSTICK_BUTTON_B, JOYSTICK_BUTTON_X, JOYSTICK_BUTTON_Y))
		. += "joystick_[button_action][(button_action in current_action_types) ? "_pressed" : ""]"

	if(is_powered)
		. += "joystick_powered"
		. += emissive_appearance(icon, "joystick_powered_emissive", src)

///Print a boxed message with a bullet point list of the currently mapped actions
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

///Used to allow or deny the ports of the the A, B, X and Y buttons from outputting FALSE when the buttons are release.
/obj/item/joystick/attack_self_secondary(mob/user, list/modifiers)
	if(length(current_actions))
		balloon_alert(user, "release buttons and shaft first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	release_output_enabled = !!release_output_enabled
	playsound(src, release_output_enabled ? 'sound/items/weapons/magin.ogg' : 'sound/items/weapons/magout.ogg', 30, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "button release outputs [release_output_enabled ? "enabled" : "disabled"]")
	return ..()

/**
 * This proc allows the user to choose an action type and bind a key to it. Because the proc sleeps while we wait for player inputs, we need to make sure that
 * they can still use the joystick after each tgui. We also make sure that two action types never share the same key, and that the Alt button can be used to unbind keys.
 */
/obj/item/joystick/click_alt(mob/user)
	. = ..()

	if(length(current_actions)) ///Prevent actions from running while the user is mapping the inputs.
		balloon_alert(user, "release buttons and shaft first!")
		return CLICK_ACTION_BLOCKING
	if(mapping) ///One at a time. It's easier to control the flow of things this way.
		balloon_alert(user, "already mapping inputs!")
		return CLICK_ACTION_BLOCKING

	mapping = TRUE

	var/action_name = tgui_input_list(user, "Choose an input to (re)bind to a key", "Joystick Mapping", action_names_to_type)
	if(!action_name || !user.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH|ALLOW_RESTING))
		mapping = FALSE
		return CLICK_ACTION_SUCCESS

	var/action_type = action_names_to_type[action_name]
	var/current_full_key
	for(var/full_key in mapped_keys)
		if(mapped_keys[full_key] == action_type)
			current_full_key = full_key
			break

	var/new_full_key = tgui_input_keycombo(user, "Please bind a key for this input. (Press Alt to unbind).", title = "Joystick Mapping", default = current_full_key)
	if(!new_full_key || !user.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH|ALLOW_RESTING))
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
		balloon_alert(user, "input for [action_name] set to [new_full_key]")
	else
		balloon_alert(user, "input for [action_name] cleared")
	mapping = FALSE

	return CLICK_ACTION_SUCCESS

///if the joystick is found in one of the hand slots, register the keydown signal
/obj/item/joystick/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HANDS))
		return
	RegisterSignal(user, COMSIG_MOB_KEYDOWN, PROC_REF(keydown))

///Terminate all current actions if we haven't, and unresiger the keydown signal.
/obj/item/joystick/dropped(mob/living/user, silent)
	. = ..()
	if(length(current_actions))
		release_all_buttons()
	UnregisterSignal(user, COMSIG_MOB_KEYDOWN, PROC_REF(keydown))

/**
 * Called when a key is pressed while holding the joystick. Check that the key is valid, that we aren't mapping, and that the user mob can use its hands.
 * If these checks pass, register some mob signals if we haven't and call press_button()
 */
/obj/item/joystick/proc/keydown(mob/source, key, client/client, full_key)
	SIGNAL_HANDLER
	if(isnull(full_key) || mapping || !mapped_keys[full_key] || HAS_TRAIT(source, TRAIT_HANDS_BLOCKED))
		return

	if(!length(current_actions))
		RegisterSignal(source, COMSIG_MOB_KEYUP, PROC_REF(keyup))
		RegisterSignals(source, list(COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(release_all_buttons))

	var/action_type = mapped_keys[full_key]

	press_button(action_type, source, key) //we don't use the full key because keyup doesn't check for alt/shift/crtl click modifiers

/**
 * Called when a key is released while the user is holding the joystick and at least one joystick action is running.
 * This calls release_button(). If the list of current actions is empty, clear the mob signals.
 */
/obj/item/joystick/proc/keyup(mob/source, key, client/client)
	SIGNAL_HANDLER
	if(isnull(key))
		return
	release_button(source, key)
	if(!length(current_actions))
		UnregisterSignal(source, list(COMSIG_MOB_KEYUP, COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))

///Called when a key mapped to an action type is pressed. This initiates an action.
/obj/item/joystick/proc/press_button(action_type, mob/user, key)
	if(current_actions[key]) //clear the current action if there's any first (as fallback)
		release_button(user, key, TRUE)

	current_actions[key] = action_type
	SEND_SIGNAL(src, COMSIG_JOYSTICK_BUTTON_PRESSED, action_type, user)
	playsound(src, directional_actions[action_type] ? SFX_JOYSTICK_SHAFT : SFX_JOYSTICK_BUTTON_PRESS, 40, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	update_appearance(UPDATE_OVERLAYS)

///Terminate the action assigned to the key, if silent, the sound cue isn't played and the overlays aren't updated.
/obj/item/joystick/proc/release_button(mob/user, key, silent = FALSE)
	var/action_type = current_actions[key]
	current_actions -= key
	if(!action_type)
		return
	SEND_SIGNAL(src, COMSIG_JOYSTICK_BUTTON_RELEASED, action_type, user)
	if(silent)
		return
	if(!directional_actions[action_type] && release_output_enabled) //only play the sound cue if not a directional action and if release_output_enabled is TRUE.
		playsound(src, SFX_JOYSTICK_BUTTON_RELEASE, 40, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	update_appearance(UPDATE_OVERLAYS)

///Terminate all current actions. It's called when the user is unable to use the joystick or if the joystick is dropped.
/obj/item/joystick/proc/release_all_buttons(mob/user)
	SIGNAL_HANDLER
	for(var/key in current_actions)
		release_button(user, key, TRUE)
	UnregisterSignal(user, list(COMSIG_MOB_KEYUP, COMSIG_MOB_LOGOUT, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))
	update_appearance(UPDATE_OVERLAYS)

///The circuit component of the joystick shell that cannot be removed.
/obj/item/circuit_component/joystick
	display_name = "Controller"
	desc = "Transmits inputs from the joystick shell. Useful for maneuvering remotely controlled shells."
	ui_color = "pink"
	//each button press is followed eventually by a button release, so the energy usage is doubled. Also direction inputs are fired every SScircuit_component tick.
	energy_usage_per_input = 0.0005 * STANDARD_CELL_CHARGE
	var/obj/item/joystick/joystick

	///This port outputs the direction of all pressed directional keys, unless where they conflict (e.g NORTH and SOUTH, EAST and WEST)
	var/datum/port/output/direction

	///The port bound to the key for the A button
	var/datum/port/output/a_button
	///The port bound to the key for the B button
	var/datum/port/output/b_button
	///The port bound to the key for the X button
	var/datum/port/output/x_button
	///The port bound to the key for the Y button
	var/datum/port/output/y_button

/obj/item/circuit_component/joystick/populate_ports()
	direction = add_direction_output_port("Direction", dirs_blacklist = list(NORTH|SOUTH, EAST|WEST, UP|DOWN))

	a_button = add_output_port("A Button", PORT_TYPE_BOOLEAN)
	b_button = add_output_port("B Button", PORT_TYPE_BOOLEAN)
	x_button = add_output_port("X Button", PORT_TYPE_BOOLEAN)
	y_button = add_output_port("Y Button", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/joystick/register_shell(atom/movable/shell)
	if(!istype(shell, /obj/item/joystick))
		return

	joystick = shell

	RegisterSignal(shell, COMSIG_JOYSTICK_BUTTON_PRESSED, PROC_REF(on_button_pressed))
	RegisterSignal(shell, COMSIG_JOYSTICK_BUTTON_RELEASED, PROC_REF(on_button_released))
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF_SECONDARY, PROC_REF(on_attack_secondary))

/obj/item/circuit_component/joystick/unregister_shell(atom/movable/shell)
	joystick = null
	UnregisterSignal(shell, list(COMSIG_JOYSTICK_BUTTON_PRESSED, COMSIG_JOYSTICK_BUTTON_RELEASED, COMSIG_ITEM_ATTACK_SELF_SECONDARY))
	STOP_PROCESSING(SScircuit_component, src)

/obj/item/circuit_component/joystick/should_receive_input(datum/port/input/port)
	if(isnull(joystick))
		return FALSE
	return ..()

/obj/item/circuit_component/joystick/get_ui_notices()
	. = ..()
	. += create_ui_notice("Button outputs are set to 1 on press and 0 on release.", "info", "gamepad")
	. += create_ui_notice("Toggle button release outputs by right-clicking the joystick while holding it.", "orange", "gamepad")

/**
 * Called when a key for a joystick action is pressed. If the action is for a direction, start processing.
 * If it isn't for a direction, set the output for that action to TRUE.
 */
/obj/item/circuit_component/joystick/proc/on_button_pressed(obj/item/joystick/source, action_type, mob/user)
	SIGNAL_HANDLER

	if(joystick.directional_actions[action_type])
		START_PROCESSING(SScircuit_component, src)
		return

	switch(action_type)
		if(JOYSTICK_BUTTON_A)
			a_button.set_output(TRUE)
		if(JOYSTICK_BUTTON_B)
			b_button.set_output(TRUE)
		if(JOYSTICK_BUTTON_X)
			x_button.set_output(TRUE)
		if(JOYSTICK_BUTTON_Y)
			y_button.set_output(TRUE)

/**
 * Called when a key for a joystick action is released. If the action is for a direction and there no other directions, stop processing.
 * Otherwise, if the release_output_enabled variable of the joystick item is set to TRUE, reset the output for that action back to FALSE.
 */
/obj/item/circuit_component/joystick/proc/on_button_released(obj/item/joystick/source, action_type, mob/user)
	SIGNAL_HANDLER

	if(joystick.directional_actions[action_type])
		var/list/current_movement_actions = assoc_to_values(joystick.current_actions) & joystick.directional_actions
		if(!length(current_movement_actions))
			STOP_PROCESSING(SScircuit_component, src)
		return

	if(!joystick.release_output_enabled)
		return

	switch(action_type)
		if(JOYSTICK_BUTTON_A)
			a_button.set_output(FALSE)
		if(JOYSTICK_BUTTON_B)
			b_button.set_output(FALSE)
		if(JOYSTICK_BUTTON_X)
			x_button.set_output(FALSE)
		if(JOYSTICK_BUTTON_Y)
			y_button.set_output(FALSE)

///While one or more keys for directions are held, the circuit will constantly output those directions every 1/10 of a second.
/obj/item/circuit_component/joystick/process(seconds_per_tick)
	var/list/current_movement_actions = assoc_to_values(joystick.current_actions) & joystick.directional_actions
	var/dir_value = NONE
	for(var/action in current_movement_actions)
		dir_value |= joystick.directional_actions[action]

	direction.set_output(dir_value)

///This proc if for resetting button outputs that have a value of TRUE (1) back to FALSE (0)
/obj/item/circuit_component/joystick/proc/on_attack_secondary(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(!joystick.release_output_enabled)
		return
	 //button outputs can be set to FALSE again. Reset any output that's still set to TRUE.
	if(a_button.value)
		a_button.set_output(FALSE)
	if(b_button.value)
		b_button.set_output(FALSE)
	if(x_button.value)
		x_button.set_output(FALSE)
	if(y_button.value)
		y_button.set_output(FALSE)

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
