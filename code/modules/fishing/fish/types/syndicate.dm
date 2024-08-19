///Contains fish that can be found in the syndicate fishing portal setting as well as the ominous fish case.
/obj/item/fish/emulsijack
	name = "toxic emulsijack"
	desc = "Ah, the terrifying emulsijack. Created in a laboratory, the only real use of this slimey, scaleless fish is for completely ruining a tank."
	icon_state = "emulsijack"
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	stable_population = 3
	fish_traits = list(/datum/fish_trait/emulsijack)
	required_temperature_min = MIN_AQUARIUM_TEMP+5
	required_temperature_max = MIN_AQUARIUM_TEMP+40
	beauty = FISH_BEAUTY_BAD

/obj/item/fish/donkfish
	name = "donk co. company patent donkfish"
	desc = "A lab-grown donkfish. Its invention was an accident for the most part, as it was intended to be consumed in donk pockets. Unfortunately, it tastes horrible, so it has now become a pseudo-mascot."
	icon_state = "donkfish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/donkfish
	fish_traits = list(/datum/fish_trait/yucky)
	required_temperature_min = MIN_AQUARIUM_TEMP+15
	required_temperature_max = MIN_AQUARIUM_TEMP+28
	beauty = FISH_BEAUTY_EXCELLENT

/obj/item/fish/jumpercable
	name = "monocloning jumpercable"
	desc = "A surprisingly useful if nasty looking creation from the syndicate fish labs. Drop one in a tank, and \
		watch it self-feed and multiply. Generates more and more power as a growing swarm!"
	icon_state = "jumpercable"
	dedicated_in_aquarium_icon_state = "jumpercable_small"
	sprite_width = 17
	sprite_height = 5
	stable_population = 12
	average_size = 110
	average_weight = 6000
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+30
	favorite_bait = list(/obj/item/stock_parts/power_store/cell/lead)
	fish_traits = list(
		/datum/fish_trait/parthenogenesis,
		/datum/fish_trait/mixotroph,
		/datum/fish_trait/electrogenesis,
	)
	beauty = FISH_BEAUTY_UGLY

/obj/item/fish/chainsawfish
	name = "chainsawfish"
	desc = "A very, very angry bioweapon, whose sole purpose is to rip and tear."
	icon = 'icons/obj/structures/aquarium/wide.dmi'
	icon_state = "chainsawfish"
	inhand_icon_state = "chainsawfish"
	icon_state_dead = "chainsawfish_dead"
	dedicated_in_aquarium_icon = 'icons/obj/structures/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = "chainsaw_small"
	force = 22
	demolition_mod = 1.5
	block_chance = 15
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5
	base_pixel_x = -16
	pixel_x = -16
	sprite_width = 8
	sprite_height = 5
	stable_population = 3
	average_size = 85
	average_weight = 2500
	breeding_timeout = 4.25 MINUTES
	feeding_frequency = 3 MINUTES
	health = 180
	beauty = FISH_BEAUTY_GREAT
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	fish_movement_type = /datum/fish_movement/accelerando
	fishing_difficulty_modifier = 30
	favorite_bait = list(
		list(
			"Type" = "Foodtype",
			"Value" = GORE
		),
	)
	fish_traits = list(/datum/fish_trait/aggressive, /datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/stinger)
	required_temperature_min = MIN_AQUARIUM_TEMP+18
	required_temperature_max = MIN_AQUARIUM_TEMP+26

/obj/item/fish/chainsawfish/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/fish/chainsawfish/update_icon_state()
	if(status == FISH_DEAD)
		inhand_icon_state = "chainsawfish_dead"
	else
		inhand_icon_state = "chainsawfish"
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		inhand_icon_state = "[inhand_icon_state]_wielded"
	return ..()

/obj/item/fish/chainsawfish/get_force_rank()
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			force -= 10
			attack_speed -= 0.2 SECONDS
			demolition_mod -= 0.4
			block_chance -= 15
			armour_penetration -= 10
			wound_bonus -= 10
			bare_wound_bonus -= 10
			toolspeed += 0.6
		if(WEIGHT_CLASS_SMALL)
			force -= 8
			attack_speed -= 0.1 SECONDS
			demolition_mod -= 0.3
			block_chance -= 10
			armour_penetration -= 10
			wound_bonus -= 10
			bare_wound_bonus -= 10
			toolspeed += 0.4
		if(WEIGHT_CLASS_NORMAL)
			force -= 5
			demolition_mod -= 0.15
			block_chance -= 5
			armour_penetration -= 5
			wound_bonus -= 5
			bare_wound_bonus -= 5
			toolspeed += 0.2
		if(WEIGHT_CLASS_HUGE)
			force += 2
			attack_speed += 0.2 SECONDS
			demolition_mod += 0.15
			armour_penetration += 10
			block_chance += 10
			wound_bonus += 10
			bare_wound_bonus += 5
		if(WEIGHT_CLASS_GIGANTIC)
			force += 4
			attack_speed += 0.4 SECONDS
			demolition_mod += 0.3
			block_chance += 20
			armour_penetration += 20
			wound_bonus += 15
			bare_wound_bonus += 10
			toolspeed -= 0.1

	if(status == FISH_DEAD)
		force -= 8 + w_class
		hitsound = SFX_SWING_HIT
		block_chance -= 25
		demolition_mod -= 0.3
		armour_penetration -= 15
		wound_bonus -= 5
		bare_wound_bonus -= 5
		toolspeed += 1

/obj/item/fish/chainsawfish/calculate_fish_force_bonus(bonus_malus)
	. = ..()
	armour_penetration += bonus_malus * 3
	wound_bonus += bonus_malus * 2
	bare_wound_bonus += bonus_malus * 3
	block_chance += bonus_malus * 2
	toolspeed -= bonus_malus * 0.1
