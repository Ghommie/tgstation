/**
 * The core component for skeletons and skeletonized mobs in general (be it from the necromancer stone, spooky trumpet etcetera etcetera).
 * Please refrain from changing mobs to the skeleton species and use this component instead.
 */
/datum/component/skeletonized_mob
	dupe_mode = COMPONENT_DUPE_SOURCES

/datum/component/skeletonized_mob/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/skeletonized_mob/RegisterWithParent()
	parent.add_traits(list(
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NO_DNA_COPY,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_UNHUSKABLE,
	), REF(src))

	var/mob/living/carbon/human/human = parent

	human.add_faction(FACTION_SKELETON)
	human.mob_biotypes |= MOB_UNDEAD|MOB_SKELETAL

	RegisterSignal(human.dna.species, COMSIG_SPECIES_GET_MUTANT_ORGAN, PROC_REF(get_skeleton_organ))
	RegisterSignal(human, COMSIG_SPECIES_LOSS, PROC_REF(on_species_loss))
	RegisterSignal(human, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))
	RegisterSignal(human, COMSIG_SPECIES_REPLACE_BODY, PROC_REF(on_species_replace_body))

/datum/component/skeletonized_mob/UnregisterFromParent()
	parent.remove_traits(list(
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NO_DNA_COPY,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_UNHUSKABLE,
	), REF(src))

	var/mob/living/carbon/human/human = parent

	human.remove_faction(FACTION_SKELETON)
	//Remove the previously added mob biotypes, minus the biotypes that were present in the inherent biotypes of the species.
	human.mob_biotypes &= ~((MOB_UNDEAD|MOB_SKELETAL) & ~human.dna.species.inherent_biotypes)

	UnregisterSignal(human.dna.species, COMSIG_SPECIES_GET_MUTANT_ORGAN)
	UnregisterSignal(human, list(COMSIG_SPECIES_LOSS, COMSIG_SPECIES_GAIN, COMSIG_SPECIES_REPLACE_BODY))

/datum/component/skeletonized_mob/proc/get_skeleton_organ(datum/species/source, slot, mob/living/carbon/human/organ_holder, list/organ_replacement)
	SIGNAL_HANDLER

/datum/component/skeletonized_mob/proc/on_species_loss(mob/living/carbon/human/source, datum/species/old_species, datum/species/new_species)
	SIGNAL_HANDLER
	if(new_species)
		RegisterSignal(source.dna.species, COMSIG_SPECIES_GET_MUTANT_ORGAN, PROC_REF(get_skeleton_organ))

/datum/component/skeletonized_mob/proc/on_species_gain(mob/living/carbon/human/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	//In case we lost it because our old species was some other undead stuff, like vampires. *sighs*
	source.mob_biotypes |= MOB_UNDEAD

/datum/component/skeletonized_mob/proc/on_species_replace_body(mob/living/carbon/human/source, datum/species/new_species, list/bodypart_overrides)
	SIGNAL_HANDLER
