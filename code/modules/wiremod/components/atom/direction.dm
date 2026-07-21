/**
 * # Direction Component
 *
 * Return the direction of a mob relative to the component
 */
/obj/item/circuit_component/direction
	display_name = "Get Direction"
	desc = "A component that returns the direction of itself and an entity."
	category = "Entity"

	/// The input port
	var/datum/port/input/input_port

	// Directions output
	var/datum/port/output/direction

	var/datum/port/output/distance


	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Maximum range for a valid direction to be returned
	var/max_range = 7

/obj/item/circuit_component/direction/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/direction/populate_ports()
	input_port = add_input_port("Targeted Entity", PORT_TYPE_ATOM)

	direction = add_direction_output_port("Direction", ALL)
	distance = add_output_port("Distance", PORT_TYPE_NUMBER)

/obj/item/circuit_component/direction/input_received(datum/port/input/port)

	var/atom/object = input_port.value
	if(!object)
		return
	var/turf/location = get_location()
	var/measured_distance = get_dist(location, object)

	if(object.z != location.z || measured_distance > max_range)
		direction.set_output(NONE)
		return

	var/dir_value = get_dir(location, get_turf(object))
	direction.set_output(dir_value)

	distance.set_output(measured_distance)
