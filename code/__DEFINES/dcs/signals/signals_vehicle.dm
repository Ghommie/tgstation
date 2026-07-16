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

/// From /obj/vehicle/sealed/mecha/vehicle_move(): (direction)
#define COMSIG_MECHA_VEHICULAR_MOVE "mecha_vehicular_move"
/// From /obj/vehicle/sealed/mecha/set_safety(): ()
#define COMSIG_MECH_SAFETIES_TOGGLE "mech_safeties_toggle"
