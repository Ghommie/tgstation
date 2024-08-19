/obj/item/fish/sockeye_salmon
	name = "sockeye salmon"
	desc = "A fairly common and iconic salmon endemic of the Pacific Ocean. At some point imported into outer space, where we're now."
	icon_state = "sockeye"
	dedicated_in_aquarium_icon_state = "sockeye_small"
	sprite_width = 6
	sprite_height = 4
	stable_population = 6
	required_temperature_min = MIN_AQUARIUM_TEMP+3
	required_temperature_max = MIN_AQUARIUM_TEMP+19
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	fillet_type = /obj/item/food/fishmeat/salmon
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/arctic_char
	name = "arctic char"
	desc = "A cold-water anadromous fish widespread around the Northern Hemisphere of Earth, yet it has somehow found a way here."
	icon_state = "arctic_char"
	dedicated_in_aquarium_icon_state = "arctic_char"
	sprite_width = 7
	sprite_height = 4
	stable_population = 6
	average_size = 60
	average_weight = 1200
	weight_size_deviation = 0.5 // known for their size dismophism
	required_temperature_min = MIN_AQUARIUM_TEMP+3
	required_temperature_max = MIN_AQUARIUM_TEMP+19
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
