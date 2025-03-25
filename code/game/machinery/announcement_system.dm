///Global list of all existing announcements systems
GLOBAL_LIST_EMPTY(announcement_systems)

///Global list of all possible announcements configs
GLOBAL_LIST_INIT_TYPED(aas_config_entries, /datum/aas_config_entry, init_aas_configs())

/proc/init_aas_configs()
	var/list/the_list = list()
	for(var/datum/aas_config_entry/config_type as anything in subtypesof(/datum/aas_config_entry))
		if(config_type::abstract_type == config_type)
			continue
		the_list[config_type] = new config_type
	return the_list

/obj/machinery/announcement_system
	density = TRUE
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "AAS_On"
	base_icon_state = "AAS"

	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.05

	circuit = /obj/item/circuitboard/machine/announcement_system

	///List of all types of config entries that have been disabled
	var/list/disabled_config_entries = list()
	///List of overridden announcement lines, by config type
	var/list/overridden_announcement_lines_map = list()

	///The headset that we use for broadcasting
	var/obj/item/radio/headset/radio
	///AIs headset support all stations channels, but it may require an override for away site or syndie AASs.
	var/radio_type = /obj/item/radio/headset/silicon/ai

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

/obj/machinery/announcement_system/Initialize(mapload)
	. = ..()
	GLOB.announcement_systems += src
	radio = new radio_type(src)
	update_appearance()

/obj/machinery/announcement_system/randomize_language_if_on_station()
	return

/obj/machinery/announcement_system/update_icon_state()
	icon_state = "[base_icon_state]_[is_operational && !(machine_stat & EMPED) ? "On" : "Off"][panel_open ? "_Open" : null]"
	return ..()

/obj/machinery/announcement_system/update_overlays()
	. = ..()
	if(!is_config_enabled(GLOB.aas_config_entries[/datum/aas_config_entry/arrival]))
		. += greenlight

	if(!is_config_enabled(GLOB.aas_config_entries[/datum/aas_config_entry/newhead]))
		. += pinklight

	if(machine_stat & EMPED)
		. += errorlight

/obj/machinery/announcement_system/Destroy()
	QDEL_NULL(radio)
	GLOB.announcement_systems -= src //"OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"
	return ..()

/obj/machinery/announcement_system/screwdriver_act(mob/living/user, obj/item/tool)
	var/icon_state_assemble = "[base_icon_state]_[is_operational && !(machine_stat & EMPED) ? "On" : "Off"]"
	if(default_deconstruction_screwdriver(user, "[icon_state_assemble]_Open", icon_state_assemble, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/announcement_system/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/announcement_system/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open || !(machine_stat & EMPED))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You reset [src]'s firmware."))
	set_machine_stat(machine_stat & ~EMPED)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/// Does funny breakage stuff
/obj/machinery/announcement_system/proc/act_up()
	if (machine_stat & EMPED)
		return
	set_machine_stat(machine_stat | EMPED)
	update_appearance()
	for (var/datum/aas_config_entry/config in GLOB.aas_config_entries)
		config.act_up(src)

/obj/machinery/announcement_system/emp_act(severity)
	. = ..()
	if(!(machine_stat & (NOPOWER|EMPED|BROKEN)) && !(. & EMP_PROTECT_SELF))
		act_up(src)

/obj/machinery/announcement_system/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	act_up(src)
	balloon_alert(user, "announcement strings corrupted")
	return TRUE

/obj/machinery/announcement_system/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AutomatedAnnouncement")
		ui.open()

/obj/machinery/announcement_system/ui_data()
	var/list/configs = list()
	for(var/config_type as anything in GLOB.aas_config_entries)
		var/datum/aas_config_entry/config = GLOB.aas_config_entries[config_type]
		if(config.hidden)
			continue

		var/list/final_lines
		var/list/override_lines = overridden_announcement_lines_map[config_type]
		if(override_lines)
			final_lines = list()
			for(var/line in config.announcement_lines_map)
				final_lines[line] = override_lines[line] || config.announcement_lines_map[line]
		else
			final_lines = config.announcement_lines_map

		configs += list(list(
			name = config.name,
			entryPath = config_type,
			enabled = is_config_enabled(config),
			modifiable = config.modifiable,
			announcementLinesMap = final_lines,
			generalTooltip = config.general_tooltip,
			varsAndTooltipsMap = config.vars_and_tooltips_map
		))
	return list("config_entries" = configs)

/obj/machinery/announcement_system/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!usr.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(machine_stat & EMPED)
		visible_message(span_warning("[src] buzzes."), span_hear("You hear a faint buzz."))
		playsound(src.loc, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
		return

	add_fingerprint(usr)
	var/datum/aas_config_entry/config = GLOB.aas_config_entries[text2path(params["entryPath"])]
	if(!istype(config) || !config.modifiable || config.hidden)
		return

	switch(action)
		if("Toggle")
			disabled_config_entries ^= config.type
			if (config.type in list(/datum/aas_config_entry/arrival, /datum/aas_config_entry/newhead))
				update_appearance()
		if("Text")
			var/line_key = params["lineKey"]
			if(!(line_key in config.announcement_lines_map))
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to set announcement line for nonexisting line in the [config.name] for AAS. Probably href injection. Received line: [params["lineKey"]]")
				log_game("[key_name(usr)] tried to mess with AAS. For [config.name] he tried to edit nonexistend [line_key]")
				return
			var/new_message = trim(html_encode(params["newText"]), MAX_MESSAGE_LEN)
			if(new_message)
				if(new_message == config.announcement_lines_map[line_key])
					LAZYREMOVEASSOC(overridden_announcement_lines_map, config.type, line_key)
				else
					LAZYINITLIST(overridden_announcement_lines_map)
					LAZYSET(overridden_announcement_lines_map[config.type], line_key, new_message)
				usr.log_message("updated [line_key] line in the [config.name] to: [new_message]", LOG_GAME)

/obj/machinery/announcement_system/can_interact(mob/user)
	. = ..()
	if (!.)
		return

	if (machine_stat & EMPED)
		to_chat(user, span_warning("[src]'s firmware appears to be malfunctioning!"))
		if (!isAI(user))	// Deus Ex Machina goes without multitool in his default complectation.
			to_chat(user, span_warning("However, you can reset it with [EXAMINE_HINT("multitool")], while its [EXAMINE_HINT("panel is open")]!"))
		return FALSE

/// If AAS can't broadcast message, it shouldn't be picked by randomizer.
/obj/machinery/announcement_system/proc/has_supported_channels(list/channels)
	if (!LAZYLEN(channels) || (RADIO_CHANNEL_COMMON in channels))
		// Okay, I am not proud of this, but I don't want CentCom or Syndie AASs to broadcast on Common.
		return src.type == /obj/machinery/announcement_system
	for(var/channel in channels)
		if(radio.channels[channel])
			return TRUE
	return FALSE

/// Can AAS receive request for broadcast from you?
/obj/machinery/announcement_system/proc/can_be_reached_from(atom/source)
	if(!source || !istype(source))
		return TRUE
	var/turf/source_turf = get_turf(source)
	if (!source_turf)
		return TRUE
	// Keep updated with broadcasting.dm (/datum/signal/subspace/vocal/New)
	return z in SSmapping.get_connected_levels(source_turf)

/// Compiles the announcement message with the provided variables. Announcement line is optional.
/obj/machinery/announcement_system/proc/compile_config_message(aas_config_entry_type, list/variables_map, announcement_line, fail_if_disabled=FALSE)
	var/datum/aas_config_entry/config = GLOB.aas_config_entries[aas_config_entry_type]
	if(fail_if_disabled && !is_config_enabled(config))
		return
	return config?.compile_announce(variables_map, announcement_line)

/obj/machinery/announcement_system/proc/is_config_enabled(datum/aas_config_entry/config)
	return config?.enabled && !(config.type in disabled_config_entries)

/// Sends a message to the appropriate channels.
/obj/machinery/announcement_system/proc/broadcast(message, list/channels, command_span = FALSE)
	use_energy(active_power_usage)
	if(!LAZYLEN(channels))
		radio.talk_into(src, message, null, command_span ? list(speech_span, SPAN_COMMAND) : null)
		return

	// For some reasons, radio can't recognize RADIO_CHANNEL_COMMON in channels, so we need to handle it separately.
	if (RADIO_CHANNEL_COMMON in channels)
		radio.talk_into(src, message, null, command_span ? list(speech_span, SPAN_COMMAND) : null)
		channels -= RADIO_CHANNEL_COMMON
	for(var/channel in channels)
		radio.talk_into(src, message, channel, command_span ? list(speech_span, SPAN_COMMAND) : null)

/// Announces configs entry message with the provided variables. Channels and announcement_line are optional.
/obj/machinery/announcement_system/proc/announce(aas_config_entry_type, list/variables_map, list/channels, announcement_line, command_span)
	var/msg = compile_config_message(aas_config_entry_type, variables_map, announcement_line, TRUE)
	if (msg)
		broadcast(msg, channels, command_span)

/// Returns a random announcement system that is operational, has the specified config entry, signal can reach source and radio supports any channel in list. Config entry, source and channels are optional.
/proc/get_announcement_system(aas_config_entry_type, source, list/channels)
	if (!GLOB.announcement_systems.len)
		return null
	var/list/intact_aass = list()
	for(var/obj/machinery/announcement_system/announce as anything in GLOB.announcement_systems)
		if(!QDELETED(announce) && announce.is_operational && announce.has_supported_channels(channels) && announce.can_be_reached_from(source))
			if(aas_config_entry_type)
				if(aas_config_entry_type in announce.disabled_config_entries)
					continue
			intact_aass += announce
	return intact_aass.len ? pick(intact_aass) : null

/// Announces the provided message with the provided variables and config entry type. Channels, announcement_line, command_span and source are optional.
/proc/aas_config_announce(aas_config_entry_type, list/variables_map, source, list/channels, announcement_line, command_span)
	var/obj/machinery/announcement_system/announcer = get_announcement_system(aas_config_entry_type, source, channels)
	if (!announcer)
		return
	announcer.announce(aas_config_entry_type, variables_map, channels, announcement_line, command_span)

/datum/aas_config_entry
	var/name = "AAS configurable entry"
	// Should we broadcast this announcement?
	var/enabled = TRUE
	// The announcement message. Key will be displayed in the UI.
	var/list/announcement_lines_map = list("Message" = "This is a default announcement line.")
	// Goes before tooltips for vars, mainly used if announcement has no replacable vars
	var/general_tooltip
	// Contains all replacable vars and their tooltips
	var/list/vars_and_tooltips_map = list()
	// Can be changed or disabled by players
	var/modifiable = TRUE
	/// If TRUE, it won't be shown in the announcement system. This also makes the config unmodifiable.
	var/hidden = FALSE
	/// If the current type matches the typepath from this variable, don't instantiatiate the object.
	var/abstract_type

/// Compiles the announcement message with the provided variables. Announcement line is optional.
/datum/aas_config_entry/proc/compile_announce(list/variables_map, announcement_line)
	var/announcement_message = LAZYACCESS(announcement_lines_map, announcement_line)
	// If index was provided LAZYACCESS will return us a key, not value
	if (isnum(announcement_line))
		announcement_message = announcement_lines_map[announcement_message]
	// Fallback - first line
	if (!announcement_message)
		announcement_message = announcement_lines_map[announcement_lines_map[1]]
	// Replace variables with their value
	for(var/variable in vars_and_tooltips_map)
		announcement_message = replacetext_char(announcement_message, "%[variable]", variables_map[variable] || "\[NO DATA\]")
	return announcement_message

/// Called when the announcement system is emagged or EMPed.
/datum/aas_config_entry/proc/act_up(obj/machinery/announcement_system/announcer)
	SHOULD_CALL_PARENT(TRUE)

	// Please do not mess with entries, that players can't fix.
	if(!modifiable)
		return TRUE
	return FALSE

/*
	Global config entries for the announcement system.
*/

/datum/aas_config_entry/arrival
	name = "Arrival Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON has signed up as %RANK")
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with their name.",
		"RANK" = "with their job."
	)

/datum/aas_config_entry/arrival/act_up(obj/machinery/announcement_system/announcer)
	. = ..()
	if (.)
		return

	var/new_message = pick(
		"#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!",
		"CRITICAL ERROR 99.",
		"ERR)#: DA#AB@#E NOT F(*ND!",
	)
	LAZYINITLIST(announcer.overridden_announcement_lines_map)
	LAZYSET(announcer.overridden_announcement_lines_map[type], "Message", new_message)

/datum/aas_config_entry/newhead
	name = "Departmental Head Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON, %RANK, is the department head.")
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with their name.",
		"RANK" = "with their job."
	)

/datum/aas_config_entry/newhead/act_up(obj/machinery/announcement_system/announcer)
	. = ..()
	if (.)
		return

	var/new_message = pick(
		"OV#RL()D: \[UNKNOWN??\] DET*#CT)D!",
		"ER)#R - B*@ TEXT F*O(ND!",
		"AAS.exe is not responding. NanoOS is searching for a solution to the problem.",
	)
	LAZYINITLIST(announcer.overridden_announcement_lines_map)
	LAZYSET(announcer.overridden_announcement_lines_map[type], "Message", new_message)

/datum/aas_config_entry/researched_node
	name = "Research Node Announcement"
	announcement_lines_map = list(
		"Message" = "The %NODE techweb node has been researched")
	vars_and_tooltips_map = list(
		"NODE" = "will be replaced with the researched node."
	)

/datum/aas_config_entry/researched_node/act_up(obj/machinery/announcement_system/announcer)
	. = ..()
	if (.)
		return

	var/new_message = pick(
		"The [/datum/techweb_node/mech_clown::display_name] techweb node has been researched",
		"R/NT1M3 A= ANNOUN-*#nt_SY!?EM.dm, LI%£ 86: N=0DE NULL!",
		"BEPIS BEPIS BEPIS",
		"ERR)#R - B*@ TEXT F*O(ND!",
	)
	LAZYINITLIST(announcer.overridden_announcement_lines_map)
	LAZYSET(announcer.overridden_announcement_lines_map[type], "Message", new_message)

/datum/aas_config_entry/arrivals_broken
	name = "Arrivals Shuttle Malfunction Announcement"
	announcement_lines_map = list(
		"Message" = "The arrivals shuttle has been damaged. Docking for repairs...")
	general_tooltip = "Broadcasted, when arrivals shuttle docks for repairs. No replacable variables provided."
	modifiable = FALSE

/datum/aas_config_entry/announce_officer
	name = "Security Alert: Officer Arrival Announcement"
	announcement_lines_map = list(
		"Message" = "Officer %OFFICER has been assigned to %DEPARTMENT.")
	vars_and_tooltips_map = list(
		"OFFICER" = "will be replaced with the officer's name.",
		"DEPARTMENT" = "with the department they were assigned to."
	)
	modifiable = FALSE

///special subtype of the aas_config_entry that's only enabled if the station has the required trait
/datum/aas_config_entry/station_trait
	enabled = FALSE
	modifiable = FALSE
	hidden = TRUE
	abstract_type = /datum/aas_config_entry/station_trait
	///The required trait for it to be enabled
	var/required_trait = STATION_TRAIT_ANNOUNCEMENT_SYSTEM_PLUS
	///If TRUE, the config will stay hidden even if enabled.
	var/stay_hidden = FALSE

/datum/aas_config_entry/station_trait/New()
	RegisterSignal(SSstation, SIGNAL_ADDTRAIT(required_trait), PROC_REF(reveal_config))
	RegisterSignal(SSstation, SIGNAL_REMOVETRAIT(required_trait), PROC_REF(hide_config))

/datum/aas_config_entry/station_trait/proc/reveal_config()
	SIGNAL_HANDLER
	if(!stay_hidden)
		hidden = FALSE
	enabled = TRUE

/datum/aas_config_entry/station_trait/proc/hide_config()
	SIGNAL_HANDLER
	hidden = TRUE
	enabled = FALSE

/datum/aas_config_entry/station_trait/suit_sensors_enable_them
	name = "Suit Sensors Reminder"
	announcement_lines_map = list(
		"Message" = "%DUMMY, max out your suit sensors, %PLEASE!")
	vars_and_tooltips_map = list(
		"DUMMY" = "a random person we occasionally remind to turn their sensors up.",
		"PLEASE" = "arbitrarily chosen filler word.",
	)

/datum/aas_config_entry/station_trait/vending_crush
	name = "Crushed by Vending Machine"
	announcement_lines_map = list(
		"Message" = "%ASSISTANT has been crushed by %SRC at %AREA")
	vars_and_tooltips_map = list(
		"ASSISTANT" = "replaced with the name of the person that just got pancaked",
		"SRC" = "the vending machine.",
		"AREA" = "the area of the accident",
	)

/datum/aas_config_entry/station_trait/tram_accident
	name = "Tram Collision"
	announcement_lines_map = list(
		"Message" = "%THEYVE been ran over by the tram!")
	vars_and_tooltips_map = list(
		"THEYVE" = "The unfortunate people that have been ran over by the ram in a 5 seconds span.",
	)

/datum/aas_config_entry/station_trait/sm_sacrifice
	name = "Supermatter Death"
	announcement_lines_map = list(
		"Message" = "%IDIOT has been consumed by the %SM!")
	vars_and_tooltips_map = list(
		"IDIOT" = "replaced with the name of whoever bit the dust.",
		"SM" = "a very dangerous crystal. Please don't lick it.",
	)

/datum/aas_config_entry/station_trait/rod_accident
	name = "Rod Accident"
	announcement_lines_map = list(
		"Message" = "%UNLUCKY has been skewered by %SRC.")
	vars_and_tooltips_map = list(
		"UNLUCKY" = "replaced by the name of whoever the rod teared a new one.",
		"SRC" = "the immovable rod",
	)

/datum/aas_config_entry/station_trait/emergency_pod_launch
	name = "Emergency Pod Launch"
	announcement_lines_map = list(
		"Message" = "%SHUTTLE has just been emergency launched away from the station.")
	vars_and_tooltips_map = list(
		"SHUTTLE" = "The name of the shuttle pod.",
	)

/datum/aas_config_entry/station_trait/too_many_critters
	name = "Too Many Critters"
	announcement_lines_map = list(
		"Message" = "Bluespace sensors reveal that the presence of %CRITTERS on your station has reached its theorical limit."
	)
	vars_and_tooltips_map = list(
		"CRITTERS" = "The name of the critters.",
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/displaycase_destroyed
	name = "Display Case Shattered"
	announcement_lines_map = list(
		"Message" = "%CASE has been shattered in %AREA!")
	vars_and_tooltips_map = list(
		"CASE" = "will be replaced with the trophy case's name.",
		"AREA" = "with the name of the area it's located.",
	)

/datum/aas_config_entry/station_trait/captain_safe_opened
	name = "Command Alert: Captain Safe Opened"
	announcement_lines_map = list(
		"Message" = "%SAFE has been opened by %SOMEONE!")
	vars_and_tooltips_map = list(
		"CASE" = "will be replaced with the name of the safe.",
		"SOMEONE" = "with the name of whoever opened it.",
	)

/datum/aas_config_entry/station_trait/disk_unsecured
	name = "Command Alert: Disk Unsecured"
	announcement_lines_map = list(
		"1" = "Disk-specific motion sensors show that the nuclear identification disk may be currently unguarded...",
		"2" = "The disk has seen a concerning lack of motion for some time now. Protocol reccommends someone picks it up. Now.",
		"3" = "Ding dong, the nuclear authentication disk just called, saying that it's getting quite lonely without someone holding it...",
		"4" = "Sleep tight disky, but not too tight, 'cause big mean operatives will come if nobody is there to guard you...",
		"5" = "Hello crew. It's been over %TIME since the last time the nuclear disk has been moved and the command is doing nothing about it.",
	)
	vars_and_tooltips_map = list(
		"TIME" = "how long the disk has been left unattended.",
	)

/datum/aas_config_entry/station_trait/patronage
	name = "Service Alert: Art Patronage"
	announcement_lines_map = list(
		"Message" = "%PATRON has donated %become the patron of the painting titled \"%ART\".")
	vars_and_tooltips_map = list(
		"PATRON" = "replaced with the name of the patron.",
		"MONEY" = "the amount of money donated.",
		"ART" = "the name of the painting, hopefully nothing stupid.",
	)

/datum/aas_config_entry/station_trait/mutation
	name = "Science Alert: Mutation Mapped"
	announcement_lines_map = list(
		"Message" = "The %MUTATION mutation has been mapped.")
	vars_and_tooltips_map = list(
		"MUTATION" = "replaced with the name of the mutation.",
	)

/datum/aas_config_entry/station_trait/relic
	name = "Science Alert: Relic Identified"
	announcement_lines_map = list(
		"Message" = "A %RELIC has been identified as a %GIZMO.")
	vars_and_tooltips_map = list(
		"RELIC" = "the name of the relic.",
		"GIZMO" = "its function.",
	)

/datum/aas_config_entry/station_trait/arrest
	name = "Security Alert: Wanted Status"
	announcement_lines_map = list(
		"Message" = "%CRIMINAL has been set on %WANTED.")
	vars_and_tooltips_map = list(
		"CRIMINAL" = "replaced with the record name.",
		"WANTED" = "either \"Wanted\" or \"Suspected\".",
	)

/datum/aas_config_entry/station_trait/beepsky_death
	name = "Security Alert: Beepsky Death"
	announcement_lines_map = list(
		"Message" = "%BEEPSKY has fallen on the line of duty at %AREA!")
	vars_and_tooltips_map = list(
		"BEEPSKY" = "replaced with beepsky's current name.",
		"AREA" = "the area where it was destroyed.",
	)

/datum/aas_config_entry/station_trait/poly_ghost
	name = "Engineering Alert: Poly Ghost"
	announcement_lines_map = list(
		"Message" = "Ectoplasmatic avian detected at %AREA. The ghost of %POLY now haunts the station.")
	vars_and_tooltips_map = list(
		"AREA" = "the area where Poly died.",
		"POLY" = "the name of the corpse of the now undead Poly.",
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/power_generation
	name = "Engineering Alert: Power Generation"
	announcement_lines_map = list(
		"Message" = "%ENGINE is currently generating %POWER.")
	vars_and_tooltips_map = list(
		"ENGINE" = "the name of the engine.",
		"POWER" = "the power generated by it.",
	)

/datum/aas_config_entry/station_trait/cargo_mark
	name = "Cargo Alert: 50k Credits Mark"
	announcement_lines_map = list(
		"Message" = "Cargo, you've reached the 50 000 credits mark this shift.")
	var/reached = FALSE

/datum/aas_config_entry/station_trait/cargo_mark/hundred_thousands
	name = "Cargo Alert: 100k Credits Mark"
	announcement_lines_map = list(
		"Message" = "Congratulations Cargo, you've reached the 100 000 credits mark this shift!")

/datum/aas_config_entry/station_trait/cargo_mark/two_hundred_fifty_thousands
	name = "Cargo Alert: 250k Credits Mark"
	announcement_lines_map = list(
		"Message" = "Congratulations Cargo! You've reached the 250 000 credits mark this shift!!")

/datum/aas_config_entry/station_trait/cargo_mark/two_hundred_fifty_thousands
	name = "Cargo Alert: 250k Credits Mark"
	announcement_lines_map = list(
		"Message" = "A round of applause for our hard working Cargo Department! They've reached the 250 000 credits mark this shift!!")

/datum/aas_config_entry/station_trait/cargo_mark/half_a_million
	name = "Cargo Alert: 500k Credits Mark"
	announcement_lines_map = list(
		"Message" = "An encore for our hard working Cargo Department and everyone who helped! They've reached the 500 000 credits mark!!")

/datum/aas_config_entry/station_trait/cargo_mark/half_a_million
	name = "Cargo Alert: One Milion Credits Mark"
	announcement_lines_map = list(
		"Message" = "ALL HAIL CARGONIA! They've broken through the ONE MILION credits mark!! HOORAY!!")

/datum/aas_config_entry/station_trait/cargo_mark/bicycle
	name = "Cargo Alert: ♪ I Want to Ride My Bicycle ♫"
	announcement_lines_map = list(
		"Message" = "CARGO HAS JUST BOUGHT THE ONE MILLION CREDITS BICYCLE! ♪ BICYCLE RACES ARE COMING YOUR WAY! ♫")
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/suit_sensors_status
	name = "Medical Alert: Suit Sensors"
	announcement_lines_map = list(
		"Message" = "Crew monitor update: %TRACKED people have their sensors maxed out, %LIFE have their life sensors on, and %BINARY just the binary sensors. For reference, there are %CREWMEMBERS crewmembers.")
	vars_and_tooltips_map = list(
		"TRACKED" = "the number of people with both sensors on",
		"LIFE" = "the number of people with life sensors on, but not tracking",
		"BINARY" = "the number that only have binary life sensors enabled",
		"CREWMEMBERS" = "Number of total crewmembers.",
	)

/datum/aas_config_entry/station_trait/spy_thievery
	name = "Antag Alert: Spy Thievery"
	announcement_lines_map = list(
		"Message" = "%OBJECT has been fenced by a spy.")
	vars_and_tooltips_map = list(
		"OBJECT" = "replaced with the name of the stolen object."
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/badass
	name = "Antag Alert: Badass"
	announcement_lines_map = list(
		"Message" = "%BADASS WANTS YOU TO KNOW THAT %THEYRE A MOTHERFUCKING BADASS ACTION MOVIE ROCKSTAR AND HAS JUST BOUGHT A SYNDICATE BALLOON TO PROVE IT!!!")
	vars_and_tooltips_map = list(
		"THEYRE" = "he's/she's/it's/they're depending on the pronouns of the buyer."
		"BADASS" = "whoever's mental enough to buy one."
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/his_grace
	name = "Antag Alert: His Grace"
	announcement_lines_map = list(
		"When Awake" = "His Grace has awakened..."
		"When Failed" = "%ULTRAKILLER has been eaten by %HIS own His Grace! Epic Fail!",
		"When Ascended" = "His Grace has ascended after having feasted on %SOULNUM souls, granting immense power to %ULTRAKILLER!",
		"When Destroyed" = "His Grace has been destroyed after having feasted on %SOULNUM souls...",
		)
	vars_and_tooltips_map = list(
		"SOULNUM" = "how many did it take for it to ascend?",
		"ULTRAKILLER" = "the madlad who did it.",
		"HIS" = "there's no Her Grace.",
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/blob_growth
	name = "Antag Alert: Blob"
	announcement_lines_map = list(
		"Halfway Critical" = "There's a blob on the station and it's halfway through reaching critical mass!",
		"75% Critical" = "There's a blob on the station and it's 75% through reaching critical mass!!",
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/ayy_win
	name = "Antag Alert: Abductors Victory"
	announcement_lines_map = list(
		"Message" = "Bluespace sensors have picked up what seems to be a victory signal coming from an abductors' UFO. It reads: \"Ayy Lmao\".",
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/ghost_circle
	name = "Ghost Circle"
	announcement_lines_map = list(
		"Message" = "Bluespace sensors have picked up a spectral presence composed of %GHOSTS individual ghosts all orbiting the same person or object on your station.",
	)
	vars_and_tooltips_map = list(
		"GHOSTS" = "the number of ghosts orbiting that thing...",
	)
	stay_hidden = TRUE

/datum/aas_config_entry/station_trait/happiness
	name = "Happiness Status"
	announcement_lines_map = list(
		"Message" = "There are currently %ELATED elated, %HAPPY happy, %NEUTRAL neutral, %SAD sad and %SORROWFUL sorrowful people on your station.",
	)
	vars_and_tooltips_map = list(
		"ELATED" = "number of exalted, enraptured people.",
		"HAPPY" = "number of glad, satisfied people.",
		"NEUTRAL" = "number of neutral, indifferent people.",
		"SAD" = "number of sad, sorry people.",
		"SORROWFUL" = "number of depressed or deranged people.",
	)
