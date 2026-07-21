/datum/port/input/direction
	var/allowed_directions = ALL
	var/list/dirs_blacklist

/datum/port/input/direction/New(obj/item/circuit_component/to_connect, name, datatype, order = 1, trigger = null, default = null, allowed_directions, list/dirs_blacklist)
	. = ..()
	src.allowed_directions = allowed_directions
	src.dirs_blacklist = dirs_blacklist

/datum/port/output/direction
	var/allowed_directions = ALL
	var/list/dirs_blacklist

/datum/port/output/direction/New(obj/item/circuit_component/to_connect, name, datatype, order = 1, allowed_directions, list/dirs_blacklist)
	. = ..()
	src.allowed_directions = allowed_directions
	src.dirs_blacklist = dirs_blacklist

/datum/circuit_datatype/direction
	datatype = PORT_TYPE_DIRECTION
	color = "pink"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT
	can_receive_from = list(PORT_TYPE_STRING, PORT_TYPE_NUMBER)

/datum/circuit_datatype/direction/convert_value(datum/port/port, value_to_convert, force)
	var/allowed_directions = SOUTH|NORTH|EAST|WEST|UP|DOWN
	var/list/dirs_blacklist
	if(!force)
		if(istype(port, /datum/port/input/direction))
			var/datum/port/input/direction/dir_input = port
			allowed_directions = dir_input.allowed_directions
			dirs_blacklist = dir_input.dirs_blacklist
		else if(istype(port, /datum/port/output/direction))
			var/datum/port/input/direction/dir_output = port
			allowed_directions = dir_output.allowed_directions
			dirs_blacklist = dir_output.dirs_blacklist

	var/return_value = value_to_convert
	if(istext(return_value))
		return_value = shorthand_text2dir(return_value)
	return_value &= allowed_directions

	for(var/blacklisted_combo in dirs_blacklist)
		if((return_value & blacklisted_combo) == blacklisted_combo) //Contains all dirs in the blacklisted entry
			return_value &= ~blacklisted_combo

	return return_value

/datum/circuit_datatype/direction/handle_manual_input(datum/port/input/port, mob/user, user_input)
	var/numerical_input = text2num(user_input)
	return numerical_input || user_input //Accept both numbers and strings. String will be later converted by text2dir()
