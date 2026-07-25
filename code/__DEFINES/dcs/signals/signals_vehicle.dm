/// Called on a mob when they start riding a vehicle (obj/vehicle)
#define COMSIG_VEHICLE_RIDDEN "vehicle-ridden"
	/// Return this to signal that the mob should be removed from the vehicle
	#define EJECT_FROM_VEHICLE (1<<0)

/// From /obj/vehicle/sealed/mob_exit(): ()
#define COMSIG_SEALED_VEHICLE_MOB_EXIT "sealed_vehicle_mob_exit"

/// From /datum/action/vehicle/ridden/wheelchair/bell/Trigger():
#define COMSIG_WHEELCHAIR_BELL_RANG "wheelchair_bell_rang"

// /obj/vehicle/sealed/mecha signals

/// sent if you attach equipment to mecha
#define COMSIG_MECHA_EQUIPMENT_ATTACHED "mecha_equipment_attached"
#define COMSIG_MECHA_RECEIVED_EQUIPMENT "mecha_received_equipment"
/// sent if you detach equipment to mecha
#define COMSIG_MECHA_EQUIPMENT_DETACHED "mecha_equipment_detached"
/// sent when you are able to drill through a mob
#define COMSIG_MECHA_DRILL_MOB "mecha_drill_mob"

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_TRIGGER "mecha_action_activate"

///sent from clicking while you have no equipment selected. Sent before cooldown and adjacency checks, so you can use this for infinite range things if you want.
#define COMSIG_MECHA_MELEE_CLICK "mecha_action_melee_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_MELEE_CLICK (1<<0)
///sent from clicking while you have equipment selected.
#define COMSIG_MECHA_EQUIPMENT_CLICK "mecha_action_equipment_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_EQUIPMENT_CLICK (1<<0)


///From /obj/vehicle/sealed/mecha/set_to_operational()
#define COMSIG_MECHA_IS_OPERATIONAL "mecha_is_operational"
///From /obj/vehicle/sealed/mecha/reset_to_non_operational()
#define COMSIG_MECHA_NOT_OPERATIONAL "mecha_not_operational"

/// From /obj/vehicle/sealed/mecha/vehicle_move(): (direction)
#define COMSIG_MECHA_VEHICULAR_MOVE "mecha_vehicular_move"
/// From /obj/vehicle/sealed/mecha/set_safety(): (user, weapon_safery)
#define COMSIG_MECH_SAFETIES_TOGGLE "mech_safeties_toggle"
/// From /obj/vehicle/sealed/mecha/toggle_strafe(): (strafe)
#define COMSIG_MECH_STRAFE_TOGGLE "mech_strafe_toggle"
/// From /obj/vehicle/sealed/mecha/toggle_strafe(): (lights_on)
#define COMSIG_MECH_LIGHTS_TOGGLE "mech_lights_toggle"
///From /obj/vehicle/sealed/mecha/toggle_overclock(): (overclock)
#define COMSIG_MECHA_TOGGLE_OVERCLOCK "mecha_toggle_overclock"
/// From /atom/mech_melee_attack(): (atom/target, mob/user)
#define COMSIG_MECH_MELEE_ATTACK "mech_melee_attack"
/// From /obj/vehicle/sealed/mecha/phazon/change_damage_type(): ()
#define COMSIG_MECH_CHANGE_DAMAGE_TYPE "mech_change_damage_type"
/// From /obj/vehicle/sealed/mecha/phazon/toggle_phasing(): (phasing)
#define COMSIG_MECHA_TOGGLE_PHASING "mech_toggle_phasing"
///From /obj/vehicle/sealed/mecha/durand/toggle_defense(): (defense_mode)
#define COMSIG_MECHA_TOGGLE_DEFENSE "mech_toggle_defense"
