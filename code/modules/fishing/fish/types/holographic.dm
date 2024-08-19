
/obj/item/fish/holo
	name = "holographic goldfish"
	desc = "A holographic representation of a common goldfish, slowly flickering out, removed from its holo-habitat."
	icon_state = "goldfish"
	show_in_catalog = FALSE
	random_case_rarity = FISH_RARITY_NOPE
	sprite_width = 8
	sprite_height = 8
	stable_population = 1
	average_size = 30
	average_weight = 500
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	grind_results = null
	fillet_type = null
	death_text = "%SRC gently disappears."
	fish_traits = list(/datum/fish_trait/no_mating) //just to be sure, these shouldn't reproduce
	experisci_scannable = FALSE

/obj/item/fish/holo/Initialize(mapload, apply_qualities = TRUE)
	. = ..()
	var/area/station/holodeck/holo_area = get_area(src)
	if(!istype(holo_area))
		addtimer(CALLBACK(src, PROC_REF(set_status), FISH_DEAD), 1 MINUTES)
		return
	holo_area.linked.add_to_spawned(src)

/obj/item/fish/holo/set_status(new_status, silent = FALSE)
	. = ..()
	if(status == FISH_DEAD)
		animate(src, alpha = 0, 3 SECONDS, easing = SINE_EASING)
		QDEL_IN(src, 3 SECONDS)

/obj/item/fish/holo/crab
	name = "holographic crab"
	desc = "A holographic represantion of a soul-crushingly soulless crab, unlike the cuter ones occasionally roaming around. It stares at you, with empty, beady eyes."
	icon_state = "crab"
	dedicated_in_aquarium_icon_state = "crab_small"
	average_weight = 1000
	sprite_height = 6
	sprite_width = 10

/obj/item/fish/holo/puffer
	name = "holographic pufferfish"
	desc ="A holographic representation of 100% safe-to-eat pufferfish... that is, if holographic fishes were even edible."
	icon_state = "pufferfish"
	sprite_width = 8
	sprite_height = 8
	average_size = 60
	average_weight = 1000
	beauty = FISH_BEAUTY_GOOD

/obj/item/fish/holo/angel
	name = "holographic angelfish"
	desc = "A holographic representation of a angelfish. I got nothing snarky to say about this one."
	icon_state = "angelfish"
	dedicated_in_aquarium_icon_state = "bigfish"
	sprite_height = 7

/obj/item/fish/holo/clown
	name = "holographic clownfish"
	icon_state = "holo_clownfish"
	desc = "A holographic representation of a clownfish, or at least how they used to look like five centuries ago."
	dedicated_in_aquarium_icon_state = "holo_clownfish_small"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 5

/obj/item/fish/holo/checkered
	name = "unrendered holographic fish"
	desc = "A checkered silhoutte of searing purple and pitch black presents itself before your eyes, like a tear in fabric of reality. It hurts to watch."
	icon_state = "checkered" //it's a meta joke, buddy.
	dedicated_in_aquarium_icon_state = "checkered_small"
	sprite_width = 4
	beauty = FISH_BEAUTY_NULL

/obj/item/fish/holo/halffish
	name = "holographic half-fish"
	desc = "A holographic representation of... a fish reduced to all bones, except for its head. Isn't it supposed to be dead? Ehr, holo-dead?"
	icon_state = "half_fish"
	dedicated_in_aquarium_icon_state = "half_fish_small"
	sprite_height = 4
	sprite_width = 10
	average_size = 50
	beauty = FISH_BEAUTY_UGLY
