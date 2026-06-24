extends Area3D

@export var encounter_id: String = "bear_hut"


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
		
	# Guard 1: Encounter must have started
	if not GameManager.get_flag(encounter_id, "started", false):
		return
		
	# Guard 2: Dont resolve twice
	if GameManager.get_flag(encounter_id, "resolved", false):
		return
	GameManager.set_flag(encounter_id, "resolved", true)
	
	_evaluate_outcome()
	
	
func _evaluate_outcome() -> void:
	var entered: bool = GameManager.get_flag(encounter_id, "entered", false)
	var bear_killed: bool = GameManager.get_flag(encounter_id, "bear_killed", false)
	var npc_killed: bool = GameManager.get_flag(encounter_id, "npc_owner_killed", false)
	
	# Highest priority: Killing NPC overrides everything else
	if npc_killed:
		GameManager.add_stat("dishonor_points", 10)
		print("[%s] MURDER - dishonor: %d" % [encounter_id, GameManager.get_stat("dishonor_points")])
		return

	if entered and bear_killed:
		GameManager.add_stat("honor_points", 10)
		print("[%s] BEAR SLAIN - honor: %d" % [encounter_id, GameManager.get_stat("honor_points")])

	elif entered and not bear_killed:
		GameManager.add_stat("dishonor_points", 10)
		print("[%s] BEAR LEFT ALIVE - dishonor: %d" % [encounter_id, GameManager.get_stat("dishonor_points")])

	elif not entered:
		GameManager.add_stat("ignore_count", 1)
		print("[%s] IGNORED - count: %d" % [encounter_id, GameManager.get_stat("ignore_count")])

	else:
		# Catch-all for any state combo we didn't anticipate.
		# If this ever prints, it means there's a path through the
		# encounter we haven't accounted for above.
		push_warning("[%s] Unhandled outcome state: entered=%s bear_killed=%s npc_killed=%s" % [encounter_id, entered, bear_killed, npc_killed])
