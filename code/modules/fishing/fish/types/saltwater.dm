/obj/item/fish/clownfish
	name = "clownfish"
	desc = "Clownfish catch prey by swimming onto the reef, attracting larger fish, and luring them back to the anemone. The anemone will sting and eat the larger fish, leaving the remains for the clownfish."
	icon_state = "clownfish"
	dedicated_in_aquarium_icon_state = "clownfish_small"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 5
	average_size = 30
	average_weight = 500
	stable_population = 4
	fish_traits = list(/datum/fish_trait/picky_eater)
	evolution_types = list(/datum/fish_evolution/lubefish)
	compatible_types = list(/obj/item/fish/clownfish/lube)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/clownfish/lube
	name = "lubefish"
	desc = "A clownfish exposed to cherry-flavored lube for far too long. First discovered the days following a cargo incident around the seas of Europa, when thousands of thousands of thousands..."
	icon_state = "lubefish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	dedicated_in_aquarium_icon_state = "lubefish_small"
	fish_traits = list(/datum/fish_trait/picky_eater, /datum/fish_trait/lubed)
	evolution_types = null
	compatible_types = list(/obj/item/fish/clownfish)
	food = /datum/reagent/lube
	fishing_difficulty_modifier = 5
	beauty = FISH_BEAUTY_GREAT

/obj/item/fish/cardinal
	name = "cardinalfish"
	desc = "Cardinalfish are often found near sea urchins, where the fish hide when threatened."
	icon_state = "cardinalfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 4
	fish_traits = list(/datum/fish_trait/vegan)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/greenchromis
	name = "green chromis"
	desc = "The Chromis can vary in color from blue to green depending on the lighting and distance from the lights."
	icon_state = "greenchromis"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#00ff00"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 5
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

	fishing_difficulty_modifier = 5 // Bit harder

/obj/item/fish/firefish
	name = "firefish goby"
	desc = "To communicate in the wild, the firefish uses its dorsal fin to alert others of potential danger."
	icon_state = "firefish"
	sprite_width = 6
	sprite_height = 5
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 3
	disliked_bait = list(/obj/item/food/bait/worm, /obj/item/food/bait/doughball)
	fish_movement_type = /datum/fish_movement/zippy
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/pufferfish
	name = "pufferfish"
	desc = "They say that one pufferfish contains enough toxins to kill 30 people, although in the last few decades they've been genetically engineered en masse to be less poisonous."
	icon_state = "pufferfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 8
	average_size = 60
	average_weight = 1000
	stable_population = 3
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28
	fillet_type = /obj/item/food/fishmeat/quality //Too bad they're poisonous
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/toxic)
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/lanternfish
	name = "lanternfish"
	desc = "Typically found in areas below 6600 feet below the surface of the ocean, they live in complete darkness."
	icon_state = "lanternfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	random_case_rarity = FISH_RARITY_VERY_RARE
	source_width = 28
	source_height = 21
	sprite_width = 8
	sprite_height = 8
	average_size = 50
	average_weight = 1000
	stable_population = 3
	fish_traits = list(/datum/fish_trait/nocturnal)
	required_temperature_min = MIN_AQUARIUM_TEMP+2 //My source is that the water at a depth 6600 feet is pretty darn cold.
	required_temperature_max = MIN_AQUARIUM_TEMP+18
	beauty = FISH_BEAUTY_NULL

/obj/item/fish/stingray
	name = "stingray"
	desc = "A type of ray, most known for its venomous stinger. Despite that, They're normally docile, if not a bit easily frightened."
	icon_state = "stingray"
	dedicated_in_aquarium_icon_state = "stingray_small"
	stable_population = 4
	sprite_height = 7
	sprite_width = 8
	average_size = 60
	average_weight = 700
	beauty = FISH_BEAUTY_GREAT
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_SALTWATER //Someone ought to add river rays later I guess.
	fish_traits = list(/datum/fish_trait/stinger, /datum/fish_trait/toxic_barbs, /datum/fish_trait/wary, /datum/fish_trait/carnivore, /datum/fish_trait/predator)

/obj/item/fish/swordfish
	name = "swordfish"
	desc = "A large billfish, most famous for its elongated bill, while also fairly popular for cooking, and as a fearsome weapon in the hands of a veteran spess-fisherman."
	icon = 'icons/obj/structures/aquarium/wide.dmi'
	icon_state = "swordfish"
	inhand_icon_state = "swordfish"
	dedicated_in_aquarium_icon = 'icons/obj/structures/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = "swordfish_small"
	force = 18
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts", "pierces")
	attack_verb_simple = list("slash", "cut", "pierce")
	block_sound = 'sound/weapons/parry.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'
	demolition_mod = 0.75
	attack_speed = 1 SECONDS
	block_chance = 50
	wound_bonus = 10
	bare_wound_bonus = 20
	armour_penetration = 75
	base_pixel_x = -18
	pixel_x = -18
	sprite_width = 13
	sprite_height = 6
	stable_population = 3
	average_size = 140
	average_weight = 4000
	breeding_timeout = 4.5 MINUTES
	feeding_frequency = 4 MINUTES
	health = 180
	beauty = FISH_BEAUTY_EXCELLENT
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	fish_movement_type = /datum/fish_movement/plunger
	fishing_difficulty_modifier = 25
	fillet_type = /obj/item/food/fishmeat/quality
	favorite_bait = list(
		list(
			"Type" = "Foodtype",
			"Value" = SEAFOOD,
		),
	)
	fish_traits = list(/datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/stinger)

/obj/item/fish/swordfish/get_force_rank()
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			force -= 11
			attack_speed -= 0.4 SECONDS
			block_chance -= 45
			armour_penetration -= 20
			wound_bonus -= 15
			bare_wound_bonus -= 20
		if(WEIGHT_CLASS_SMALL)
			force -= 8
			attack_speed -= 0.3 SECONDS
			block_chance -= 30
			armour_penetration -= 15
			wound_bonus -= 10
			bare_wound_bonus -= 20
		if(WEIGHT_CLASS_NORMAL)
			force -= 5
			attack_speed -= 0.2 SECONDS
			block_chance -= 20
			armour_penetration -= 10
			wound_bonus -= 10
			bare_wound_bonus -= 15
		if(WEIGHT_CLASS_BULKY)
			force -= 3
			attack_speed -= 0.1 SECONDS
			block_chance -= 10
			armour_penetration -= 5
			wound_bonus -= 5
			bare_wound_bonus -= 10
		if(WEIGHT_CLASS_GIGANTIC)
			force += 5
			attack_speed += 0.2 SECONDS
			demolition_mod += 0.15
			block_chance += 10
			armour_penetration += 5
			wound_bonus += 5
			bare_wound_bonus += 10

	if(status == FISH_DEAD)
		force -= 4 + w_class
		block_chance -= 25
		armour_penetration -= 30
		wound_bonus -= 10
		bare_wound_bonus -= 10

/obj/item/fish/swordfish/calculate_fish_force_bonus(bonus_malus)
	. = ..()
	armour_penetration += bonus_malus * 5
	wound_bonus += bonus_malus * 3
	bare_wound_bonus += bonus_malus * 5
	block_chance += bonus_malus * 7
