/obj/item/bodypart/head/skeleton
	icon = 'icons/mob/human/skeleton_bodyparts.dmi'
	icon_static = 'icons/mob/human/skeleton_bodyparts.dmi'
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	head_flags = NONE
	bodypart_flags = BODYPART_UNHUSKABLE
	scarrable = FALSE
	skeleton_part = null
	bodypart_flags = parent_type::bodypart_flags | BODYPART_RETAIN_DIGITIGRADE //for digitigrade legs

/obj/item/bodypart/chest/skeleton
	icon = 'icons/mob/human/skeleton_bodyparts.dmi'
	icon_static = 'icons/mob/human/skeleton_bodyparts.dmi'
	biological_state = BIO_BONE
	limb_id = SPECIES_SKELETON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	bodypart_flags = BODYPART_UNHUSKABLE
	wing_types = list(/obj/item/organ/wings/functional/skeleton)
	scarrable = FALSE
	skeleton_part = null
	bodypart_flags = parent_type::bodypart_flags | BODYPART_RETAIN_DIGITIGRADE //for digitigrade legs

///In case this part was unfortunately aquired via butchering
/obj/item/bodypart/chest/skeleton/on_removal(mob/living/carbon/old_owner)
	. = ..()
	old_owner.cure_husk(SKELETON_TRAIT)

/obj/item/bodypart/arm/left/skeleton
	icon = 'icons/mob/human/skeleton_bodyparts.dmi'
	icon_static = 'icons/mob/human/skeleton_bodyparts.dmi'
	biological_state = (BIO_BONE|BIO_JOINTED)
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	bodypart_flags = BODYPART_UNHUSKABLE
	scarrable = FALSE
	skeleton_part = null

/obj/item/bodypart/arm/right/skeleton
	icon = 'icons/mob/human/skeleton_bodyparts.dmi'
	icon_static = 'icons/mob/human/skeleton_bodyparts.dmi'
	biological_state = (BIO_BONE|BIO_JOINTED)
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	bodypart_flags = BODYPART_UNHUSKABLE
	scarrable = FALSE
	skeleton_part = null

/obj/item/bodypart/leg/left/skeleton
	icon = 'icons/mob/human/skeleton_bodyparts.dmi'
	icon_static = 'icons/mob/human/skeleton_bodyparts.dmi'
	biological_state = (BIO_BONE|BIO_JOINTED)
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	bodypart_flags = BODYPART_UNHUSKABLE
	scarrable = FALSE
	skeleton_part = null

/obj/item/bodypart/leg/right/skeleton
	icon = 'icons/mob/human/skeleton_bodyparts.dmi'
	icon_static = 'icons/mob/human/skeleton_bodyparts.dmi'
	biological_state = (BIO_BONE|BIO_JOINTED)
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	bodypart_flags = BODYPART_UNHUSKABLE
	scarrable = FALSE
	skeleton_part = null

#define BODYPART_ID_SKELETON_BUG "skeleton_bug"
#define BODYPART_ID_SKELETON_MONKEY "skeleton_monkey"
#define BODYPART_ID_SKELETON_MUSH "skeleton_mush"

/obj/item/bodypart/head/skeleton/bug
	limb_id = BODYPART_ID_SKELETON_BUG
	teeth_count = 0

/obj/item/bodypart/arm/right/skeleton/bug
	limb_id = BODYPART_ID_SKELETON_BUG
	unarmed_attack_verbs = /obj/item/bodypart/arm/right/moth::unarmed_attack_verbs
	unarmed_attack_verbs_continuous = /obj/item/bodypart/arm/right/moth::unarmed_attack_verbs_continuous
	grappled_attack_verb = /obj/item/bodypart/arm/right/moth::grappled_attack_verb
	grappled_attack_verb_continuous = /obj/item/bodypart/arm/right/moth::grappled_attack_verb_continuous
	unarmed_attack_effect = /obj/item/bodypart/arm/right/moth::unarmed_attack_effect
	unarmed_attack_sound = /obj/item/bodypart/arm/right/moth::unarmed_attack_sound
	unarmed_miss_sound = /obj/item/bodypart/arm/right/moth

/obj/item/bodypart/arm/left/skeleton/bug
	limb_id = BODYPART_ID_SKELETON_BUG
	unarmed_attack_verbs = /obj/item/bodypart/arm/left/moth::unarmed_attack_verbs
	unarmed_attack_verbs_continuous = /obj/item/bodypart/arm/left/moth::unarmed_attack_verbs_continuous
	grappled_attack_verb = /obj/item/bodypart/arm/left/moth::grappled_attack_verb
	grappled_attack_verb_continuous = /obj/item/bodypart/arm/left/moth::grappled_attack_verb_continuous
	unarmed_attack_effect = /obj/item/bodypart/arm/left/moth::unarmed_attack_effect
	unarmed_attack_sound = /obj/item/bodypart/arm/left/moth::unarmed_attack_sound
	unarmed_miss_sound = /obj/item/bodypart/arm/left/moth

/obj/item/bodypart/leg/right/skeleton/bug
	limb_id = BODYPART_ID_SKELETON_BUG

/obj/item/bodypart/leg/left/skeleton/bug
	limb_id = BODYPART_ID_SKELETON_BUG


/obj/item/bodypart/head/skeleton/monkey
	limb_id = BODYPART_ID_SKELETON_MONKEY
	bodyshape = /obj/item/bodypart/head/monkey::bodyshape
	dmg_overlay_type = /obj/item/bodypart/head/monkey::dmg_overlay_type

/obj/item/bodypart/head/skeleton/monkey/Initialize(mapload)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_y = list("south" = 1),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_y = list("south" = 1),
	)
	return ..()

/obj/item/bodypart/chest/skeleton/monkey
	limb_id = BODYPART_ID_SKELETON_MONKEY
	wound_resistance = /obj/item/bodypart/chest/monkey::wound_resistance
	bodyshape = /obj/item/bodypart/chest/monkey::bodyshape
	acceptable_bodyshape = /obj/item/bodypart/chest/monkey::acceptable_bodyshape
	dmg_overlay_type = /obj/item/bodypart/chest/monkey::dmg_overlay_type

/obj/item/bodypart/chest/skeleton/monkey/Initialize(mapload)
	worn_neck_offset = new(
		attached_part = src,
		feature_key = OFFSET_NECK,
		offset_y = list("south" = 1),
	)
	return ..()

/obj/item/bodypart/arm/right/skeleton/monkey
	limb_id = BODYPART_ID_SKELETON_MONKEY
	bodyshape = /obj/item/bodypart/arm/right/monkey::bodyshape
	should_draw_greyscale = /obj/item/bodypart/arm/right/monkey::should_draw_greyscale
	wound_resistance = /obj/item/bodypart/arm/right/monkey::wound_resistance
	px_x = /obj/item/bodypart/arm/right/monkey::px_x
	px_y = /obj/item/bodypart/arm/left/monkey::px_y
	dmg_overlay_type = /obj/item/bodypart/arm/right/monkey::dmg_overlay_type
	unarmed_damage_low = /obj/item/bodypart/arm/right/monkey::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/arm/right/monkey::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/arm/right/monkey::unarmed_effectiveness
	appendage_noun = /obj/item/bodypart/arm/right/monkey::appendage_noun

/obj/item/bodypart/arm/left/skeleton/monkey
	limb_id = BODYPART_ID_SKELETON_MONKEY
	bodyshape = /obj/item/bodypart/arm/left/monkey::bodyshape
	should_draw_greyscale = /obj/item/bodypart/arm/left/monkey::should_draw_greyscale
	wound_resistance = /obj/item/bodypart/arm/left/monkey::wound_resistance
	px_x = /obj/item/bodypart/arm/left/monkey::px_x
	px_y = /obj/item/bodypart/arm/left/monkey::px_y
	dmg_overlay_type = /obj/item/bodypart/arm/left/monkey::dmg_overlay_type
	unarmed_damage_low = /obj/item/bodypart/arm/left/monkey::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/arm/left/monkey::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/arm/left/monkey::unarmed_effectiveness
	appendage_noun = /obj/item/bodypart/arm/left/monkey::appendage_noun

/obj/item/bodypart/leg/right/skeleton/monkey
	limb_id = BODYPART_ID_SKELETON_MONKEY
	bodyshape = /obj/item/bodypart/leg/right/monkey::bodyshape
	wound_resistance = /obj/item/bodypart/leg/right/monkey::wound_resistance
	px_y = /obj/item/bodypart/leg/right/monkey::px_y
	dmg_overlay_type = /obj/item/bodypart/leg/right/monkey::dmg_overlay_type
	unarmed_damage_low = /obj/item/bodypart/leg/right/monkey::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/leg/right/monkey::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/leg/right/monkey::unarmed_effectiveness
	footprint_sprite = /obj/item/bodypart/leg/right/monkey::footprint_sprite

/obj/item/bodypart/leg/left/skeleton/monkey
	limb_id = BODYPART_ID_SKELETON_MONKEY
	bodyshape = /obj/item/bodypart/leg/left/monkey::bodyshape
	wound_resistance = /obj/item/bodypart/leg/left/monkey::wound_resistance
	px_y = /obj/item/bodypart/leg/left/monkey::px_y
	dmg_overlay_type = /obj/item/bodypart/leg/left/monkey::dmg_overlay_type
	unarmed_damage_low = /obj/item/bodypart/leg/left/monkey::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/leg/left/monkey::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/leg/left/monkey::unarmed_effectiveness
	footprint_sprite = /obj/item/bodypart/leg/left/monkey::footprint_sprite

/obj/item/bodypart/head/skeleton/mushroom
	limb_id = BODYPART_ID_SKELETON_MUSH
	burn_modifier = /obj/item/bodypart/chest/mushroom::burn_modifier
	teeth_count = /obj/item/bodypart/head/mushroom::teeth_count

/obj/item/bodypart/chest/skeleton/mushroom
	limb_id = BODYPART_ID_SKELETON_MUSH
	bodypart_traits = /obj/item/bodypart/chest/mushroom::bodypart_traits
	burn_modifier = /obj/item/bodypart/chest/mushroom::burn_modifier

/obj/item/bodypart/arm/left/skeleton/mushroom
	limb_id = BODYPART_ID_SKELETON_MUSH
	unarmed_damage_low = /obj/item/bodypart/arm/left/mushroom::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/arm/left/mushroom::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/arm/left/mushroom::unarmed_effectiveness
	burn_modifier = /obj/item/bodypart/arm/left/mushroom::burn_modifier

/obj/item/bodypart/arm/right/skeleton/mushroom
	limb_id = BODYPART_ID_SKELETON_MUSH
	unarmed_damage_low = /obj/item/bodypart/arm/right/mushroom::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/arm/right/mushroom::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/arm/right/mushroom::unarmed_effectiveness
	burn_modifier = /obj/item/bodypart/arm/right/mushroom::burn_modifier

/obj/item/bodypart/leg/left/skeleton/mushroom
	limb_id = BODYPART_ID_SKELETON_MUSH
	unarmed_damage_low = /obj/item/bodypart/leg/left/mushroom::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/leg/left/mushroom::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/leg/left/mushroom::unarmed_effectiveness
	burn_modifier = /obj/item/bodypart/leg/left/mushroom::burn_modifier
	speed_modifier = /obj/item/bodypart/leg/left/mushroom::speed_modifier

/obj/item/bodypart/leg/right/skeleton/mushroom
	limb_id = BODYPART_ID_SKELETON_MUSH
	unarmed_damage_low = /obj/item/bodypart/leg/right/mushroom::unarmed_damage_low
	unarmed_damage_high = /obj/item/bodypart/leg/right/mushroom::unarmed_damage_high
	unarmed_effectiveness = /obj/item/bodypart/leg/right/mushroom::unarmed_effectiveness
	burn_modifier = /obj/item/bodypart/leg/right/mushroom::burn_modifier
	speed_modifier = /obj/item/bodypart/leg/right/mushroom::speed_modifier
